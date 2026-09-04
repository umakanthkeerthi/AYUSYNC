import sys
import json
import uuid
from datetime import datetime, timedelta

sys.path.insert(0, '.')
from app.core.database_session import SessionLocal
from app.models.database import User, Patient, LabTest, Organization, OrgType

def seed_lab_data():
    db = SessionLocal()
    try:
        # Get or create Laboratory Organization
        lab_org = db.query(Organization).filter(Organization.org_type == OrgType.LABORATORY).first()
        if not lab_org:
            lab_org = Organization(
                id=str(uuid.uuid4()),
                org_type=OrgType.LABORATORY,
                name="AyuSync Diagnostics & Central Lab"
            )
            db.add(lab_org)
            db.flush()

        patients = db.query(Patient).all()
        if not patients:
            print("No patients found in DB.")
            return

        # Clear existing lab tests
        db.query(LabTest).delete()
        db.commit()

        now = datetime.now()

        test_templates = [
            {
                "test_name": "Complete Blood Count (CBC)",
                "status": "Results Ready",
                "offset_days": 0,
                "hour": 8,
                "minute": 30,
                "results": [
                    {"name": "Hemoglobin", "result": "14.2", "unit": "g/dL", "range": "12.0 - 15.5"},
                    {"name": "WBC Count", "result": "11.5", "unit": "10^3/uL", "range": "4.5 - 11.0"},
                    {"name": "Platelets", "result": "220", "unit": "10^3/uL", "range": "150 - 450"}
                ]
            },
            {
                "test_name": "Lipid Profile",
                "status": "Completed",
                "offset_days": -1,
                "hour": 10,
                "minute": 0,
                "results": [
                    {"name": "Total Cholesterol", "result": "210", "unit": "mg/dL", "range": "<200"},
                    {"name": "LDL Cholesterol", "result": "140", "unit": "mg/dL", "range": "<100"},
                    {"name": "HDL Cholesterol", "result": "45", "unit": "mg/dL", "range": ">40"}
                ]
            },
            {
                "test_name": "Comprehensive Metabolic Panel (CMP)",
                "status": "Processing",
                "offset_days": 0,
                "hour": 9,
                "minute": 15,
                "results": None
            },
            {
                "test_name": "Thyroid Stimulating Hormone (TSH)",
                "status": "Completed",
                "offset_days": -2,
                "hour": 11,
                "minute": 30,
                "results": [
                    {"name": "TSH", "result": "2.4", "unit": "uIU/mL", "range": "0.4 - 4.0"}
                ]
            },
            {
                "test_name": "HbA1c Diabetes Test",
                "status": "Results Ready",
                "offset_days": 0,
                "hour": 9,
                "minute": 45,
                "results": [
                    {"name": "HbA1c", "result": "7.8", "unit": "%", "range": "4.0 - 5.6"}
                ]
            },
            {
                "test_name": "Liver Function Test (LFT)",
                "status": "Completed",
                "offset_days": -3,
                "hour": 14,
                "minute": 0,
                "results": [
                    {"name": "ALT", "result": "28", "unit": "U/L", "range": "7 - 56"},
                    {"name": "AST", "result": "30", "unit": "U/L", "range": "10 - 40"}
                ]
            },
            {
                "test_name": "Urinalysis & Culture",
                "status": "Processing",
                "offset_days": 0,
                "hour": 10,
                "minute": 30,
                "results": None
            },
            {
                "test_name": "Vitamin D & B12 Panel",
                "status": "Completed",
                "offset_days": -4,
                "hour": 16,
                "minute": 15,
                "results": [
                    {"name": "Vitamin D", "result": "18.5", "unit": "ng/mL", "range": "30 - 100"},
                    {"name": "Vitamin B12", "result": "450", "unit": "pg/mL", "range": "200 - 900"}
                ]
            },
            {
                "test_name": "Arterial Blood Gas (ABG)",
                "status": "Processing",
                "offset_days": 0,
                "hour": 11,
                "minute": 0,
                "results": None
            },
            {
                "test_name": "Renal Function Test (RFT)",
                "status": "Completed",
                "offset_days": -5,
                "hour": 13,
                "minute": 45,
                "results": [
                    {"name": "Creatinine", "result": "0.9", "unit": "mg/dL", "range": "0.6 - 1.2"},
                    {"name": "BUN", "result": "14", "unit": "mg/dL", "range": "7 - 20"}
                ]
            }
        ]

        count = 0
        for i, template in enumerate(test_templates):
            patient = patients[i % len(patients)]
            user = db.query(User).filter(User.id == patient.user_id).first()
            patient_name = user.full_name if user else "Unknown"

            scheduled_dt = (now + timedelta(days=template["offset_days"])).replace(
                hour=template["hour"], minute=template["minute"], second=0, microsecond=0
            )

            lab_test = LabTest(
                id=str(uuid.uuid4()),
                patient_id=patient.id,
                test_name=template["test_name"],
                scheduled_time=scheduled_dt,
                status=template["status"],
                results_json=json.dumps(template["results"]) if template["results"] else None
            )
            db.add(lab_test)
            count += 1
            print(f"Added LabTest: '{template['test_name']}' for {patient_name} (Status: {template['status']})")

        db.commit()
        print(f"\nSuccessfully seeded {count} dummy lab tests!")
    except Exception as e:
        db.rollback()
        print(f"Error seeding lab tests: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    seed_lab_data()
