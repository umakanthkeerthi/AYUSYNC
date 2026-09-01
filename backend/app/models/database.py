from sqlalchemy import Column, Integer, String, ForeignKey, DateTime, Float, Enum, JSON, Boolean, Text
from sqlalchemy.orm import declarative_base, relationship
from datetime import datetime, timezone
import enum
import uuid

Base = declarative_base()

def generate_uuid():
    return str(uuid.uuid4())

def current_utc_time():
    return datetime.now(timezone.utc)

# ==========================================
# ENUMS
# ==========================================
class UserRole(str, enum.Enum):
    PATIENT = "PATIENT"
    CAREGIVER = "CAREGIVER"
    NURSE = "NURSE"
    DOCTOR = "DOCTOR"
    PHARMACIST = "PHARMACIST"
    LAB_TECH = "LAB_TECH"
    INSURANCE_REP = "INSURANCE_REP"
    AMBULANCE_DRIVER = "AMBULANCE_DRIVER"
    ADMIN = "ADMIN"

class OrgType(str, enum.Enum):
    PHARMACY = "PHARMACY"
    LABORATORY = "LABORATORY"
    INSURANCE = "INSURANCE"
    HOSPITAL = "HOSPITAL"

class AdherenceStatus(str, enum.Enum):
    TAKEN = "TAKEN"
    MISSED = "MISSED"
    SYSTEMIC_DELAY = "SYSTEMIC_DELAY"

class TriageSeverity(str, enum.Enum):
    LOW = "LOW"
    MEDIUM = "MEDIUM"
    HIGH = "HIGH"

class DispatchStatus(str, enum.Enum):
    PENDING = "PENDING"
    EN_ROUTE = "EN_ROUTE"
    ARRIVED = "ARRIVED"
    DELIVERED = "DELIVERED"

# ==========================================
# 1. IDENTITY & AUTH TIER
# ==========================================
class User(Base):
    __tablename__ = "users"
    id = Column(String, primary_key=True, default=generate_uuid)
    role = Column(Enum(UserRole), nullable=False)
    full_name = Column(String, nullable=False)
    username = Column(String, unique=True, nullable=True) # e.g. AYU-1234
    hashed_password = Column(String, nullable=True)
    email = Column(String, unique=True, nullable=True)
    phone_number = Column(String, unique=True, nullable=False)
    created_at = Column(DateTime, default=current_utc_time)
    
    # Relationships
    patient_profile = relationship("Patient", back_populates="user", uselist=False, foreign_keys="[Patient.user_id]")
    practitioner_profile = relationship("Practitioner", back_populates="user", uselist=False)

class AmbulanceDriver(Base):
    __tablename__ = "ambulance_drivers"
    id = Column(String, primary_key=True, default=generate_uuid)
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    vehicle_license_plate = Column(String, nullable=True)
    is_on_duty = Column(Boolean, default=False)
    current_lat = Column(Float, nullable=True)
    current_lng = Column(Float, nullable=True)
    
    user = relationship("User")

class HospitalAdmin(Base):
    __tablename__ = "hospital_admins"
    id = Column(String, primary_key=True, default=generate_uuid)
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    department = Column(String, nullable=True)
    access_level = Column(String, default="SUPER_ADMIN")
    
    user = relationship("User")

class Organization(Base):
    __tablename__ = "organizations"
    id = Column(String, primary_key=True, default=generate_uuid)
    org_type = Column(Enum(OrgType), nullable=False)
    name = Column(String, nullable=False)
    api_endpoint = Column(String, nullable=True) # For webhook routing

# ==========================================
# 2. PATIENT & CAREGIVER TIER
# ==========================================
class Patient(Base):
    __tablename__ = "patients"
    id = Column(String, primary_key=True, default=generate_uuid)
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    caregiver_id = Column(String, ForeignKey("users.id"), nullable=True) # Links to a User with role CAREGIVER
    caregiver_relation = Column(String, nullable=True)
    date_of_birth = Column(DateTime, nullable=False)
    blood_type = Column(String, nullable=True)
    
    user = relationship("User", back_populates="patient_profile", foreign_keys=[user_id])
    caregiver = relationship("User", foreign_keys=[caregiver_id])
    vitals = relationship("VitalSign", back_populates="patient", cascade="all, delete-orphan")
    care_plan = relationship("CarePlan", uselist=False, cascade="all, delete-orphan")
    tasks = relationship("CareTask", cascade="all, delete-orphan")
    lab_tests = relationship("LabTest", cascade="all, delete-orphan")
    encounters = relationship("Encounter", back_populates="patient")
    medications = relationship("Medication", back_populates="patient")

