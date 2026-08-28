import asyncio
from app.core.event_bus import event_bus
from app.models.events import TelemetryEvent, EventSource, VitalsPayload

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

if __name__ == "__main__":
    asyncio.run(run_test())
