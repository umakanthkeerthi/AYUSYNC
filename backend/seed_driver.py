import sys, os, uuid
from app.core.database_session import SessionLocal
from app.models.database import User, UserRole, AmbulanceDriver

def seed_driver():
    db = SessionLocal()
    
    alex = db.query(User).filter(User.role == UserRole.AMBULANCE_DRIVER, User.full_name == "Driver Alex").first()
    if not alex:
        print("Driver Alex not found in the users table! Aborting.")
        return
        
    driver = db.query(AmbulanceDriver).filter(AmbulanceDriver.user_id == alex.id).first()
    if driver:
        driver.vehicle_license_plate = "AP09-AMB-8492"
        driver.is_on_duty = True
        driver.current_lat = 17.3850
        driver.current_lng = 78.4867
        print("Updated Driver Alex's profile.")
    else:
        driver = AmbulanceDriver(
            id=str(uuid.uuid4()),
            user_id=alex.id,
            vehicle_license_plate="AP09-AMB-8492",
            is_on_duty=True,
            current_lat=17.3850,
            current_lng=78.4867
        )
        db.add(driver)
        print("Created new ambulance driver profile for Driver Alex.")
        
    db.commit()
    print("Driver seeded successfully!")

if __name__ == "__main__":
    seed_driver()
