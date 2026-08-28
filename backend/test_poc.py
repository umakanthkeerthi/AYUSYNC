import asyncio
from app.core.event_bus import event_bus
from app.models.events import TelemetryEvent, EventSource, VitalsPayload, AgentCommandEvent, CommandPayload

async def run_test():
    print("\n--- 🚀 STARTING TRACER BULLET POC (THE THINKING AGENTS) ---\n")
    
    # 1. Simulate the Patient Agent already parsing the text and sending structured vitals
    vitals_event = TelemetryEvent(
        patient_id="patient_123_mock",
        source=EventSource.STATE_AGENT,
        vitals=VitalsPayload(
            heart_rate=130, # Abnormal HR
            blood_pressure_systolic=120,
            blood_pressure_diastolic=80,
            oxygen_saturation=98
        )
    )
    
    print("\n📱 1. ACTIONABLE PATIENT AGENT PUBLISHES EXTRACTED VITALS (HR: 130)")
    # 2. Publish to the EventBus, which kicks off the massive chain reaction!
    event_bus.publish(vitals_event)
    
    print("\n--- TRACER BULLET COMPLETE ---")
    
    print("\n--- 🚀 STARTING ACTIONABLE AGENTS POC (TRACK A) ---\n")
    from app.models.events import AgentCommandEvent, CommandPayload
    
    # Simulate Care Coordinator sending a command to Patient Agent
    cmd_patient = AgentCommandEvent(
        patient_id="patient_123_mock",
        source=EventSource.POLICY_ENGINE,
        command=CommandPayload(
            target_agent="patient_agent",
            action="request_vitals",
            parameters={"delay_hours": 1},
            urgency="high"
        )
    )
    event_bus.publish(cmd_patient)
    
    # Simulate Care Coordinator sending a command to Doctor Agent
    cmd_doctor = AgentCommandEvent(
        patient_id="patient_123_mock",
        source=EventSource.POLICY_ENGINE,
        command=CommandPayload(
            target_agent="doctor_agent",
            action="page_doctor",
            parameters={"reason": "Abnormal HR of 130"},
            urgency="critical"
        )
    )
    event_bus.publish(cmd_doctor)
    
    # Simulate Care Coordinator sending a command to Nurse Agent
    cmd_nurse = AgentCommandEvent(
        patient_id="patient_123_mock",
        source=EventSource.POLICY_ENGINE,
        command=CommandPayload(
            target_agent="nurse_agent",
            action="follow_up_call",
            parameters={"reason": "missed medication and high HR"},
            urgency="high"
        )
    )
    event_bus.publish(cmd_nurse)
    
    # Simulate Care Coordinator sending a command to Caregiver Agent
    cmd_caregiver = AgentCommandEvent(
        patient_id="patient_123_mock",
        source=EventSource.POLICY_ENGINE,
        command=CommandPayload(
            target_agent="caregiver_agent",
            action="update_family",
            parameters={"message": "Ramesh's condition is being monitored closely by Dr. Smith. We will keep you updated."},
            urgency="normal"
        )
    )
    event_bus.publish(cmd_caregiver)
    
    # Simulate Care Coordinator triggering a Voice Call via Patient Agent
    cmd_voice_call = AgentCommandEvent(
        patient_id="patient_123_mock",
        source=EventSource.POLICY_ENGINE,
        command=CommandPayload(
            target_agent="patient_agent",
            action="call_patient",
            parameters={
                "phone": "+917013250990",
                "name": "Umakanth",
                "agent_instruction": "Remind the patient to take their Paracetamol tablet now."
            },
            urgency="high"
        )
    )
    event_bus.publish(cmd_voice_call)
    
    print("\n--- ACTIONABLE AGENTS POC COMPLETE ---")

    # ---------------------------------------------------------
    # TRACK B VERIFICATION: Testing the Operations & Logistics
    # ---------------------------------------------------------
    print("\n\n--- 🚀 STARTING TRACK B VERIFICATION (EXECUTION AGENTS) ---\n")
    print("💊 Triggering the Pharmacy Agent with a mock command...")
    
    pharmacy_command = AgentCommandEvent(
        patient_id="patient_123_mock",
        source=EventSource.STATE_AGENT, # Coordinator usually sends this, mocking for now
        command=CommandPayload(
            target_agent="pharmacy_agent",
            action="process_prescription",
            parameters={"medication": "Aspirin", "dosage": "81mg"},
            urgency="high"
        )
    )
    
    # We must format it correctly as the agents expect a dictionary with 'data'
    # Normally the AWSEventBus handles this translation, but in local mode we pass it
    # We will just publish it to the bus
    event_bus.publish(pharmacy_command)
    
    print("\n--- TRACK B VERIFICATION COMPLETE ---")

if __name__ == "__main__":
    asyncio.run(run_test())
