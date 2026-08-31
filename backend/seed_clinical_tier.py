import sys, os, uuid, urllib.request, json
from datetime import datetime, timedelta
sys.path.insert(0, r"C:\AyuSync\backend")
from app.core.database_session import SessionLocal
from app.models.database import User, Patient, Practitioner, Encounter, CarePlan

def fetch_ehr_encounters(patient_name):
    try:
        req = urllib.request.Request("http://13.60.9.54/api/patients/", headers={'User-Agent': 'Mozilla/5.0'})
        res = json.loads(urllib.request.urlopen(req).read())
        ehr_id = None
        for p in res:
            if p["name"] == patient_name:
                ehr_id = p["id"]
                break
        if not ehr_id:
            return None
        req2 = urllib.request.Request(f"http://13.60.9.54/api/patients/{ehr_id}/encounters", headers={'User-Agent': 'Mozilla/5.0'})
        enc = json.loads(urllib.request.urlopen(req2).read())
        if enc:
            return enc[0]
    except Exception as e:
        print(f"EHR Fetch Error for {patient_name}: {e}")
    return None

def seed_clinical_tier():
    db = SessionLocal()
    
    # 1. PRACTITIONERS
    practitioners_info = {
        "Dr. Gowrinath S.": {"npi": "9876543210", "specialty": "Internal Medicine & Cardiology"},
        "Dr. Uma Kanth": {"npi": "9876543211", "specialty": "Pulmonology & Orthopedics"},
        "Nurse Clara": {"npi": "1234567890", "specialty": "Home Health & Post-Acute Care"}
    }
    
    practitioner_map = {}
    for name, info in practitioners_info.items():
        user = db.query(User).filter(User.full_name == name).first()
        if user:
            prac = db.query(Practitioner).filter(Practitioner.user_id == user.id).first()
            if not prac:
                prac = Practitioner(
                    id=str(uuid.uuid4()),
                    user_id=user.id,
                    npi_number=info["npi"],
                    specialty=info["specialty"]
                )
                db.add(prac)
                db.flush()
            else:
                prac.npi_number = info["npi"]
                prac.specialty = info["specialty"]
            practitioner_map[name] = prac
            print(f"Seeded Practitioner: {name}")

    if "Dr. Gowrinath S." not in practitioner_map or "Dr. Uma Kanth" not in practitioner_map:
        print("Error: Doctors not found in DB.")
        return

    # 2. ENCOUNTERS & CARE PLANS
    patients = db.query(User).filter(User.full_name.in_([
        "Ramesh Gupta", "Swathi Reddy", "Varun Verma", 
        "Ananya Sharma", "Vikram Chawla", "Mock Patient"
    ])).all()
    
    for u in patients:
        pat = db.query(Patient).filter(Patient.user_id == u.id).first()
        if not pat:
            continue
            
        # Clean existing encounters and care plans
        db.query(Encounter).filter(Encounter.patient_id == pat.id).delete(synchronize_session=False)
        db.query(CarePlan).filter(CarePlan.patient_id == pat.id).delete(synchronize_session=False)
        
        # Encounter
        ehr_encounter = fetch_ehr_encounters(u.full_name)
        if ehr_encounter and "start_time" in ehr_encounter and ehr_encounter["start_time"]:
            try:
                start_str = ehr_encounter["start_time"]
                if "." in start_str:
                    start_date = datetime.strptime(start_str, "%Y-%m-%dT%H:%M:%S.%f")
                else:
                    start_date = datetime.strptime(start_str, "%Y-%m-%dT%H:%M:%S")
                # Discharge is 2 days after start time
                discharge_date = start_date + timedelta(days=2)
            except Exception as e:
                discharge_date = datetime.now() - timedelta(days=3)
        else:
            discharge_date = datetime.now() - timedelta(days=3)
            
        enc = Encounter(
            id=str(uuid.uuid4()),
            patient_id=pat.id,
            status="discharged",
            discharge_date=discharge_date
        )
        db.add(enc)
        
        # Care Plan
        plan_is_active = True
        if u.full_name == "Ramesh Gupta":
            doc = practitioner_map["Dr. Gowrinath S."]
            protocol = {"check_frequency": "daily", "thresholds": {"bp_sys_max": 140, "bp_dia_max": 90}, "actions": ["Administer Lisinopril", "Log BP"]}
        elif u.full_name == "Vikram Chawla":
            doc = practitioner_map["Dr. Uma Kanth"]
            protocol = {"check_frequency": "twice_daily", "thresholds": {"spo2_min": 92}, "actions": ["Check O2 flow rate", "Use Rescue Inhaler"]}
        elif u.full_name == "Swathi Reddy":
            doc = practitioner_map["Dr. Gowrinath S."]
            protocol = {"check_frequency": "weekly", "thresholds": {"pain_scale_max": 4}, "actions": ["Administer Sumatriptan if needed"]}
        elif u.full_name == "Varun Verma":
            doc = practitioner_map["Dr. Uma Kanth"]
            protocol = {"check_frequency": "weekly", "thresholds": {"mobility_pain_max": 3}, "actions": ["Perform PT stretching routine"]}
            plan_is_active = False
        elif u.full_name == "Ananya Sharma":
            doc = practitioner_map["Dr. Gowrinath S."]
            protocol = {"check_frequency": "weekly", "thresholds": {"heart_rate_max": 90}, "actions": ["Administer Levothyroxine"]}
        else:
            doc = practitioner_map["Dr. Uma Kanth"]
            protocol = {"check_frequency": "daily", "thresholds": {"bp_sys_max": 130}, "actions": ["Standard monitoring"]}
            
        # In SQLModel/SQLAlchemy, if protocol_json is JSON type, assigning dict is better. We will assign json string just in case it is String, or dict if it's JSON. 
        # But we will use json.dumps() to be safe. If error occurs, we fix.
        cp = CarePlan(
            id=str(uuid.uuid4()),
            patient_id=pat.id,
            doctor_id=doc.id,
            protocol_json=json.dumps(protocol), 
            is_active=plan_is_active
        )
        db.add(cp)
        print(f"Generated encounter and care plan for {u.full_name}")

    db.commit()
    print("Clinical Tier 3 seeded successfully!")

if __name__ == "__main__":
    seed_clinical_tier()
