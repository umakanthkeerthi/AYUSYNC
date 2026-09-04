import sys
import uuid
from datetime import datetime, timezone

sys.path.insert(0, '.')
from app.core.database_session import SessionLocal
from app.models.database import (
    User, UserRole, Patient, Practitioner, Organization, OrgType, 
    Medication, PharmacyOrder
)

def seed_prescriptions():
    db = SessionLocal()
    try:
        # 1. Get or create Pharmacy Organization
        pharmacy = db.query(Organization).filter(Organization.org_type == OrgType.PHARMACY).first()
        if not pharmacy:
            pharmacy = Organization(
                id=str(uuid.uuid4()),
                org_type=OrgType.PHARMACY,
                name="AyuSync Pharmacy"
            )
            db.add(pharmacy)
            db.flush()
            print(f"Created Pharmacy Organization: {pharmacy.id}")

        # 2. Get a Doctor Practitioner for prescribed_by_id
        doctor = db.query(Practitioner).first()
        doctor_id = doctor.id if doctor else str(uuid.uuid4())

        # 3. 5 Members with Prescription Details
        dummy_members = [
            {
                "full_name": "Ramesh Gupta",
                "username": "PT-RAMESH",
                "phone": "+91 99512 00001",
                "dob": datetime(1980, 5, 15),
                "drug_name": "Lisinopril",
                "dosage": "10mg",
                "frequency": "Once Daily",
                "status": "REQUESTED"
            },
            {
                "full_name": "Swathi Reddy",
                "username": "PT-SWATHI",
                "phone": "+91 99512 00002",
                "dob": datetime(1992, 8, 20),
                "drug_name": "Metformin",
                "dosage": "500mg",
                "frequency": "Twice Daily",
                "status": "IN_STOCK"
            },
            {
                "full_name": "Varun Verma",
                "username": "PT-VARUN",
                "phone": "+91 99512 00003",
                "dob": datetime(1985, 3, 10),
                "drug_name": "Atorvastatin",
                "dosage": "20mg",
                "frequency": "Once Daily at Bedtime",
                "status": "BACKORDERED"
            },
            {
                "full_name": "Ananya Sharma",
                "username": "PT-ANANYA",
                "phone": "+91 99512 00004",
                "dob": datetime(1995, 11, 25),
                "drug_name": "Amoxicillin",
                "dosage": "500mg",
                "frequency": "Three Times Daily",
                "status": "REQUESTED"
            },
            {
                "full_name": "Vikram Chawla",
                "username": "PT-VIKRAM",
                "phone": "+91 99512 00005",
                "dob": datetime(1978, 1, 30),
                "drug_name": "Omeprazole",
                "dosage": "20mg",
                "frequency": "Once Daily before Breakfast",
                "status": "PICKED_UP"
            }
        ]

        for m in dummy_members:
            # Get or create User
            user = db.query(User).filter((User.full_name == m["full_name"]) | (User.username == m["username"])).first()
            if not user:
                user = User(
                    id=str(uuid.uuid4()),
                    role=UserRole.PATIENT,
                    full_name=m["full_name"],
                    username=m["username"],
                    phone_number=m["phone"],
                    hashed_password="password123"
                )
                db.add(user)
                db.flush()

            # Get or create Patient
            patient = db.query(Patient).filter(Patient.user_id == user.id).first()
            if not patient:
                patient = Patient(
                    id=str(uuid.uuid4()),
                    user_id=user.id,
                    date_of_birth=m["dob"]
                )
                db.add(patient)
                db.flush()

            # Create Medication
            medication = Medication(
                id=str(uuid.uuid4()),
                patient_id=patient.id,
                prescribed_by_id=doctor_id,
                drug_name=m["drug_name"],
                dosage=m["dosage"],
                frequency=m["frequency"],
                is_active=True
            )
            db.add(medication)
            db.flush()

            # Create PharmacyOrder
            order = PharmacyOrder(
                id=str(uuid.uuid4()),
                medication_id=medication.id,
                pharmacy_id=pharmacy.id,
                status=m["status"],
                is_proactive_10_day=True
            )
            db.add(order)
            db.flush()
            print(f"Added prescription for {m['full_name']}: {m['drug_name']} {m['dosage']} (Status: {m['status']})")

        db.commit()
        print("Successfully seeded 5 members' prescriptions!")
    except Exception as e:
        db.rollback()
        print(f"Error seeding prescriptions: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    seed_prescriptions()
