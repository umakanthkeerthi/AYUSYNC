import sys
import os
import uuid
from datetime import datetime, timedelta, timezone

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.core.database_session import SessionLocal
from app.models.database import Patient, TriageQueue, CareTask

def main():
    db = SessionLocal()
    
    # 1. Fetch some patients
    patients = db.query(Patient).limit(3).all()
    if len(patients) < 3:
        print("Not enough patients to seed.")
        return

    p1, p2, p3 = patients[0], patients[1], patients[2]
    
    # 2. Add CareTasks (Assigned to NURSE)
    # Pending Task
    db.add(CareTask(
        id=str(uuid.uuid4()),
        patient_id=p1.id,
        task_description="Administer Morning Medications",
        is_completed=False,
        assigned_role="NURSE",
        due_time=datetime.now(timezone.utc) + timedelta(hours=1)
    ))
    
    # Pending Task
    db.add(CareTask(
        id=str(uuid.uuid4()),
        patient_id=p2.id,
        task_description="Check IV Drip Line",
        is_completed=False,
        assigned_role="NURSE",
        due_time=datetime.now(timezone.utc) + timedelta(minutes=30)
    ))
    
    # Completed Task
    db.add(CareTask(
        id=str(uuid.uuid4()),
        patient_id=p3.id,
        task_description="Collect Blood Sample for Labs",
        is_completed=True,
        assigned_role="NURSE",
        due_time=datetime.now(timezone.utc) - timedelta(hours=2)
    ))

    # Completed Task
    db.add(CareTask(
        id=str(uuid.uuid4()),
        patient_id=p1.id,
        task_description="Morning Vitals Check",
        is_completed=True,
        assigned_role="NURSE",
        due_time=datetime.now(timezone.utc) - timedelta(hours=4)
    ))
    
    # 3. Add HIGH Severity Triage
    db.add(TriageQueue(
        id=str(uuid.uuid4()),
        patient_id=p2.id,
        severity="HIGH",
        status="OPEN",
        created_at=datetime.now(timezone.utc) - timedelta(minutes=15)
    ))

    db.commit()
    db.close()
    print("Extra nurse data seeded successfully!")

if __name__ == "__main__":
    main()
