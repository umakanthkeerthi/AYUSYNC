import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), '..'))

from app.core.database_session import SessionLocal
from app.models.database import LabTest, Patient
import datetime
import json
import random

db = SessionLocal()

def seed_lab_tests():
    patients = db.query(Patient).all()
    if not patients:
        print("No patients found to associate lab tests with.")
        return

    # Clear existing if any
    db.query(LabTest).delete()
    
    test_types = [
        "Complete Blood Count", "Lipid Panel", "Thyroid Profile", 
        "Hemoglobin A1C", "Liver Function Test", "Vitamin D"
    ]
    statuses = ["Processing", "Results Ready", "Completed"]
    
    now = datetime.datetime.now()
    
    count = 0
    for p in patients:
        # Give each patient 2-4 tests
        num_tests = random.randint(2, 4)
        for _ in range(num_tests):
            t_name = random.choice(test_types)
            t_status = random.choice(statuses)
            
            # mock results json if completed
            res_json = None
            if t_status == "Completed":
                if "Hemoglobin" in t_name:
                    res_json = "6.2%"
                elif "Lipid" in t_name:
                    res_json = "180 mg/dL"
                elif "Vitamin" in t_name:
                    res_json = "18 ng/mL"
                else:
                    res_json = "Normal"
            
            test = LabTest(
                patient_id=p.id,
                test_name=t_name,
                scheduled_time=now - datetime.timedelta(hours=random.randint(1, 48)),
                status=t_status,
                results_json=res_json
            )
            db.add(test)
            count += 1
            
    db.commit()
    print(f"Successfully seeded {count} lab tests across {len(patients)} patients.")

if __name__ == "__main__":
    seed_lab_tests()
