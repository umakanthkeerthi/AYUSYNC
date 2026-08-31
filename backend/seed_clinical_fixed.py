import sys, os, uuid, random, json
from datetime import datetime, timedelta
from app.core.database_session import SessionLocal
from app.models.database import (
    User, UserRole, Patient, VitalSign, Condition, ClinicalNote, 
    Practitioner, Encounter, CarePlan, Medication, AdherenceLog,
    TriageQueue, TriageSeverity, DoctorEscalation, Appointment,
    CareTask, PharmacyOrder, LabOrder, LabResult, EmergencyDispatch, DispatchStatus,
    ChatThread, ChatMessage, Organization, OrgType, AmbulanceDriver
)

def seed_clinical():
    print("Connecting to DB...", flush=True)
    db = SessionLocal()
    
    print("Fetching basic users...", flush=True)
    patients = db.query(User).filter(User.role == UserRole.PATIENT).all()
    cg_giri = db.query(User).filter(User.role == UserRole.CAREGIVER, User.full_name == "Giri").first()
    docs = db.query(User).filter(User.role == UserRole.DOCTOR).all()
    nur_clara = db.query(User).filter(User.role == UserRole.NURSE, User.full_name == "Nurse Clara").first()
    drv_alex = db.query(User).filter(User.role == UserRole.AMBULANCE_DRIVER, User.full_name == "Driver Alex").first()
    
    if not docs:
        print("No doctors found!")
        return

    print("Setup Organizations...", flush=True)
    pharmacy = db.query(Organization).filter(Organization.org_type == OrgType.PHARMACY).first()
    if not pharmacy:
        pharmacy = Organization(id=str(uuid.uuid4()), org_type=OrgType.PHARMACY, name="CVS Health Hub")
        db.add(pharmacy)
        
    lab = db.query(Organization).filter(Organization.org_type == OrgType.LABORATORY).first()
    if not lab:
        lab = Organization(id=str(uuid.uuid4()), org_type=OrgType.LABORATORY, name="Quest Diagnostics")
        db.add(lab)

    print("Setup Driver...", flush=True)
    driver = None
    if drv_alex:
        driver = db.query(AmbulanceDriver).filter(AmbulanceDriver.user_id == drv_alex.id).first()
        if not driver:
            driver = AmbulanceDriver(id=str(uuid.uuid4()), user_id=drv_alex.id, vehicle_license_plate="MED-8492", is_on_duty=True, current_lat=34.0522, current_lng=-118.2437)
            db.add(driver)

    print("Setup Practitioners...", flush=True)
    prac_map = {}
    for doc in docs:
        prac = db.query(Practitioner).filter(Practitioner.user_id == doc.id).first()
        if not prac:
            prac = Practitioner(id=str(uuid.uuid4()), user_id=doc.id, npi_number=f"MCI-{random.randint(1000,9999)}", specialty="Internal Medicine")
            db.add(prac)
        prac_map[doc.id] = prac
        
    nur_prac = None
    if nur_clara:
        nur_prac = db.query(Practitioner).filter(Practitioner.user_id == nur_clara.id).first()
        if not nur_prac:
            nur_prac = Practitioner(id=str(uuid.uuid4()), user_id=nur_clara.id, npi_number=f"MCI-{random.randint(1000,9999)}", specialty="Triage Nurse")
            db.add(nur_prac)

    print("Seeding Patients...", flush=True)
    for p_user in patients:
        print(f"  -> {p_user.full_name}", flush=True)
        pat = db.query(Patient).filter(Patient.user_id == p_user.id).first()
        if not pat:
            pat = Patient(id=str(uuid.uuid4()), user_id=p_user.id, caregiver_id=cg_giri.id if cg_giri else None, date_of_birth=datetime(random.randint(1950, 1995), 1, 1), blood_type="O+")
            db.add(pat)
            
        doc_user = random.choice(docs)
        doc_prac = prac_map[doc_user.id]

        for i in range(5):
            v = VitalSign(id=str(uuid.uuid4()), patient_id=pat.id, timestamp=datetime.now() - timedelta(days=i), heart_rate=80, blood_pressure_systolic=120, blood_pressure_diastolic=80, oxygen_saturation=98)
            db.add(v)
            
        db.add(Condition(id=str(uuid.uuid4()), patient_id=pat.id, condition_name="Hypertension", status="active", diagnosed_date=datetime.now() - timedelta(days=365)))
        db.add(ClinicalNote(id=str(uuid.uuid4()), patient_id=pat.id, note_type="DISCHARGE SUMMARY", content_text="Patient stabilized.", timestamp=datetime.now() - timedelta(days=1)))
        db.add(Encounter(id=str(uuid.uuid4()), patient_id=pat.id, status="discharged", discharge_date=datetime.now() - timedelta(days=1)))
        db.add(CarePlan(id=str(uuid.uuid4()), patient_id=pat.id, doctor_id=doc_prac.id, protocol_json=json.dumps({"rule": "Alert if SpO2 < 92"}), is_active=True))
        
        med = Medication(id=str(uuid.uuid4()), patient_id=pat.id, prescribed_by_id=doc_prac.id, drug_name="Metformin", dosage="10mg", frequency="Daily", is_active=True)
        db.add(med)
        
        db.add(AdherenceLog(id=str(uuid.uuid4()), patient_id=pat.id, medication_id=med.id, status="MISSED", timestamp=datetime.now() - timedelta(hours=2)))
        db.add(PharmacyOrder(id=str(uuid.uuid4()), medication_id=med.id, pharmacy_id=pharmacy.id, status="IN_STOCK"))
        
        if nur_clara and nur_prac:
            db.add(TriageQueue(id=str(uuid.uuid4()), patient_id=pat.id, assigned_nurse_id=nur_prac.id, severity=TriageSeverity.MEDIUM, status="OPEN"))
            
        db.add(DoctorEscalation(id=str(uuid.uuid4()), patient_id=pat.id, doctor_id=doc_prac.id, risk_score=85, shap_explanation="bp_systolic (142)", doctor_decision="PENDING"))
        db.add(Appointment(id=str(uuid.uuid4()), patient_id=pat.id, practitioner_id=doc_prac.id, scheduled_time=datetime.now() + timedelta(days=5), status="SCHEDULED"))
        db.add(CareTask(id=str(uuid.uuid4()), patient_id=pat.id, assigned_role=UserRole.CAREGIVER, task_description="Measure Morning Blood Sugar", due_time=datetime.now(), is_completed=True))
        
        lab_order = LabOrder(id=str(uuid.uuid4()), patient_id=pat.id, lab_id=lab.id, test_type="HbA1c", status="COMPLETED")
        db.add(lab_order)
        db.add(LabResult(id=str(uuid.uuid4()), lab_order_id=lab_order.id, results_json=json.dumps({"hba1c_level": 7.8})))
        
        if driver:
            db.add(EmergencyDispatch(id=str(uuid.uuid4()), patient_id=pat.id, driver_id=driver.id, pickup_location="123 Main St", pickup_lat=34.0530, pickup_lng=-118.2440, status=DispatchStatus.EN_ROUTE))

    print("Setup Chat...", flush=True)
    if cg_giri and nur_clara:
        thread = ChatThread(id=str(uuid.uuid4()), participant_1_id=cg_giri.id, participant_2_id=nur_clara.id, created_at=datetime.now())
        db.add(thread)
        db.add(ChatMessage(id=str(uuid.uuid4()), thread_id=thread.id, sender_id=cg_giri.id, message_text="He missed his Lisinopril this morning, is that okay?", timestamp=datetime.now()))
        
    print("Committing to DB...", flush=True)
    db.commit()
    print("DONE!")

if __name__ == "__main__":
    seed_clinical()
