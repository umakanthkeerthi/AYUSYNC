import requests
from datetime import datetime, timezone
from app.core.database_session import SessionLocal
from app.models.database import (
    User, Patient, Practitioner, Encounter, Medication, 
    VitalSign, LabResult, Condition, ClinicalNote, UserRole
)
import uuid

API_BASE_URL = "http://13.60.9.54/api"

def get_or_create_user(db, name, role):
    # Just a helper to avoid duplicate names in our simple seed
    user = db.query(User).filter(User.full_name == name, User.role == role).first()
    if not user:
        user = User(
            id=str(uuid.uuid4()),
            full_name=name,
            role=role,
            phone_number=f"+1555{str(uuid.uuid4().int)[:6]}" # Fake phone
        )
        db.add(user)
        db.flush()
    return user

def seed_database():
    print(f"Starting seed from {API_BASE_URL}...")
    db = SessionLocal()
    
    try:
        # 1. Fetch Patients
        print("Fetching patients...")
        response = requests.get(f"{API_BASE_URL}/patients/", timeout=10)
        response.raise_for_status()
        patients_data = response.json()
        
        for p_data in patients_data:
            # Create User
            user = get_or_create_user(db, p_data.get('name', 'Unknown Patient'), UserRole.PATIENT)
            
            # Create Patient Profile
            patient = db.query(Patient).filter(Patient.user_id == user.id).first()
            if not patient:
                dob_str = p_data.get('dob', '1980-01-01')
                try:
                    dob = datetime.strptime(dob_str, "%Y-%m-%d")
                except:
                    dob = datetime(1980, 1, 1)
                    
                patient = Patient(
                    id=str(uuid.uuid4()),
                    user_id=user.id,
                    date_of_birth=dob
                )
                db.add(patient)
                db.flush()
                
            print(f"Processing clinical data for patient: {user.full_name}")
            
            # 2. Fetch Encounters
            try:
                enc_res = requests.get(f"{API_BASE_URL}/patients/{p_data['id']}/encounters", timeout=5)
                if enc_res.status_code == 200:
                    for enc in enc_res.json():
                        db.add(Encounter(
                            id=str(uuid.uuid4()),
                            patient_id=patient.id,
                            status=enc.get('status', 'finished')
                        ))
            except Exception as e:
                print(f"  Error fetching encounters: {e}")
                
            # 3. Fetch Medications
            try:
                med_res = requests.get(f"{API_BASE_URL}/patients/{p_data['id']}/medications", timeout=5)
                if med_res.status_code == 200:
                    for med in med_res.json():
                        # Assume prescribed by a dummy doctor for now
                        dummy_doc = get_or_create_user(db, "Dr. Smith (EHR System)", UserRole.DOCTOR)
                        doc_profile = db.query(Practitioner).filter(Practitioner.user_id == dummy_doc.id).first()
                        if not doc_profile:
                            doc_profile = Practitioner(id=str(uuid.uuid4()), user_id=dummy_doc.id)
                            db.add(doc_profile)
                            db.flush()
                            
                        db.add(Medication(
                            id=str(uuid.uuid4()),
                            patient_id=patient.id,
                            prescribed_by_id=doc_profile.id,
                            drug_name=med.get('name', 'Unknown Drug'),
                            dosage=med.get('dose', '1 pill'),
                            frequency=med.get('frequency', 'daily')
                        ))
            except Exception as e:
                print(f"  Error fetching medications: {e}")
                
            # 4. Fetch Conditions
            try:
                cond_res = requests.get(f"{API_BASE_URL}/patients/{p_data['id']}/conditions", timeout=5)
                if cond_res.status_code == 200:
                    for cond in cond_res.json():
                        db.add(Condition(
                            id=str(uuid.uuid4()),
                            patient_id=patient.id,
                            condition_name=cond.get('name', 'Unknown Condition'),
                            status=cond.get('status', 'active')
                        ))
            except Exception as e:
                print(f"  Error fetching conditions: {e}")
                
            # 5. Fetch Observations (Vitals)
            try:
                obs_res = requests.get(f"{API_BASE_URL}/patients/{p_data['id']}/observations", timeout=5)
                if obs_res.status_code == 200:
                    for obs in obs_res.json():
                        name = obs.get('name', '').lower()
                        val = obs.get('value', 0)
                        if 'heart rate' in name:
                            db.add(VitalSign(id=str(uuid.uuid4()), patient_id=patient.id, heart_rate=int(float(val))))
                        elif 'blood pressure' in name:
                            try:
                                sys, dia = map(int, str(val).split('/'))
                                db.add(VitalSign(id=str(uuid.uuid4()), patient_id=patient.id, blood_pressure_systolic=sys, blood_pressure_diastolic=dia))
                            except:
                                pass
            except Exception as e:
                print(f"  Error fetching observations: {e}")
        
        db.commit()
        print("\n✅ Successfully seeded the database from Demo EHR API!")
        
    except requests.exceptions.RequestException as e:
        print(f"\n❌ Network Error reaching EHR API: {e}")
        print("Please ensure the AWS server (13.60.9.54) is running and accessible.")
        db.rollback()
    except Exception as e:
        print(f"\n❌ Unexpected Error: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    seed_database()
