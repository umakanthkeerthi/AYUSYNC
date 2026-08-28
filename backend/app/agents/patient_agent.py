import json
import requests
from typing import Dict, Any

def handle_event(topic: str, payload: Dict[str, Any]):
    """
    Patient Agent (Actionable / Execution Layer)
    Listens for system.agent_commands and communicates with the patient
    via the proprietary Ayusync Mobile App (Push Notifications / In-App Messaging).
    """
    if topic != "system.agent_commands":
        return
        
    command_data = payload.get("command", {})
    if command_data.get("target_agent") != "patient_agent":
        return

    patient_id = payload.get("patient_id", "unknown")
    action = command_data.get("action", "unknown_action")
    parameters = command_data.get("parameters", {})
    urgency = command_data.get("urgency", "normal")
    
    print(f"\n📱 [Patient Agent] WAKING UP for command: {action} (Urgency: {urgency})")
    
    # Mocking the execution using the proprietary app
    if action == "request_vitals":
        delay = parameters.get("delay_hours", 0)
        print(f"📱 [Patient Agent] PUSH NOTIFICATION to Patient {patient_id} via Ayusync App: 'Please submit your vitals in {delay} hours.'")
    elif action == "send_reminder":
        message = parameters.get("message", "Don't forget your care plan tasks!")
        print(f"📱 [Patient Agent] PUSH NOTIFICATION to Patient {patient_id} via Ayusync App: '{message}'")
    elif action == "call_patient":
        phone = parameters.get("phone", "+917013250990")
        name = parameters.get("name", "Patient")
        instruction = parameters.get("agent_instruction", "Please take your medication.")
        
        print(f"📱 [Patient Agent] INITIATING AI VOICE CALL to {phone} for {name}...")
        try:
            response = requests.post(
                "https://ayusync.toplabs.in/api/call",
                json={
                    "phone": phone,
                    "name": name,
                    "call_reason": "medication_reminder",
                    "agent_instruction": instruction
                },
                headers={
                    "Content-Type": "application/json",
                    "Authorization": "Bearer ayusync_admin_123"
                },
                timeout=10
            )
            print(f"📱 [Patient Agent] CALL API RESPONSE: {response.status_code} - {response.text}")
        except Exception as e:
            print(f"📱 [Patient Agent] FAILED TO CALL: {str(e)}")
    else:
        print(f"📱 [Patient Agent] Executing action {action} with parameters {parameters} via Ayusync App.")
