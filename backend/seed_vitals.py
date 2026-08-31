import sys, os, uuid, random
from datetime import datetime, timedelta
sys.path.insert(0, r"C:\AyuSync\backend")
from app.core.database_session import SessionLocal
from app.models.database import User, Patient, VitalSign

def seed_vitals():
    db = SessionLocal()
    
    users = db.query(User).filter(User.full_name.in_([
        "Ramesh Gupta", "Swathi Reddy", "Varun Verma", 
        "Ananya Sharma", "Vikram Chawla", "Mock Patient"
    ])).all()
    
    for u in users:
        pat = db.query(Patient).filter(Patient.user_id == u.id).first()
        if not pat:
            continue
            
        # Delete existing vitals
        db.query(VitalSign).filter(VitalSign.patient_id == pat.id).delete(synchronize_session=False)
        
        # Generate 5 days of history
        for i in range(5):
            # i=0 is today, i=4 is 4 days ago
            timestamp = datetime.now() - timedelta(days=i, hours=random.randint(0, 5))
            
            if u.full_name == "Ramesh Gupta":
                hr = random.randint(85, 95)
                # Worsening trend over time (i=0 is today, i=4 is 4 days ago)
                # 4 days ago: ~140. Today: ~160.
                sys_base = 160 - (i * 5) 
                bp_sys = sys_base + random.randint(-5, 5)
                bp_dia = int(bp_sys * 0.6) + random.randint(-5, 5)
                o2 = random.randint(95, 98)
            elif u.full_name == "Swathi Reddy":
                hr = random.randint(70, 75)
                bp_sys = random.randint(110, 115)
                bp_dia = random.randint(70, 75)
                o2 = random.randint(98, 100)
            elif u.full_name == "Varun Verma":
                hr = random.randint(55, 60)
                bp_sys = random.randint(110, 120)
                bp_dia = random.randint(70, 80)
                o2 = random.randint(99, 100)
            elif u.full_name == "Vikram Chawla":
                hr = random.randint(90, 105)
                bp_sys = random.randint(120, 130)
                bp_dia = random.randint(80, 85)
                o2 = random.randint(88, 93) # Hypoxia
            else:
                # Ananya & Mock
                hr = random.randint(70, 80)
                bp_sys = random.randint(115, 125)
                bp_dia = random.randint(75, 80)
                o2 = random.randint(97, 99)
                
            v = VitalSign(
                id=str(uuid.uuid4()),
                patient_id=pat.id,
                timestamp=timestamp,
                heart_rate=hr,
                blood_pressure_systolic=bp_sys,
                blood_pressure_diastolic=bp_dia,
                oxygen_saturation=o2
            )
            db.add(v)
            
        print(f"Generated rich vitals for {u.full_name}")

    db.commit()
    print("Vitals seeded successfully!")

if __name__ == "__main__":
    seed_vitals()
