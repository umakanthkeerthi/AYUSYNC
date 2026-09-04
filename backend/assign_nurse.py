import os
import sys

sys.path.insert(0, os.path.abspath("."))

from app.core.database_session import SessionLocal, engine
from app.models.database import Base, User, Practitioner, Patient, TriageQueue, CareTask, UserRole

def assign():
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    
    # 1. Check if Nurse Sara exists, if not create her
    nurse_user = db.query(User).filter(User.full_name == "Nurse Sara").first()
    if not nurse_user:
        nurse_user = User(
            full_name="Nurse Sara",
            username="Nurse Sara",
            role=UserRole.NURSE,
            phone_number="7013250990",
            email="sara@ayusync.com"
        )
        db.add(nurse_user)
        db.commit()
        db.refresh(nurse_user)
        print("Created User for Nurse Sara")
    
    nurse_practitioner = db.query(Practitioner).filter(Practitioner.user_id == nurse_user.id).first()
    if not nurse_practitioner:
        nurse_practitioner = Practitioner(
            user_id=nurse_user.id,
            npi_number="NURSE-SARA-001",
            specialty="Senior Staff Nurse"
        )
        db.add(nurse_practitioner)
        db.commit()
        db.refresh(nurse_practitioner)
        print("Created Practitioner profile for Nurse Sara")
        
    # 2. Assign all patients to her in TriageQueue
    patients = db.query(Patient).all()
    if not patients:
        print("No patients found in the database. Please run the seed scripts to populate data first!")
        return
        
    triage_count = 0
    for p in patients:
        # Check if they already have an open triage
        triage = db.query(TriageQueue).filter(TriageQueue.patient_id == p.id, TriageQueue.status == "OPEN").first()
        if not triage:
            from app.models.database import TriageSeverity
            triage = TriageQueue(
                patient_id=p.id,
                severity=TriageSeverity.MEDIUM,
                status="OPEN"
            )
            db.add(triage)
        
        triage.assigned_nurse_id = nurse_practitioner.id
        triage_count += 1
        
    tasks = db.query(CareTask).filter(CareTask.assigned_role == UserRole.NURSE).all()
    for task in tasks:
        # CareTask doesn't have an assigned_nurse_id, but if it did we would assign it here.
        pass
    
    db.commit()
    print(f"Assigned {triage_count} patients to Nurse Sara via TriageQueue")
    
    db.close()

if __name__ == "__main__":
    assign()
