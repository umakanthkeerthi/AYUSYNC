import json
import requests
from typing import Dict, Any
from ..core.event_bus import event_bus
from ..core.database_session import SessionLocal
from ..core.config import settings
from ..models.database import VitalSign, Patient
from ..models.events import AnalysisEvent, EventSource

from langchain_groq import ChatGroq
from langchain_core.messages import SystemMessage, HumanMessage

def handle_event(topic: str, payload: Dict[str, Any]):
    """
    Risk Predictor Agent
    Listens for trigger.risk_assessment events from the Monitoring Agent.
    Now supercharged with Groq LLM for trend analysis.
    """
    if topic != "trigger.risk_assessment":
        return

    print(f"🧠 [Risk Predictor Agent] Received risk assessment trigger for Patient: {payload.get('patient_id')}")
    
    patient_id = payload.get("patient_id")
    if not patient_id:
        print("❌ [Risk Predictor Agent] Missing patient_id in payload.")
        return

    db = SessionLocal()
    try:
        # 1. Fetch recent vitals for patient from database to spot trends (last 5)
        recent_vitals = db.query(VitalSign).filter(VitalSign.patient_id == patient_id).order_by(VitalSign.timestamp.desc()).limit(5).all()
        
        if not recent_vitals:
            print("⚠️ [Risk Predictor Agent] No vitals found for patient.")
            return
            
        latest_vitals = recent_vitals[0]
            
        hr = float(latest_vitals.heart_rate or 80.0)
        
        # 2. Format the payload for the live external ML API
        api_payload = {
            "respiratory_rate": 16.0 if hr < 110 else 28.0,
            "oxygen_saturation": float(latest_vitals.oxygen_saturation or 98.0),
            "o2_scale": 1,
            "systolic_bp": float(latest_vitals.blood_pressure_systolic or 120.0),
            "heart_rate": hr,
            "temperature": 37.0 if hr < 110 else 39.0,
            "consciousness": "A" if hr < 110 else "V",
            "on_oxygen": 0 if hr < 110 else 1
        }
        
        # 3. Call the external ML Vitals API
        print(f"🧠 [Risk Predictor Agent] Querying external ML API...")
        headers = {"X-API-Key": "Ayusync-Secret-Key-1234"}
        response = requests.post(
            "https://ayusync.vitalsriskpred.toplabs.in/api/predict",
            json=api_payload,
            headers=headers
        )
        
        if response.status_code == 200:
            result = response.json()
            risk_level = result.get("risk_level", "Unknown")
            risk_prob = result.get("probabilities", {}).get(risk_level, 0)
            
            # Map risk_level back to a 0-100 score for our Care Planning agent
            risk_score = 0
            if risk_level == "Medium": risk_score = 50
            if risk_level == "High": risk_score = 90
            
            print(f"🚨 [Risk Predictor Agent] Predicted Risk Level: {risk_level} ({risk_prob}%)")
            
            # 4. Use Groq to analyze trends and write a comprehensive SBAR explanation
            print(f"🧠 [Risk Predictor Agent] Querying Groq ({settings.GROQ_MODEL_NAME}) for Trend Analysis...")
            
            # Format the history for the LLM
            history_text = "\n".join([
                f"- Time: {v.timestamp}, HR: {v.heart_rate}, BP: {v.blood_pressure_systolic}/{v.blood_pressure_diastolic}, O2: {v.oxygen_saturation}%" 
                for v in reversed(recent_vitals) # chronologically
            ])
            
            try:
                llm = ChatGroq(
                    api_key=settings.GROQ_API_KEY,
                    model_name=settings.GROQ_MODEL_NAME,
                    temperature=0.2
                )
                
                messages = [
                    SystemMessage(content="You are an expert AI clinical analyst for the Doc AI system. Your job is to read the patient's recent vitals history and the Machine Learning model's risk score. You must write a concise, professional SBAR (Situation, Background, Assessment, Recommendation) note explaining *why* the ML model gave this score and highlight any concerning trends (e.g., 'Heart rate is steadily increasing'). Keep it under 4 sentences."),
                    HumanMessage(content=f"ML Predicted Risk: {risk_level} ({risk_prob}% probability)\n\nRecent Vitals History (Oldest to Newest):\n{history_text}")
                ]
                
                llm_response = llm.invoke(messages)
                clinical_reasoning = llm_response.content
                print(f"📝 [Risk Predictor Agent] Groq AI Reasoning:\n{clinical_reasoning}")
                
            except Exception as llm_err:
                print(f"⚠️ [Risk Predictor Agent] Groq LLM failed, falling back to basic explanation. Error: {str(llm_err)}")
                clinical_reasoning = f"SBAR: ML model indicated {risk_level} risk ({risk_prob}%). Latest HR: {latest_vitals.heart_rate}."
            
            from ..models.database import DoctorEscalation, Medication
            from datetime import datetime, timezone
            
            medication = db.query(Medication).filter(Medication.patient_id == patient_id).first()
            doc_id = medication.prescribed_by_id if medication else "unknown"

            escalation = DoctorEscalation(
                patient_id=patient_id,
                doctor_id=doc_id,
                risk_score=risk_score,
                shap_explanation=clinical_reasoning,
                timestamp=datetime.now(timezone.utc)
            )
            db.add(escalation)
            db.commit()
            print("✅ [Risk Predictor Agent] Saved DoctorEscalation to database.")

            # 5. Broadcast the analysis event back to EventBridge
            analysis_event = AnalysisEvent(
                patient_id=patient_id,
                source=EventSource.RISK_AGENT,
                topic="analysis.risk_scored",
                data={
                    "risk_score": risk_score,
                    "reasoning": clinical_reasoning,
                    "raw_vitals": api_payload
                }
            )
            
            # Publish back to event bus
            event_bus.publish(analysis_event)
            
        else:
            print(f"❌ [Risk Predictor Agent] ML API returned error: {response.status_code} - {response.text}")
            
    except Exception as e:
        print(f"❌ [Risk Predictor Agent] Failed: {str(e)}")
    finally:
        db.close()