class VitalSign(Base):
    __tablename__ = "vitals"
    id = Column(String, primary_key=True, default=generate_uuid)
    patient_id = Column(String, ForeignKey("patients.id"), nullable=False)
    timestamp = Column(DateTime, default=current_utc_time, nullable=False)
    heart_rate = Column(Integer, nullable=True)
    blood_pressure_systolic = Column(Integer, nullable=True)
    blood_pressure_diastolic = Column(Integer, nullable=True)
    oxygen_saturation = Column(Integer, nullable=True)
    
    patient = relationship("Patient", back_populates="vitals")

class Condition(Base):
    __tablename__ = "conditions"
    id = Column(String, primary_key=True, default=generate_uuid)
    patient_id = Column(String, ForeignKey("patients.id"), nullable=False)
    condition_name = Column(String, nullable=False)
    status = Column(String, nullable=False)
    diagnosed_date = Column(DateTime, nullable=True)

class ClinicalNote(Base):
    __tablename__ = "clinical_notes"
    id = Column(String, primary_key=True, default=generate_uuid)
    patient_id = Column(String, ForeignKey("patients.id"), nullable=False)
    note_type = Column(String, nullable=False)
    content_text = Column(Text, nullable=False)
    timestamp = Column(DateTime, default=current_utc_time)

# ==========================================
# 3. CLINICAL TIER (DOCTORS & NURSES)
# ==========================================
class Practitioner(Base):
    __tablename__ = "practitioners"
    id = Column(String, primary_key=True, default=generate_uuid)
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    npi_number = Column(String, unique=True, nullable=True)
    specialty = Column(String, nullable=True)
    
    user = relationship("User", back_populates="practitioner_profile")

class Encounter(Base):
    __tablename__ = "encounters"
    id = Column(String, primary_key=True, default=generate_uuid)
    patient_id = Column(String, ForeignKey("patients.id"), nullable=False)
    status = Column(String, nullable=False) # e.g., 'admitted', 'discharged'
    discharge_date = Column(DateTime, nullable=True)
    
    patient = relationship("Patient", back_populates="encounters")

class Appointment(Base):
    __tablename__ = "appointments"
    id = Column(String, primary_key=True, default=generate_uuid)
    patient_id = Column(String, ForeignKey("patients.id"), nullable=False)
    practitioner_id = Column(String, ForeignKey("practitioners.id"), nullable=False)
    scheduled_time = Column(DateTime, nullable=False)
    status = Column(String, default="SCHEDULED") # SCHEDULED, COMPLETED, CANCELLED

class CareTask(Base):
    __tablename__ = "care_tasks"
    id = Column(String, primary_key=True, default=generate_uuid)
    patient_id = Column(String, ForeignKey("patients.id"), nullable=False)
    assigned_role = Column(Enum(UserRole), nullable=False) # NURSE or CAREGIVER
    task_description = Column(String, nullable=False)
    due_time = Column(DateTime, nullable=False)
    is_completed = Column(Boolean, default=False)
    
class LabTest(Base):
    __tablename__ = "lab_tests"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    patient_id = Column(String(36), ForeignKey("patients.id"))
    test_name = Column(String)
    scheduled_time = Column(DateTime)
    status = Column(String, default="Processing")  # 'Processing', 'Results Ready', 'Completed'
    results_json = Column(String, nullable=True) # JSON string of table rows: [{"name": "Hemoglobin", "result": "13.5", "unit": "g/dL", "range": "12.0 - 15.5"}, ...]

class CarePlan(Base):
    __tablename__ = "care_plans"
    id = Column(String, primary_key=True, default=generate_uuid)
    patient_id = Column(String, ForeignKey("patients.id"), nullable=False)
    doctor_id = Column(String, ForeignKey("practitioners.id"), nullable=False)
    protocol_json = Column(JSON, nullable=False) # The strict standing orders
    is_active = Column(Boolean, default=True)

class Medication(Base):
    __tablename__ = "medications"
    id = Column(String, primary_key=True, default=generate_uuid)
    patient_id = Column(String, ForeignKey("patients.id"), nullable=False)
    prescribed_by_id = Column(String, ForeignKey("practitioners.id"), nullable=False)
    drug_name = Column(String, nullable=False)
    dosage = Column(String, nullable=False)
    frequency = Column(String, nullable=False)
    is_active = Column(Boolean, default=True)
    
    patient = relationship("Patient", back_populates="medications")
    adherence_logs = relationship("AdherenceLog", back_populates="medication")

class AdherenceLog(Base):
    __tablename__ = "adherence_logs"
    id = Column(String, primary_key=True, default=generate_uuid)
    patient_id = Column(String, ForeignKey("patients.id"), nullable=False)
    medication_id = Column(String, ForeignKey("medications.id"), nullable=False)
    status = Column(Enum(AdherenceStatus), nullable=False)
    timestamp = Column(DateTime, default=current_utc_time)
    
    medication = relationship("Medication", back_populates="adherence_logs")

