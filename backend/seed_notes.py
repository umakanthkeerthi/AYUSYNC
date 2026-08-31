import sys, os, uuid, urllib.request, json
from datetime import datetime, timedelta
sys.path.insert(0, r"C:\AyuSync\backend")
from app.core.database_session import SessionLocal
from app.models.database import User, Patient, ClinicalNote

def fetch_ehr_encounters(patient_name):
    try:
        # Get patient list
        req = urllib.request.Request("http://13.60.9.54/api/patients/", headers={'User-Agent': 'Mozilla/5.0'})
        res = json.loads(urllib.request.urlopen(req).read())
        ehr_id = None
        for p in res:
            if p["name"] == patient_name:
                ehr_id = p["id"]
                break
        if not ehr_id:
            return None
            
        # Get encounters
        req2 = urllib.request.Request(f"http://13.60.9.54/api/patients/{ehr_id}/encounters", headers={'User-Agent': 'Mozilla/5.0'})
        enc = json.loads(urllib.request.urlopen(req2).read())
        if enc:
            return enc[0] # Return the most recent encounter
    except Exception as e:
        print(f"EHR Fetch Error for {patient_name}: {e}")
    return None

def seed_notes():
    db = SessionLocal()
    
    users = db.query(User).filter(User.full_name.in_([
        "Ramesh Gupta", "Swathi Reddy", "Varun Verma", 
        "Ananya Sharma", "Vikram Chawla", "Mock Patient"
    ])).all()
    
    for u in users:
        pat = db.query(Patient).filter(Patient.user_id == u.id).first()
        if not pat:
            continue
            
        # Delete existing notes
        db.query(ClinicalNote).filter(ClinicalNote.patient_id == pat.id).delete(synchronize_session=False)
        
        # 1. Generate Discharge Summary from EHR
        ehr_encounter = fetch_ehr_encounters(u.full_name)
        if ehr_encounter:
            api_date = ehr_encounter.get("start_time", "Unknown Date")
            if "T" in api_date:
                api_date = api_date.split("T")[0]
            status = ehr_encounter.get("status", "finished")
            ds_text = f"Patient admitted for Inpatient care on {api_date}. Encounter status: {status}. Patient stabilized and cleared for discharge. Caregiver assumes home monitoring duties."
        else:
            ds_text = "Patient stabilized and cleared for discharge. Caregiver assumes home monitoring duties. (EHR Sync Fallback)"
            
        n1 = ClinicalNote(
            id=str(uuid.uuid4()),
            patient_id=pat.id,
            note_type="DISCHARGE SUMMARY",
            content_text=ds_text,
            timestamp=datetime.now() - timedelta(days=5)
        )
        db.add(n1)
        
        # 2. Contextual Post-Discharge Note
        if u.full_name == "Ramesh Gupta":
            ctx_type = "TELEHEALTH REVIEW"
            ctx_text = "Patient is 3 days post-discharge. Caregiver reports blood pressure remains elevated (160/100) despite medication. Scheduled urgent follow-up with cardiology."
        elif u.full_name == "Swathi Reddy":
            ctx_type = "NURSE VISIT"
            ctx_text = "Post-discharge home health visit. Patient is recovering perfectly. Caregiver is doing an excellent job maintaining medication adherence."
        elif u.full_name == "Varun Verma":
            ctx_type = "PT EVALUATION"
            ctx_text = "Post-discharge physical therapy evaluation at home. Knee mobility is improving. Caregiver instructed on daily stretching exercises."
        elif u.full_name == "Vikram Chawla":
            ctx_type = "HOME O2 ALERT"
            ctx_text = "Telehealth flag: Caregiver reported O2 saturation dropping to 88% during sleep. Pulmonologist notified to adjust home oxygen flow rate."
        elif u.full_name == "Ananya Sharma":
            ctx_type = "TELEHEALTH REVIEW"
            ctx_text = "Routine post-discharge check-in. Medication is being administered correctly by caregiver. No concerns."
        else:
            ctx_type = "TELEHEALTH REVIEW"
            ctx_text = "Post-discharge check-in. Caregiver reports patient is resting comfortably."
            
        n2 = ClinicalNote(
            id=str(uuid.uuid4()),
            patient_id=pat.id,
            note_type=ctx_type,
            content_text=ctx_text,
            timestamp=datetime.now() - timedelta(days=2)
        )
        db.add(n2)
            
        print(f"Generated notes for {u.full_name}")

    db.commit()
    print("Notes seeded successfully!")

if __name__ == "__main__":
    seed_notes()
