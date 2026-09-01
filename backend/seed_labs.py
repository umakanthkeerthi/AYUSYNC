import os
import json
from datetime import datetime, timedelta
from app.core.database_session import SessionLocal
from app.models.database import User, Patient, LabTest

db = SessionLocal()

user = db.query(User).filter(User.username == "AYU-1955").first()
if user:
    patient = db.query(Patient).filter(Patient.user_id == user.id).first()
    if patient:
        # Delete old lab tests if any
        db.query(LabTest).filter(LabTest.patient_id == patient.id).delete()
        
        now = datetime.now()
        
        lab1 = LabTest(
            patient_id=patient.id,
            test_name="Complete Blood Count (CBC)",
            scheduled_time=now.replace(hour=8, minute=30, second=0, microsecond=0),
            status="Results Ready",
            results_json=json.dumps([
                {"name": "Hemoglobin", "result": "13.5", "unit": "g/dL", "range": "12.0 - 15.5"},
                {"name": "WBC Count", "result": "6.8", "unit": "10^3/uL", "range": "4.5 - 11.0"},
                {"name": "Platelets", "result": "250", "unit": "10^3/uL", "range": "150 - 450"},
            ])
        )
        
        lab2 = LabTest(
            patient_id=patient.id,
            test_name="Lipid Profile",
            scheduled_time=now.replace(hour=8, minute=45, second=0, microsecond=0),
            status="Processing",
            results_json=None
        )
        
        lab3 = LabTest(
            patient_id=patient.id,
            test_name="HbA1c",
            scheduled_time=now - timedelta(days=77), # past date
            status="Completed",
            results_json=json.dumps([
                {"name": "HbA1c", "result": "5.6", "unit": "%", "range": "4.0 - 5.6"},
                {"name": "Estimated Avg Glucose", "result": "114", "unit": "mg/dL", "range": "70 - 126"}
            ])
        )
        
        db.add(lab1)
        db.add(lab2)
        db.add(lab3)
        db.commit()
        print("Successfully seeded lab tests for Swathi (AYU-1955).")
    else:
        print("Patient profile not found.")
else:
    print("User AYU-1955 not found.")

db.close()
