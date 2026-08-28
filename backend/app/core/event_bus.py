import boto3
import json
from .config import settings
from typing import Dict, Any
from ..models.events import BaseEvent

class AWSEventBus:
    """Wrapper for AWS EventBridge."""
    
    def __init__(self):
        if settings.has_aws_credentials:
            self.client = boto3.client(
                'events',
                region_name=settings.AWS_REGION,
                aws_access_key_id=settings.AWS_ACCESS_KEY_ID,
                aws_secret_access_key=settings.AWS_SECRET_ACCESS_KEY
            )
            self.bus_name = settings.AWS_EVENTBRIDGE_BUS_NAME
            print(f"✅ Connected to AWS EventBridge Bus: {self.bus_name}")
        else:
            self.client = None
            print("⚠️ WARNING: AWS Credentials not found in .env. EventBus running in LOCAL MOCK mode.")

    def publish(self, event: BaseEvent):
        """Publishes a Pydantic Event Model to EventBridge."""
        # Convert Pydantic model to dictionary, formatting datetimes correctly
        detail_json = event.model_dump(mode="json")
        
        if self.client:
            try:
                response = self.client.put_events(
                    Entries=[
                        {
                            'Source': 'ayusync.system',
                            'DetailType': event.topic,
                            'Detail': json.dumps(detail_json),
                            'EventBusName': self.bus_name
                        }
                    ]
                )
                print(f"🚀 Published to AWS EventBridge [{event.topic}]: {response}")
                
                # For this local PoC, we manually trigger the Patient State Agent 
                # so it can save to the DB, simulating a cloud webhook.
                from ..agents.patient_state_agent import handle_event as ps_handle_event
                from ..agents.monitoring_agent import handle_event as monitor_handle_event
                from ..agents.risk_prediction_agent import handle_event as risk_handle_event
                from ..agents.care_planning_agent import handle_event as plan_handle_event
                from ..agents.care_coordinator_agent import handle_event as coord_handle_event
                from ..agents.medication_adherence_agent import handle_event as adherence_handle_event
                from ..agents.patient_agent import handle_event as patient_handle_event
                from ..agents.doctor_agent import handle_event as doctor_handle_event
                from ..agents.nurse_agent import handle_event as nurse_handle_event
                from ..agents.caregiver_agent import handle_event as caregiver_handle_event
                
                # Track B Execution Agents
                from ..agents.pharmacy_agent import handle_event as pharmacy_handle_event
                from ..agents.laboratory_agent import handle_event as lab_handle_event
                from ..agents.insurance_agent import handle_event as insurance_handle_event
                
                # Broadcast the event to all Thinking Agents (simulating an EventBridge Pub/Sub)
                ps_handle_event(event.topic, detail_json)
                monitor_handle_event(event.topic, detail_json)
                risk_handle_event(event.topic, detail_json)
                adherence_handle_event(event.topic, detail_json)
                plan_handle_event(event.topic, detail_json)
                coord_handle_event(event.topic, detail_json)
                
                # Broadcast to Actionable Agents (Track A)
                patient_handle_event(event.topic, detail_json)
                doctor_handle_event(event.topic, detail_json)
                nurse_handle_event(event.topic, detail_json)
                caregiver_handle_event(event.topic, detail_json)
                
                # Broadcast the event to Track B Execution Agents
                pharmacy_handle_event(event.topic, detail_json)
                lab_handle_event(event.topic, detail_json)
                insurance_handle_event(event.topic, detail_json)
                
                return response
            except Exception as e:
                print(f"❌ Failed to publish to AWS: {str(e)}")
                return None
        else:
            # Mock mode logic
            print(f"🚀 [LOCAL BUS MOCK] Published Event!")
            print(f"   Topic: {event.topic}")
            print(f"   Payload: {json.dumps(detail_json, indent=2)}")
            
            # Since this is a PoC, in local mode, we will directly trigger the Patient State Agent here
            # so we can prove the end-to-end flow without setting up SQS queues locally.
            from ..agents.patient_state_agent import handle_event as ps_handle_event
            from ..agents.monitoring_agent import handle_event as monitor_handle_event
            from ..agents.risk_prediction_agent import handle_event as risk_handle_event
            from ..agents.care_planning_agent import handle_event as plan_handle_event
            from ..agents.care_coordinator_agent import handle_event as coord_handle_event
            from ..agents.medication_adherence_agent import handle_event as adherence_handle_event
            from ..agents.patient_agent import handle_event as patient_handle_event
            from ..agents.doctor_agent import handle_event as doctor_handle_event
            from ..agents.nurse_agent import handle_event as nurse_handle_event
            from ..agents.caregiver_agent import handle_event as caregiver_handle_event
            
            # Track B Execution Agents
            from ..agents.pharmacy_agent import handle_event as pharmacy_handle_event
            from ..agents.laboratory_agent import handle_event as lab_handle_event
            from ..agents.insurance_agent import handle_event as insurance_handle_event
            
            # Broadcast the event to all Thinking Agents
            ps_handle_event(event.topic, detail_json)
            monitor_handle_event(event.topic, detail_json)
            risk_handle_event(event.topic, detail_json)
            adherence_handle_event(event.topic, detail_json)
            plan_handle_event(event.topic, detail_json)
            coord_handle_event(event.topic, detail_json)
            
            # Broadcast to Actionable Agents (Track A)
            patient_handle_event(event.topic, detail_json)
            doctor_handle_event(event.topic, detail_json)
            nurse_handle_event(event.topic, detail_json)
            caregiver_handle_event(event.topic, detail_json)
            
            # Broadcast the event to Track B Execution Agents
            pharmacy_handle_event(event.topic, detail_json)
            lab_handle_event(event.topic, detail_json)
            insurance_handle_event(event.topic, detail_json)
            
            return {"FailedEntryCount": 0, "Entries": [{"EventId": "mock-event-id"}]}

# Global Singleton
event_bus = AWSEventBus()