class TriageQueue(Base):
    __tablename__ = "triage_queues"
    id = Column(String, primary_key=True, default=generate_uuid)
    patient_id = Column(String, ForeignKey("patients.id"), nullable=False)
    assigned_nurse_id = Column(String, ForeignKey("practitioners.id"), nullable=True)
    severity = Column(Enum(TriageSeverity), nullable=False)
    status = Column(String, default="OPEN") # OPEN, CLAIMED, RESOLVED
    created_at = Column(DateTime, default=current_utc_time)

class DoctorEscalation(Base):
    __tablename__ = "doctor_escalations"
    id = Column(String, primary_key=True, default=generate_uuid)
    patient_id = Column(String, ForeignKey("patients.id"), nullable=False)
    doctor_id = Column(String, ForeignKey("practitioners.id"), nullable=False)
    risk_score = Column(Integer, nullable=False)
    shap_explanation = Column(Text, nullable=False) # No LLM hallucinations
    doctor_decision = Column(String, nullable=True) # e.g., 'AUTHORIZE_ER', 'ADJUST_MEDS'
    timestamp = Column(DateTime, default=current_utc_time)

# ==========================================
# 4. LOGISTICS TIER (PHARMACY & LABS)
# ==========================================
class PharmacyOrder(Base):
    __tablename__ = "pharmacy_orders"
    id = Column(String, primary_key=True, default=generate_uuid)
    medication_id = Column(String, ForeignKey("medications.id"), nullable=False)
    pharmacy_id = Column(String, ForeignKey("organizations.id"), nullable=False)
    status = Column(String, default="REQUESTED") # REQUESTED, IN_STOCK, BACKORDERED, PICKED_UP
    is_proactive_10_day = Column(Boolean, default=True)

class LabOrder(Base):
    __tablename__ = "lab_orders"
    id = Column(String, primary_key=True, default=generate_uuid)
    patient_id = Column(String, ForeignKey("patients.id"), nullable=False)
    lab_id = Column(String, ForeignKey("organizations.id"), nullable=False)
    test_type = Column(String, nullable=False)
    status = Column(String, default="SCHEDULED") # SCHEDULED, RESULTS_READY

class LabResult(Base):
    __tablename__ = "lab_results"
    id = Column(String, primary_key=True, default=generate_uuid)
    lab_order_id = Column(String, ForeignKey("lab_orders.id"), nullable=False)
    results_json = Column(JSON, nullable=False)
    timestamp = Column(DateTime, default=current_utc_time)

# ==========================================
# 5. EMERGENCY & ADMIN TIER
# ==========================================
class EmergencyDispatch(Base):
    __tablename__ = "emergency_dispatches"
    id = Column(String, primary_key=True, default=generate_uuid)
    patient_id = Column(String, ForeignKey("patients.id"), nullable=False)
    driver_id = Column(String, ForeignKey("ambulance_drivers.id"), nullable=True)
    pickup_location = Column(String, nullable=False)
    pickup_lat = Column(Float, nullable=True)
    pickup_lng = Column(Float, nullable=True)
    status = Column(Enum(DispatchStatus), default=DispatchStatus.PENDING)
    dispatched_at = Column(DateTime, default=current_utc_time)

class PriorAuthorization(Base):
    __tablename__ = "prior_authorizations"
    id = Column(String, primary_key=True, default=generate_uuid)
    patient_id = Column(String, ForeignKey("patients.id"), nullable=False)
    insurance_org_id = Column(String, ForeignKey("organizations.id"), nullable=False)
    request_type = Column(String, nullable=False) # e.g., 'ER_VISIT', 'EXPENSIVE_MED'
    status = Column(String, default="PENDING") # PENDING, APPROVED, DENIED

class SystemAuditLog(Base):
    __tablename__ = "system_audit_logs"
    id = Column(String, primary_key=True, default=generate_uuid)
    action = Column(String, nullable=False)
    agent_source = Column(String, nullable=False) # Which AI agent did this
    metadata_json = Column(JSON, nullable=True)
    timestamp = Column(DateTime, default=current_utc_time)

# ==========================================
# 6. COMMUNICATION TIER
# ==========================================
class ChatThread(Base):
    __tablename__ = "chat_threads"
    id = Column(String, primary_key=True, default=generate_uuid)
    participant_1_id = Column(String, ForeignKey("users.id"), nullable=False)
    participant_2_id = Column(String, ForeignKey("users.id"), nullable=False)
    created_at = Column(DateTime, default=current_utc_time)

class ChatMessage(Base):
    __tablename__ = "chat_messages"
    id = Column(String, primary_key=True, default=generate_uuid)
    thread_id = Column(String, ForeignKey("chat_threads.id"), nullable=False)
    sender_id = Column(String, ForeignKey("users.id"), nullable=False)
    message_text = Column(Text, nullable=False)
    timestamp = Column(DateTime, default=current_utc_time)
