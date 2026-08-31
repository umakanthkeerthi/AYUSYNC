import sys, os, uuid
from datetime import datetime, timedelta
sys.path.insert(0, r"C:\AyuSync\backend")
from app.core.database_session import SessionLocal
from app.models.database import User, Patient, Practitioner, Medication, AdherenceLog, TriageQueue, PharmacyOrder

def seed_meds_triage():
    db = SessionLocal()
    
    # 1. Fetch Practitioners
    dr_g = db.query(Practitioner).join(User).filter(User.full_name == "Dr. Gowrinath S.").first()
    dr_u = db.query(Practitioner).join(User).filter(User.full_name == "Dr. Uma Kanth").first()
    nurse_c = db.query(Practitioner).join(User).filter(User.full_name == "Nurse Clara").first()
    
    if not dr_g or not dr_u or not nurse_c:
        print("Error: Practitioners missing.")
        return

    # 2. Fetch Patients
    patients = db.query(User).filter(User.full_name.in_([
        "Ramesh Gupta", "Swathi Reddy", "Varun Verma", 
        "Ananya Sharma", "Vikram Chawla", "Mock Patient"
    ])).all()
    
    for u in patients:
        pat = db.query(Patient).filter(Patient.user_id == u.id).first()
        if not pat:
            continue
            
        # Clean existing records
        med_ids = [m.id for m in db.query(Medication).filter(Medication.patient_id == pat.id).all()]
        if med_ids:
            db.query(PharmacyOrder).filter(PharmacyOrder.medication_id.in_(med_ids)).delete(synchronize_session=False)
            
        db.query(AdherenceLog).filter(AdherenceLog.patient_id == pat.id).delete(synchronize_session=False)
        db.query(TriageQueue).filter(TriageQueue.patient_id == pat.id).delete(synchronize_session=False)
        db.query(Medication).filter(Medication.patient_id == pat.id).delete(synchronize_session=False)
        
        meds = []
        if u.full_name == "Ramesh Gupta":
            meds.append(("Lisinopril 20mg", "Daily", dr_g.id, True))
            meds.append(("Metformin 500mg", "Twice Daily", dr_g.id, True))
        elif u.full_name == "Swathi Reddy":
            meds.append(("Sumatriptan 50mg", "As Needed", dr_g.id, True))
        elif u.full_name == "Varun Verma":
            meds.append(("Ibuprofen 400mg", "Daily", dr_u.id, False))
        elif u.full_name == "Vikram Chawla":
            meds.append(("Albuterol Inhaler", "As Needed", dr_u.id, True))
        elif u.full_name == "Ananya Sharma":
            meds.append(("Levothyroxine 50mcg", "Daily", dr_g.id, True))
        else:
            meds.append(("Atorvastatin 20mg", "Daily", dr_u.id, True))
            
        for drug, freq, doc_id, active in meds:
            drug_name = " ".join(drug.split(" ")[:-1]) if " " in drug else drug
            dosage = drug.split(" ")[-1] if " " in drug else "Standard"
            
            m = Medication(
                id=str(uuid.uuid4()),
                patient_id=pat.id,
                prescribed_by_id=doc_id,
                drug_name=drug_name,
                dosage=dosage,
                frequency=freq,
                is_active=active
            )
            db.add(m)
            db.flush() # flush to get the medication id in the session
            
            # Adherence Logs
            if active:
                for i in range(1, 4):
                    status = "TAKEN"
                    if u.full_name == "Ramesh Gupta" and i == 1 and m.drug_name == "Lisinopril":
                        status = "MISSED"
                    if u.full_name == "Vikram Chawla" and i == 2 and m.drug_name == "Albuterol":
                        status = "SYSTEMIC_DELAY"
                        
                    log = AdherenceLog(
                        id=str(uuid.uuid4()),
                        patient_id=pat.id,
                        medication_id=m.id,
                        status=status,
                        timestamp=datetime.now() - timedelta(days=i)
                    )
                    db.add(log)
                    
        # Triage Queues
        if u.full_name == "Ramesh Gupta":
            t = TriageQueue(
                id=str(uuid.uuid4()),
                patient_id=pat.id,
                assigned_nurse_id=nurse_c.id,
                severity="HIGH",
                status="OPEN"
            )
            db.add(t)
        elif u.full_name == "Vikram Chawla":
            t = TriageQueue(
                id=str(uuid.uuid4()),
                patient_id=pat.id,
                assigned_nurse_id=nurse_c.id,
                severity="MEDIUM",
                status="OPEN"
            )
            db.add(t)
        elif u.full_name == "Swathi Reddy":
            t = TriageQueue(
                id=str(uuid.uuid4()),
                patient_id=pat.id,
                assigned_nurse_id=nurse_c.id,
                severity="LOW",
                status="RESOLVED"
            )
            db.add(t)
            
        print(f"Generated meds, logs, and triage for {u.full_name}")

    db.commit()
    print("Meds and Triage Tier seeded successfully!")

if __name__ == "__main__":
    seed_meds_triage()
