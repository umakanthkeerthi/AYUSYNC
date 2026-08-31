import sys, os, uuid, json
from datetime import datetime
sys.path.insert(0, r"C:\AyuSync\backend")
from app.core.database_session import SessionLocal
from app.models.database import User, Patient, Organization, OrgType, EmergencyDispatch, PriorAuthorization, SystemAuditLog, UserRole, AmbulanceDriver

def seed_emergency_admin():
    db = SessionLocal()
    
    # 1. Fetch Insurance
    insurance = db.query(Organization).filter(Organization.org_type == OrgType.INSURANCE).first()
    
    # 2. Seed Ambulance Driver (if missing)
    driver_user = db.query(User).filter(User.full_name == "Ravi Kumar").first()
    if not driver_user:
        driver_user = User(
            id=str(uuid.uuid4()),
            full_name="Ravi Kumar",
            email="ravi.driver@ayusync.com",
            phone_number="+91 9876543210",
            hashed_password="hashed_password",
            role=UserRole.AMBULANCE_DRIVER
        )
        db.add(driver_user)
        db.commit()
        db.refresh(driver_user)
        
    driver = db.query(AmbulanceDriver).filter(AmbulanceDriver.user_id == driver_user.id).first()
    if not driver:
        driver = AmbulanceDriver(
            id=str(uuid.uuid4()),
            user_id=driver_user.id,
            vehicle_license_plate="TS 09 EA 1234",
            current_lat=17.4300,
            current_lng=78.4500,
            is_on_duty=True
        )
        db.add(driver)
        db.commit()
        db.refresh(driver)
        
    # 3. Fetch Patients
    patients = db.query(User).filter(User.full_name.in_([
        "Ramesh Gupta", "Vikram Chawla", "Ananya Sharma", "Varun Verma"
    ])).all()
    
    # Coordinates in Hyderabad/India (realish):
    coords = {
        "Ramesh Gupta": {"lat": 17.4156, "lng": 78.4398, "loc": "Banjara Hills, Hyderabad"},
        "Vikram Chawla": {"lat": 17.4399, "lng": 78.4983, "loc": "Secunderabad, Hyderabad"},
        "Varun Verma": {"lat": 17.4483, "lng": 78.3915, "loc": "Madhapur, Hyderabad"},
        "Ananya Sharma": {"lat": 17.3850, "lng": 78.4867, "loc": "Charminar, Hyderabad"}
    }
    
    for u in patients:
        pat = db.query(Patient).filter(Patient.user_id == u.id).first()
        if not pat:
            continue
            
        # Clean existing records
        db.query(EmergencyDispatch).filter(EmergencyDispatch.patient_id == pat.id).delete(synchronize_session=False)
        db.query(PriorAuthorization).filter(PriorAuthorization.patient_id == pat.id).delete(synchronize_session=False)
        
        # 4. Emergency Dispatches (3 records)
        if u.full_name in ["Ramesh Gupta", "Vikram Chawla", "Varun Verma"]:
            status = "EN_ROUTE" if u.full_name == "Ramesh Gupta" else "DELIVERED"
            ed = EmergencyDispatch(
                id=str(uuid.uuid4()),
                patient_id=pat.id,
                driver_id=driver.id,
                pickup_location=coords[u.full_name]["loc"],
                pickup_lat=coords[u.full_name]["lat"],
                pickup_lng=coords[u.full_name]["lng"],
                status=status
            )
            db.add(ed)
            
        # 5. Prior Authorizations
        if u.full_name == "Ramesh Gupta" and insurance:
            pa = PriorAuthorization(
                id=str(uuid.uuid4()),
                patient_id=pat.id,
                insurance_org_id=insurance.id,
                request_type="Emergency Room Visit",
                status="APPROVED"
            )
            db.add(pa)
        elif u.full_name == "Vikram Chawla" and insurance:
            pa = PriorAuthorization(
                id=str(uuid.uuid4()),
                patient_id=pat.id,
                insurance_org_id=insurance.id,
                request_type="Albuterol Inhaler Refill",
                status="PENDING"
            )
            db.add(pa)
        elif u.full_name == "Ananya Sharma" and insurance:
            pa = PriorAuthorization(
                id=str(uuid.uuid4()),
                patient_id=pat.id,
                insurance_org_id=insurance.id,
                request_type="Thyroid Panel Lab",
                status="APPROVED"
            )
            db.add(pa)

    # 6. System Audit Logs
    db.query(SystemAuditLog).delete(synchronize_session=False)
    
    logs = [
        {"action": "Generated High Severity Triage", "agent": "Risk Prediction Agent", "meta": {"patient": "Ramesh", "trigger": "Missed Lisinopril, BP Spike"}},
        {"action": "Escalated to ER", "agent": "Doctor Agent", "meta": {"doctor": "Dr. Gowrinath S.", "decision": "AUTHORIZE_ER"}},
        {"action": "Automated Refill Request", "agent": "Pharmacy Agent", "meta": {"patient": "Ananya", "medication": "Levothyroxine"}},
        {"action": "Cross-Referenced Stock Delay", "agent": "Medication Adherence Agent", "meta": {"patient": "Vikram", "medication": "Albuterol", "status": "SYSTEMIC_DELAY"}}
    ]
    
    for l in logs:
        sal = SystemAuditLog(
            id=str(uuid.uuid4()),
            action=l["action"],
            agent_source=l["agent"],
            metadata_json=json.dumps(l["meta"])
        )
        db.add(sal)

    db.commit()
    print("Emergency & Admin Tier seeded successfully!")

if __name__ == "__main__":
    seed_emergency_admin()
