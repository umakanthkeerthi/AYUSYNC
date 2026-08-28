import json
from typing import Dict, Any
from ..core.event_bus import event_bus
from ..core.config import settings
from ..models.events import AnalysisEvent, EventSource

from langchain_groq import ChatGroq
from langchain_core.messages import SystemMessage, HumanMessage

def handle_event(topic: str, payload: Dict[str, Any]):
    """
    Care Planning Agent (The Strategist)
    Listens for analysis.risk_scored. Enforces the doctor's strictly prescribed plan
    using Groq LLM to dynamically draft instructions.
    """
    if topic != "analysis.risk_scored":
        return

    print(f"📋 [Care Planning Agent] Evaluating new Risk Score for Patient: {payload.get('patient_id')}")
    
    patient_id = payload.get("patient_id")
    data = payload.get("data", {})
    risk_score = data.get("risk_score", 0)
    reasoning = data.get("reasoning", "No specific reasoning provided.")
    
    # 1. Load Doctor's strict Care Plan (Mocked for PoC)
    doctor_protocol = {
        "max_acceptable_risk": 50,
        "actions_if_exceeded": ["page_on_call_doctor", "request_new_vitals_in_1_hour"]
    }
    
    proposed_plan = []
    drafted_plan_text = ""
    
    if risk_score > doctor_protocol["max_acceptable_risk"]:
        print(f"⚠️ [Care Planning Agent] Risk Score ({risk_score}%) exceeds doctor's threshold!")
        
        print(f"📋 [Care Planning Agent] Querying Groq ({settings.GROQ_MODEL_NAME}) to draft Custom Care Plan...")
        
        try:
            llm = ChatGroq(
                api_key=settings.GROQ_API_KEY,
                model_name=settings.GROQ_MODEL_NAME,
                temperature=0.3
            )
            
            sys_msg = """You are an expert Senior Medical Officer AI for the Doc AI platform.
Your job is to read the patient's risk score and the SBAR note, and output a strict, bulleted 3-step action plan for the nursing staff.
You must adhere to the doctor's protocol: 'page_on_call_doctor' and 'request_new_vitals_in_1_hour'.
Keep your response professional, clinical, and under 5 sentences."""

            messages = [
                SystemMessage(content=sys_msg),
                HumanMessage(content=f"Risk Score: {risk_score}%\n\nClinical SBAR Reasoning:\n{reasoning}")
            ]
            
            llm_response = llm.invoke(messages)
            drafted_plan_text = llm_response.content
            print(f"📝 [Care Planning Agent] Drafted Action Plan:\n{drafted_plan_text}")
            
        except Exception as llm_err:
            print(f"⚠️ [Care Planning Agent] Groq LLM failed, using hardcoded plan. Error: {str(llm_err)}")
            drafted_plan_text = f"Doctor's protocol applied directly due to risk score {risk_score}%."
        
        proposed_plan = doctor_protocol["actions_if_exceeded"]
    else:
        print("✅ [Care Planning Agent] Patient is within safe parameters.")
        
    if proposed_plan or drafted_plan_text:
        plan_event = AnalysisEvent(
            patient_id=patient_id,
            source=EventSource.PLANNING_AGENT,
            topic="analysis.plan_proposed",
            data={
                "proposed_actions": proposed_plan,
                "reason": drafted_plan_text
            }
        )
        event_bus.publish(plan_event)
