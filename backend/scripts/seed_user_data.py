import sys
import os
import datetime
from sqlalchemy.orm import Session
from dotenv import load_dotenv

sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
load_dotenv(os.path.join(os.path.dirname(__file__), '..', '.env'))

from app.core.database_session import SessionLocal
from app.models.database import LabTest, LabOrder, Patient, User

def run():
    db = SessionLocal()
    
    # Delete existing lab tests and orders
    db.query(LabTest).delete()
    db.query(LabOrder).delete()
    
    # Get patients
    users = db.query(User).all()
    user_map = {u.full_name: u.id for u in users}
    
    patients = db.query(Patient).all()
    patient_map = {}
    for p in patients:
        for u in users:
            if p.user_id == u.id:
                patient_map[u.full_name] = p.id
    
    # User data
    completed_date = datetime.datetime(2026, 6, 16)
    
    test_data = [
        ("Ramesh Gupta", "Lipid Panel", "Completed", completed_date),
        ("Ramesh Gupta", "HbA1c", "Completed", completed_date),
        ("Swathi Reddy", "Metabolic Panel", "Completed", completed_date),
        ("Swathi Reddy", "Vitamin B12", "Completed", completed_date),
        ("Varun Verma", "Inflammation Panel", "Completed", completed_date),
        ("Varun Verma", "Coagulation (PT/INR)", "Completed", completed_date),
        ("Vikram Chawla", "Arterial Blood Gas (ABG)", "Completed", completed_date),
        ("Vikram Chawla", "CBC", "Completed", completed_date),
        ("Ananya Sharma", "Thyroid Panel", "Completed", completed_date),
        ("Ananya Sharma", "CMP", "Completed", completed_date),
        
        # Swathi's explicit tests
        ("Swathi Reddy", "Complete Blood Count (CBC)", "Results Ready", datetime.datetime(2026, 9, 1, 8, 30)),
        ("Swathi Reddy", "Lipid Profile", "Processing", datetime.datetime(2026, 9, 1, 8, 45)),
        ("Swathi Reddy", "HbA1c", "Completed", datetime.datetime(2026, 6, 16))
    ]
    
    for full_name, test_name, status, scheduled_time in test_data:
        p_id = patient_map.get(full_name)
        if not p_id:
            print(f"Patient {full_name} not found!")
            continue
            
        test = LabTest(
            patient_id=p_id,
            test_name=test_name,
            scheduled_time=scheduled_time,
            status=status,
            results_json="{}"
        )
        db.add(test)
        
    db.commit()
    db.close()
    print("Database seeded successfully with user data.")

if __name__ == "__main__":
    run()
