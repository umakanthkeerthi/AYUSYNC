import sys
import os
import uuid
from datetime import datetime, timedelta, timezone

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.core.database_session import SessionLocal
from app.models.database import Patient, TriageQueue, Appointment, Practitioner, User

def main():
    db = SessionLocal()
    
    # 1. Fetch some patients
    patients = db.query(Patient).limit(3).all()
    if len(patients) < 3:
        print("Not enough patients to seed workflow.")
        return

    p1, p2, p3 = patients[0], patients[1], patients[2]
    
    # 2. Add MEDIUM_SEVERITY triages for digital call list (for p1 and p2)
    db.add(TriageQueue(
        id=str(uuid.uuid4()),
        patient_id=p1.id,
        severity="MEDIUM",
        status="OPEN",
        created_at=datetime.now(timezone.utc) - timedelta(hours=2)
    ))
    db.add(TriageQueue(
        id=str(uuid.uuid4()),
        patient_id=p2.id,
        severity="MEDIUM",
        status="OPEN",
        created_at=datetime.now(timezone.utc) - timedelta(minutes=45)
    ))
    
    # 3. Add HOME_VISIT appointments (for p2 and p3)
    # We need a practitioner to assign the visit. We'll find any practitioner or create a dummy one.
    practitioner = db.query(Practitioner).first()
    if not practitioner:
        print("No practitioner found. Home visits need a practitioner.")
        return
        
    db.add(Appointment(
        id=str(uuid.uuid4()),
        patient_id=p2.id,
        practitioner_id=practitioner.id,
        scheduled_time=datetime.now(timezone.utc) + timedelta(hours=24),
        status="SCHEDULED"
    ))
    
    db.add(Appointment(
        id=str(uuid.uuid4()),
        patient_id=p3.id,
        practitioner_id=practitioner.id,
        scheduled_time=datetime.now(timezone.utc) + timedelta(hours=48),
        status="SCHEDULED"
    ))

    db.commit()
    db.close()
    print("Nurse workflow data seeded successfully!")

if __name__ == "__main__":
    main()
