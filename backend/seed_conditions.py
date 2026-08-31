import sys, os, uuid
from datetime import datetime, timedelta
sys.path.insert(0, r"C:\AyuSync\backend")
from app.core.database_session import SessionLocal
from app.models.database import User, Patient, Condition

def seed_conditions():
    db = SessionLocal()
    
    users = db.query(User).filter(User.full_name.in_([
        "Ramesh Gupta", "Swathi Reddy", "Varun Verma", 
        "Ananya Sharma", "Vikram Chawla", "Mock Patient"
    ])).all()
    
    for u in users:
        pat = db.query(Patient).filter(Patient.user_id == u.id).first()
        if not pat:
            continue
            
        # Delete existing conditions
        db.query(Condition).filter(Condition.patient_id == pat.id).delete(synchronize_session=False)
        
        conditions = []
        if u.full_name == "Ramesh Gupta":
            conditions.append(("Essential Hypertension", "active", 365))
            conditions.append(("Type 2 Diabetes Mellitus", "active", 800))
        elif u.full_name == "Swathi Reddy":
            conditions.append(("Migraine", "active", 200))
            conditions.append(("Gestational Diabetes", "resolved", 1500))
        elif u.full_name == "Varun Verma":
            conditions.append(("Meniscus Tear - Sports Injury", "resolved", 600))
        elif u.full_name == "Vikram Chawla":
            conditions.append(("COPD (Chronic Obstructive Pulmonary Disease)", "active", 1200))
            conditions.append(("Severe Asthma", "active", 4000))
        elif u.full_name == "Ananya Sharma":
            conditions.append(("Hypothyroidism", "active", 500))
        else:
            conditions.append(("Hyperlipidemia", "active", 100))
            
        for name, status, days_ago in conditions:
            c = Condition(
                id=str(uuid.uuid4()),
                patient_id=pat.id,
                condition_name=name,
                status=status,
                diagnosed_date=datetime.now() - timedelta(days=days_ago)
            )
            db.add(c)
            
        print(f"Generated rich conditions for {u.full_name}")

    db.commit()
    print("Conditions seeded successfully!")

if __name__ == "__main__":
    seed_conditions()
