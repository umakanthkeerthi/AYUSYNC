import sys, os, uuid, json
from datetime import datetime, timedelta
sys.path.insert(0, r"C:\AyuSync\backend")
from app.core.database_session import SessionLocal
from app.models.database import User, Patient, Practitioner, DoctorEscalation, Appointment, CareTask

def seed_escalations_tasks():
    db = SessionLocal()
    
    # 1. Fetch Practitioners
    dr_g = db.query(Practitioner).join(User).filter(User.full_name == "Dr. Gowrinath S.").first()
    dr_u = db.query(Practitioner).join(User).filter(User.full_name == "Dr. Uma Kanth").first()
    nurse_c = db.query(Practitioner).join(User).filter(User.full_name == "Nurse Clara").first()
    
    if not dr_g or not dr_u or not nurse_c:
        print("Error: Practitioners missing.")
        return

    # 2. Fetch Patients
    patients = db.query(User).filter(User.full_name.in_([
        "Ramesh Gupta", "Swathi Reddy", "Varun Verma", 
        "Ananya Sharma", "Vikram Chawla", "Mock Patient"
    ])).all()
    
    for u in patients:
        pat = db.query(Patient).filter(Patient.user_id == u.id).first()
        if not pat:
            continue
            
        # Clean existing records
        db.query(DoctorEscalation).filter(DoctorEscalation.patient_id == pat.id).delete(synchronize_session=False)
        db.query(Appointment).filter(Appointment.patient_id == pat.id).delete(synchronize_session=False)
        db.query(CareTask).filter(CareTask.patient_id == pat.id).delete(synchronize_session=False)
        
        # Escalations
        if u.full_name == "Ramesh Gupta":
            shap = {"features": {"Missed_BP_Meds": "+0.45", "BP_Systolic_Trend": "+0.30"}, "baseline": 0.15}
            esc = DoctorEscalation(
                id=str(uuid.uuid4()),
                patient_id=pat.id,
                doctor_id=dr_g.id,
                risk_score=92,
                shap_explanation=json.dumps(shap),
                doctor_decision="AUTHORIZE_ER"
            )
            db.add(esc)
            
        # Appointments
        if u.full_name == "Ramesh Gupta":
            app = Appointment(
                id=str(uuid.uuid4()),
                patient_id=pat.id,
                practitioner_id=nurse_c.id,
                scheduled_time=datetime.now() + timedelta(days=1),
                status="SCHEDULED"
            )
            db.add(app)
        elif u.full_name == "Vikram Chawla":
            app = Appointment(
                id=str(uuid.uuid4()),
                patient_id=pat.id,
                practitioner_id=dr_u.id,
                scheduled_time=datetime.now() - timedelta(days=1),
                status="COMPLETED"
            )
            db.add(app)
        elif u.full_name == "Swathi Reddy":
            app = Appointment(
                id=str(uuid.uuid4()),
                patient_id=pat.id,
                practitioner_id=dr_g.id,
                scheduled_time=datetime.now() + timedelta(days=7),
                status="SCHEDULED"
            )
            db.add(app)

        # Care Tasks
        if u.full_name == "Ramesh Gupta":
            ct = CareTask(
                id=str(uuid.uuid4()),
                patient_id=pat.id,
                assigned_role="CAREGIVER",
                task_description="Check Blood Pressure and log manually",
                due_time=datetime.now() + timedelta(hours=2),
                is_completed=False
            )
            db.add(ct)
        elif u.full_name == "Vikram Chawla":
            ct = CareTask(
                id=str(uuid.uuid4()),
                patient_id=pat.id,
                assigned_role="CAREGIVER",
                task_description="Check SpO2 levels after breathing treatment",
                due_time=datetime.now() - timedelta(days=1),
                is_completed=True
            )
            db.add(ct)
        elif u.full_name == "Ananya Sharma":
            ct = CareTask(
                id=str(uuid.uuid4()),
                patient_id=pat.id,
                assigned_role="NURSE",
                task_description="Review weekly thyroid symptom log",
                due_time=datetime.now() + timedelta(days=1),
                is_completed=False
            )
            db.add(ct)
        elif u.full_name == "Swathi Reddy":
            ct = CareTask(
                id=str(uuid.uuid4()),
                patient_id=pat.id,
                assigned_role="CAREGIVER",
                task_description="Ensure dark room protocol during migraine",
                due_time=datetime.now() - timedelta(days=1),
                is_completed=True
            )
            db.add(ct)
            
        print(f"Generated escalations, appointments, and tasks for {u.full_name}")

    db.commit()
    print("Final Clinical Tier seeded successfully!")

if __name__ == "__main__":
    seed_escalations_tasks()
