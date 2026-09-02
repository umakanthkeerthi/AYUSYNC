import sys
import os
import random

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.core.database_session import SessionLocal
from app.models.database import Patient

def main():
    db = SessionLocal()
    patients = db.query(Patient).all()
    
    blood_groups = ["O+", "A+", "B+", "AB+", "O-", "A-", "B-", "AB-"]
    
    for patient in patients:
        # Assign a random blood type
        patient.blood_type = random.choice(blood_groups)
        
    db.commit()
    db.close()
    print("Random blood types assigned to all patients!")

if __name__ == "__main__":
    main()
