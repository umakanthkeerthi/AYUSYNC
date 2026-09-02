import sys
import os
import uuid
from datetime import datetime, timedelta, timezone

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.core.database_session import SessionLocal
from app.models.database import Patient, VitalSign

def main():
    db = SessionLocal()
    patients = db.query(Patient).all()
    if not patients:
        print("No patients found.")
        return
        
    for i, p in enumerate(patients):
        vital = VitalSign(
            id=str(uuid.uuid4()),
            patient_id=p.id,
            heart_rate=70 + i*5,
            blood_pressure_systolic=120 + i*5,
            blood_pressure_diastolic=80 + i*2,
            timestamp=datetime.now(timezone.utc)
        )
        db.add(vital)
        
    db.commit()
    print("Vitals seeded successfully.")
    db.close()

if __name__ == "__main__":
    main()
