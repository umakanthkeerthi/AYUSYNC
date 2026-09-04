import asyncio
import os
import sys

# Ensure backend folder is in path to allow imports
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.core.config import settings
from app.models.database import (
    User, Patient, Practitioner, VitalSign, Condition, ClinicalNote,
    Encounter, Appointment, CareTask, LabTest, CarePlan, Medication,
    AdherenceLog, TriageQueue, DoctorEscalation, PharmacyOrder, LabOrder,
    LabResult, EmergencyDispatch, PriorAuthorization, SystemAuditLog,
    ChatThread, ChatMessage, AmbulanceDriver, HospitalAdmin, Organization,
    UserRole
)

def main():
    print("Connecting to database...")
    db_url = settings.DATABASE_URL.replace("postgresql://", "postgresql+psycopg2://")
    engine = create_engine(db_url)
    Session = sessionmaker(bind=engine)
    session = Session()

    try:
        print("Starting massive database cleanup...")

        # 1. Delete standalone logs & communications
        session.query(ChatMessage).delete()
        session.query(ChatThread).delete()
        session.query(SystemAuditLog).delete()

        # 2. Delete logistics & emergency data
        session.query(EmergencyDispatch).delete()
        session.query(AmbulanceDriver).delete()
        session.query(PriorAuthorization).delete()
        session.query(LabResult).delete()
        session.query(LabOrder).delete()
        session.query(PharmacyOrder).delete()

        # 3. Delete clinical records (must be done before deleting Patients)
        session.query(DoctorEscalation).delete()
        session.query(TriageQueue).delete()
        session.query(AdherenceLog).delete()
        session.query(Medication).delete()
        session.query(CarePlan).delete()
        session.query(LabTest).delete()
        session.query(CareTask).delete()
        session.query(Appointment).delete()
        session.query(Encounter).delete()
        session.query(ClinicalNote).delete()
        session.query(Condition).delete()
        session.query(VitalSign).delete()

        # 4. Delete Patients
        session.query(Patient).delete()

        # 5. Delete other roles and organizations
        session.query(HospitalAdmin).delete()
        session.query(Organization).delete()

        # 6. Delete Practitioners who are NOT Doctors or Nurses (just in case of dirty data)
        valid_roles = [UserRole.DOCTOR, UserRole.NURSE]
        invalid_practitioners = session.query(Practitioner).join(User).filter(User.role.notin_(valid_roles)).all()
        for p in invalid_practitioners:
            session.delete(p)
            
        # 7. Delete Users who are NOT Doctors or Nurses
        users_to_delete = session.query(User).filter(User.role.notin_(valid_roles)).all()
        deleted_user_count = len(users_to_delete)
        for u in users_to_delete:
            session.delete(u)

        # Commit all deletions
        session.commit()
        
        # Count remaining users to verify
        remaining_doctors = session.query(User).filter(User.role == UserRole.DOCTOR).count()
        remaining_nurses = session.query(User).filter(User.role == UserRole.NURSE).count()

        print(f"Successfully wiped patient data and {deleted_user_count} non-medical users.")
        print(f"Preserved {remaining_doctors} Doctors and {remaining_nurses} Nurses.")

    except Exception as e:
        session.rollback()
        print(f"Error during cleanup: {str(e)}")
    finally:
        session.close()

if __name__ == "__main__":
    main()
