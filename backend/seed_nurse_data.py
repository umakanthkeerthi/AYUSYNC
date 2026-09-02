import sys
import os
import uuid
from datetime import datetime, timedelta, timezone

# Add backend dir to sys path to allow importing app modules
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.core.database_session import SessionLocal
from app.models.database import User, UserRole, Patient, Practitioner, Appointment, ChatThread, ChatMessage

def generate_uuid():
    return str(uuid.uuid4())

def main():
    db = SessionLocal()
    
    print("Seeding Nurse Data...")
    
    # Check if we have patients and doctors
    patients = db.query(Patient).all()
    if not patients:
        print("No patients found. Please seed patients first.")
        return
        
    doctors = db.query(Practitioner).all()
    if not doctors:
        print("No doctors found. Please seed doctors first.")
        return

    # Seed 1: Appointments
    print("Seeding Appointments...")
    now = datetime.now(timezone.utc)
    for i, p in enumerate(patients[:3]):
        # Create a scheduled appointment tomorrow
        appt = Appointment(
            id=generate_uuid(),
            patient_id=p.id,
            practitioner_id=doctors[i % len(doctors)].id,
            scheduled_time=now + timedelta(days=1, hours=i),
            status="SCHEDULED"
        )
        db.add(appt)
        
    # Seed 2: Chat Messages (Nurse Conversations)
    print("Seeding Chat Messages...")
    
    # We need a Nurse user to be participant 1
    # Let's find Nurse Clara or create one
    nurse_user = db.query(User).filter(User.full_name == "Nurse Clara").first()
    if not nurse_user:
        nurse_user = User(
            id=generate_uuid(),
            role=UserRole.NURSE,
            full_name="Nurse Clara",
            username="Ayusync_nurse",
            phone_number="+1-555-NURSE-001"
        )
        db.add(nurse_user)
        db.commit()
        db.refresh(nurse_user)
        
    # Let's create chat threads for 2 patients
    for i, p in enumerate(patients[:2]):
        patient_user = db.query(User).filter(User.id == p.user_id).first()
        if not patient_user:
            continue
            
        thread = ChatThread(
            id=generate_uuid(),
            participant_1_id=nurse_user.id,
            participant_2_id=patient_user.id
        )
        db.add(thread)
        db.commit()
        db.refresh(thread)
        
        # Message 1 (From Nurse)
        m1 = ChatMessage(
            id=generate_uuid(),
            thread_id=thread.id,
            sender_id=nurse_user.id,
            message_text=f"Hi {patient_user.full_name}, I noticed your recent risk score was elevated. Have you taken your Lisinopril today?",
            timestamp=now - timedelta(hours=2)
        )
        db.add(m1)
        
        # Message 2 (From Patient)
        m2 = ChatMessage(
            id=generate_uuid(),
            thread_id=thread.id,
            sender_id=patient_user.id,
            message_text="Hi Nurse Clara, no I forgot to take it this morning. I will take it right away.",
            timestamp=now - timedelta(hours=1, minutes=45)
        )
        db.add(m2)
        
        # Message 3 (From Nurse)
        m3 = ChatMessage(
            id=generate_uuid(),
            thread_id=thread.id,
            sender_id=nurse_user.id,
            message_text="Great, please also measure your blood pressure after 30 minutes and log it in the app.",
            timestamp=now - timedelta(minutes=30)
        )
        db.add(m3)

    db.commit()
    print("Seed complete.")
    db.close()

if __name__ == "__main__":
    main()
