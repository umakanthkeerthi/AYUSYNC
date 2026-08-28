import json
import requests
from typing import Dict, Any
from ..core.event_bus import event_bus
from ..core.database_session import SessionLocal
from ..models.database import VitalSign, Patient
from ..models.events import AnalysisEvent, EventSource

def handle_event(topic: str, payload: Dict[str, Any]):
    """
    Risk Predictor Agent
    Listens for trigger.risk_assessment events from the Monitoring Agent.
    """
    if topic != "trigger.risk_assessment":
        return

    print(f"🧠 [Risk Predictor Agent] Received risk assessment trigger for Patient: {payload.get('patient_id')}")
    
    patient_id = payload.get("patient_id")
    if not patient_id:
        print("❌ [Risk Predictor Agent] Missing patient_id in payload.")
        return

    # 1. Fetch latest vitals for patient from database
    db = SessionLocal()
    try:
        latest_vitals = db.query(VitalSign).filter(VitalSign.patient_id == patient_id).order_by(VitalSign.timestamp.desc()).first()
        
        if not latest_vitals:
            print("⚠️ [Risk Predictor Agent] No vitals found for patient.")
            return
            
        # 2. Format the payload for the live external ML API
        api_payload = {
            "respiratory_rate": 16.0, # Defaulting some fields not currently in DB
            "oxygen_saturation": float(latest_vitals.oxygen_saturation or 98.0),
            "o2_scale": 1,
            "systolic_bp": float(latest_vitals.blood_pressure_systolic or 120.0),
            "heart_rate": float(latest_vitals.heart_rate or 80.0),
            "temperature": 37.0,
            "consciousness": "A",
            "on_oxygen": 0
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
            clinical_reasoning = result.get("agent_assessment", {}).get("doctor_sbar_note", "No explanation provided.")
            
            # Map risk_level back to a 0-100 score for our Care Planning agent
            risk_score = 0
            if risk_level == "Medium": risk_score = 50
            if risk_level == "High": risk_score = 90
            
            print(f"🚨 [Risk Predictor Agent] Predicted Risk Level: {risk_level} ({risk_prob}%)")
            print(f"📝 [Risk Predictor Agent] AI Reasoning: {clinical_reasoning}")
            
            # 4. Broadcast the analysis event back to EventBridge
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
