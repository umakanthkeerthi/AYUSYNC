from pydantic import BaseModel, Field
from typing import Optional, Dict, Any, List
from datetime import datetime, timezone
from enum import Enum
import uuid

def generate_uuid():
    return str(uuid.uuid4())

def current_utc_time():
    return datetime.now(timezone.utc)

class EventSource(str, Enum):
    PATIENT_AGENT = "patient_agent"
    LABORATORY_AGENT = "laboratory_agent"
    NURSE_AGENT = "nurse_agent"
    MONITORING_AGENT = "monitoring_agent"
    RISK_AGENT = "risk_agent"
    ADHERENCE_AGENT = "adherence_agent"
    PLANNING_AGENT = "planning_agent"
    POLICY_ENGINE = "policy_engine"
    STATE_AGENT = "state_agent"
    PHARMACY_AGENT = "pharmacy_agent"
    EXTERNAL_SYSTEM = "external_system"

class BaseEvent(BaseModel):
    """The foundational structure every single event must have."""
    event_id: str = Field(default_factory=generate_uuid, description="Unique identifier for idempotency")
    timestamp: datetime = Field(default_factory=current_utc_time)
    patient_id: str = Field(..., description="The ID of the patient this event relates to")
    source: EventSource = Field(..., description="Which agent published this event")

# ==========================================
# 1. TELEMETRY EVENTS (telemetry.*)
# ==========================================
class VitalsPayload(BaseModel):
    heart_rate: Optional[int] = Field(None, description="Beats per minute")
    blood_pressure_systolic: Optional[int] = Field(None, description="mmHg")
    blood_pressure_diastolic: Optional[int] = Field(None, description="mmHg")
    temperature_celsius: Optional[float] = None
    oxygen_saturation: Optional[int] = Field(None, description="Percentage (0-100)")

class TelemetryEvent(BaseEvent):
    """Fired when new vitals are recorded via wearables or manual entry."""
    topic: str = Field(default="telemetry.vitals", frozen=True)
    vitals: VitalsPayload


# ==========================================
# 2. CLINICAL EVENTS (clinical.*)
# ==========================================
class ClinicalPayload(BaseModel):
    update_type: str = Field(..., description="'lab_result', 'new_diagnosis', 'medication_change'")
    data: Dict[str, Any] = Field(..., description="Structured clinical data payload (e.g., FHIR Observation resource)")
    provider_id: Optional[str] = Field(None, description="ID of the doctor/lab that generated the data")

class ClinicalEvent(BaseEvent):
    """Fired when EHR updates, lab reports, or new doctor notes arrive."""
    topic: str = Field(default="clinical.ehr_updates", frozen=True)
    clinical_data: ClinicalPayload


# ==========================================
# 3. INTERACTION EVENTS (interaction.*)
# ==========================================
class FeedbackPayload(BaseModel):
    channel: str = Field(..., description="'sms', 'voice', 'app'")
    intent: str = Field(..., description="'medication_taken', 'symptom_reported', 'ignored'")
    sentiment: Optional[str] = Field(None, description="e.g., 'positive', 'negative', 'anxious'")
    extracted_data: Dict[str, Any] = Field(default_factory=dict, description="Structured data extracted by LLM (e.g., {'pain_level': 8})")
    raw_text: Optional[str] = Field(None, description="The original transcribed text from the patient")

class InteractionEvent(BaseEvent):
    """Fired when a patient or caregiver responds to an outreach."""
    topic: str = Field(default="interaction.feedback", frozen=True)
    feedback: FeedbackPayload


# ==========================================
# 4. SYSTEM COMMANDS (system.agent_commands)
# ==========================================
class CommandPayload(BaseModel):
    target_agent: str = Field(..., description="Which actionable agent should execute this (e.g., 'patient_agent')")
    action: str = Field(..., description="The action to take (e.g., 'send_medication_reminder', 'page_doctor')")
    parameters: Dict[str, Any] = Field(default_factory=dict, description="Arguments for the action")
    urgency: str = Field(default="normal", description="'normal', 'high', 'critical'")

class AgentCommandEvent(BaseEvent):
    """Fired by the Policy Engine to instruct an Actionable Agent to do something."""
    topic: str = Field(default="system.agent_commands", frozen=True)
    command: CommandPayload


# ==========================================
# 5. INTERNAL TRIGGERS (trigger.*)
# ==========================================
class TriggerPayload(BaseModel):
    trigger_type: str = Field(..., description="e.g., 'risk_assessment', 'adherence_check'")
    reason: str = Field(..., description="Why it was triggered (e.g., 'new_high_blood_pressure_recorded')")

class TriggerEvent(BaseEvent):
    """Fired by the Monitoring Agent to wake up Thinking Agents."""
    topic: str = Field(..., description="e.g., 'trigger.risk_assessment'")
    trigger: TriggerPayload

# ==========================================
# 6. STATE CHANGES (state.updated)
# ==========================================
class StateUpdatePayload(BaseModel):
    changed_fields: List[str] = Field(..., description="List of fields updated (e.g., ['vitals', 'medications'])")
    snapshot_summary: Dict[str, Any] = Field(..., description="A lightweight summary of current patient state")

class StateChangeEvent(BaseEvent):
    """Fired by the Patient State Agent so the Monitoring Agent knows to run its rules."""
    topic: str = Field(default="state.updated", frozen=True)
    state_update: StateUpdatePayload

# ==========================================
# 7. ANALYSIS RESULTS (analysis.*)
# ==========================================
class AnalysisEvent(BaseEvent):
    """Fired by Thinking Agents (Risk, Adherence, Planning) after they finish computing."""
    topic: str = Field(..., description="'analysis.risk_scored', 'analysis.adherence_scored', 'analysis.plan_proposed'")
    data: Dict[str, Any] = Field(..., description="The calculated scores, SHAP explanations, or proposed care plans")

# ==========================================
# 8. EXECUTION RESULTS (action.completed)
# ==========================================
class ExecutionResultPayload(BaseModel):
    command_id: str = Field(..., description="The original event_id of the AgentCommandEvent that triggered this")
    status: str = Field(..., description="'success', 'failed', 'pending'")
    details: str = Field(..., description="E.g., 'SMS delivered successfully' or 'Refill denied by pharmacy'")

class ExecutionResultEvent(BaseEvent):
    """Fired by Actionable Agents to close the loop and ensure idempotency."""
    topic: str = Field(default="action.completed", frozen=True)
    result: ExecutionResultPayload
