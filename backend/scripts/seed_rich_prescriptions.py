import os
import sys

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy.orm import Session
from app.core.database_session import SessionLocal
from app.models.database import Medication

def seed():
    db = SessionLocal()
    meds = db.query(Medication).all()
    
    for i, med in enumerate(meds):
        if i % 2 == 0:
            med.drug_name = "Lisinopril"
            med.dosage = "10mg (1 Tablet)"
            med.frequency = "Morning"
        else:
            med.drug_name = "Metformin"
            med.dosage = "500mg (2 Tablets)"
            med.frequency = "Morning and Night"
            
    db.commit()
    db.close()
    print("Successfully updated prescriptions to rich format!")

if __name__ == "__main__":
    seed()
