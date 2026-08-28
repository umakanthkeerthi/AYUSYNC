import json
from typing import Dict, Any
from ..core.event_bus import event_bus
from ..core.config import settings
from ..models.events import AgentCommandEvent, EventSource, CommandPayload

from langchain_groq import ChatGroq
from langchain_core.messages import SystemMessage, HumanMessage

def handle_event(topic: str, payload: Dict[str, Any]):
    """
    Care Coordinator Agent (The Scheduler)
    Listens for analysis.plan_proposed. Translates tactical plans into specific Agent Commands
    using Groq LLM to intelligently map reasoning to commands.
    """
    if topic != "analysis.plan_proposed":
        return

    print(f"🗓️ [Care Coordinator Agent] Received proposed plan for Patient: {payload.get('patient_id')}")
    
    patient_id = payload.get("patient_id")
    data = payload.get("data", {})
    proposed_actions = data.get("proposed_actions", [])
    reason = data.get("reason", "")
    
    if not proposed_actions and not reason:
        return
        
    print(f"⚙️ [Care Coordinator Agent] Translating plan into System Commands...")
    
    try:
        llm = ChatGroq(
            api_key=settings.GROQ_API_KEY,
            model_name=settings.GROQ_MODEL_NAME,
            temperature=0.1
        )
        
        sys_msg = """You are the 'Care Coordinator Agent' for a Hospital AI System.
Your job is to read the 'Proposed Care Plan' and 'Reasoning', and decide exactly which system command to trigger.
Output your decision strictly as a JSON list of command objects. Example format:
[
  {
    "target_agent": "patient_agent", 
    "action": "request_vitals", 
    "parameters": {"delay_hours": 1}, 
    "urgency": "high"
  }
]
Valid target agents: 'doctor_agent', 'patient_agent', 'nurse_agent', 'pharmacy_agent'."""

        messages = [
            SystemMessage(content=sys_msg),
            HumanMessage(content=f"Proposed Actions (Hardcoded array if any): {proposed_actions}\nDrafted Care Plan / Reason: {reason}")
        ]
        
        print(f"🧠 [Care Coordinator Agent] Querying Groq ({settings.GROQ_MODEL_NAME}) for Final Decision...")
        llm_response = llm.invoke(messages)
        
        # Clean up JSON if LLM added markdown formatting
        content = llm_response.content.strip()
        if content.startswith("```json"):
            content = content[7:-3].strip()
        elif content.startswith("```"):
            content = content[3:-3].strip()
            
        commands = json.loads(content)
        print(f"🤖 [Care Coordinator Agent] Groq decided to execute {len(commands)} commands!")
        
        for cmd_data in commands:
            cmd_event = AgentCommandEvent(
                patient_id=patient_id,
                source=EventSource.POLICY_ENGINE,
                command=CommandPayload(
                    target_agent=cmd_data.get("target_agent", "unknown"),
                    action=cmd_data.get("action", "unknown"),
                    parameters=cmd_data.get("parameters", {}),
                    urgency=cmd_data.get("urgency", "normal")
                )
            )
            event_bus.publish(cmd_event)
            print(f"🚀 [Care Coordinator Agent] Scheduled command: {cmd_data.get('action')} -> {cmd_data.get('target_agent')} ({cmd_data.get('urgency')})")
            
    except Exception as llm_err:
        print(f"⚠️ [Care Coordinator Agent] Groq LLM parsing failed. Falling back to default hardcoded logic. Error: {str(llm_err)}")
        
        # Fallback to old logic
        for action in proposed_actions:
            if action == "page_on_call_doctor":
                cmd = AgentCommandEvent(
                    patient_id=patient_id,
                    source=EventSource.POLICY_ENGINE,
                    command=CommandPayload(
                        target_agent="doctor_agent",
                        action="page_doctor",
                        parameters={"reason": reason},
                        urgency="critical"
                    )
                )
                event_bus.publish(cmd)
                print(f"🚀 [Care Coordinator Agent] Scheduled command: {action} -> doctor_agent")
            
            elif action == "request_new_vitals_in_1_hour":
                cmd = AgentCommandEvent(
                    patient_id=patient_id,
                    source=EventSource.POLICY_ENGINE,
                    command=CommandPayload(
                        target_agent="patient_agent",
                        action="request_vitals",
                        parameters={"delay_hours": 1},
                        urgency="high"
                    )
                )
                event_bus.publish(cmd)
                print(f"🚀 [Care Coordinator Agent] Scheduled command: {action} -> patient_agent")
