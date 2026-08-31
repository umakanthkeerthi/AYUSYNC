import sys, os, uuid, json
sys.path.insert(0, r"C:\AyuSync\backend")
from app.core.database_session import SessionLocal
from app.models.database import User, Patient, Organization, OrgType, Medication, PharmacyOrder, LabOrder, LabResult

def seed_logistics():
    db = SessionLocal()
    
    # 1. Fetch Organizations
    pharmacy = db.query(Organization).filter(Organization.org_type == OrgType.PHARMACY).first()
    lab = db.query(Organization).filter(Organization.org_type == OrgType.LABORATORY).first()
    
    if not pharmacy or not lab:
        print("Error: Pharmacy or Lab not found.")
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
            
        lab_order_ids = [lo.id for lo in db.query(LabOrder).filter(LabOrder.patient_id == pat.id).all()]
        if lab_order_ids:
            db.query(LabResult).filter(LabResult.lab_order_id.in_(lab_order_ids)).delete(synchronize_session=False)
        db.query(LabOrder).filter(LabOrder.patient_id == pat.id).delete(synchronize_session=False)
        
        # Seed Pharmacy Orders
        meds = db.query(Medication).filter(Medication.patient_id == pat.id).all()
        for i, med in enumerate(meds):
            status = "PICKED_UP"
            if u.full_name == "Vikram Chawla" and "Albuterol" in med.drug_name:
                status = "BACKORDERED"
            elif u.full_name == "Ramesh Gupta" and "Lisinopril" in med.drug_name:
                status = "IN_STOCK"
            elif u.full_name == "Ramesh Gupta" and "Metformin" in med.drug_name:
                status = "PICKED_UP"
            elif u.full_name == "Ananya Sharma":
                status = "REQUESTED"
            elif u.full_name == "Mock Patient":
                status = "IN_STOCK"
                
            po = PharmacyOrder(
                id=str(uuid.uuid4()),
                medication_id=med.id,
                pharmacy_id=pharmacy.id,
                status=status
            )
            db.add(po)

        # Seed Lab Orders & Results
        labs = []
        if u.full_name == "Ramesh Gupta":
            labs.append(("Lipid Panel", {"LDL_Cholesterol": "160 mg/dL", "flag": "HIGH", "notes": "High risk for cardiac event."}))
            labs.append(("HbA1c", {"HbA1c": "7.5%", "flag": "ELEVATED", "notes": "Requires strict dietary adherence."}))
        elif u.full_name == "Vikram Chawla":
            labs.append(("Arterial Blood Gas (ABG)", {"PaO2": "70 mmHg", "flag": "LOW", "notes": "Hypoxemia detected."}))
            labs.append(("CBC", {"WBC": "8,000 /uL", "flag": "CLEAN", "notes": "No signs of respiratory infection."}))
        elif u.full_name == "Swathi Reddy":
            labs.append(("Metabolic Panel", {"Glucose": "90 mg/dL", "flag": "CLEAN", "notes": "All metabolic markers perfectly within normal range."}))
            labs.append(("Vitamin B12", {"B12": "500 pg/mL", "flag": "CLEAN", "notes": "Normal levels. No deficiency."}))
        elif u.full_name == "Varun Verma":
            labs.append(("Inflammation Panel", {"CRP": "0.8 mg/L", "flag": "CLEAN", "notes": "No active inflammation post-surgery. Healing well."}))
            labs.append(("Coagulation (PT/INR)", {"INR": "1.1", "flag": "CLEAN", "notes": "Normal clotting profile."}))
        elif u.full_name == "Ananya Sharma":
            labs.append(("Thyroid Panel", {"TSH": "5.2 mIU/L", "flag": "ELEVATED", "notes": "Adjust levothyroxine dose."}))
            labs.append(("CMP", {"Calcium": "9.5 mg/dL", "flag": "CLEAN", "notes": "Normal electrolytes."}))
        else:
            labs.append(("CBC", {"Hemoglobin": "14 g/dL", "flag": "CLEAN", "notes": "Normal blood count."}))
            labs.append(("Lipid Panel", {"LDL_Cholesterol": "95 mg/dL", "flag": "CLEAN", "notes": "Excellent lipid profile."}))
            
        for test_type, results in labs:
            lo_id = str(uuid.uuid4())
            lo = LabOrder(
                id=lo_id,
                patient_id=pat.id,
                lab_id=lab.id,
                test_type=test_type,
                status="COMPLETED"
            )
            db.add(lo)
            
            lr = LabResult(
                id=str(uuid.uuid4()),
                lab_order_id=lo_id,
                results_json=results
            )
            db.add(lr)
            
        print(f"Generated pharmacy and lab orders for {u.full_name}")

    db.commit()
    print("Logistics Tier seeded successfully!")

if __name__ == "__main__":
    seed_logistics()
