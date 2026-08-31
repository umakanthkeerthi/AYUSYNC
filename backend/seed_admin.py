import sys, os, uuid
from app.core.database_session import SessionLocal
from app.models.database import User, UserRole, HospitalAdmin

def seed_admin():
    db = SessionLocal()
    
    eve = db.query(User).filter(User.role == UserRole.ADMIN, User.full_name == "Admin Eve").first()
    if not eve:
        print("Admin Eve not found in the users table! Aborting.")
        return
        
    admin = db.query(HospitalAdmin).filter(HospitalAdmin.user_id == eve.id).first()
    if admin:
        admin.department = "IT Operations"
        admin.access_level = "SUPER_ADMIN"
        print("Updated Admin Eve's profile.")
    else:
        admin = HospitalAdmin(
            id=str(uuid.uuid4()),
            user_id=eve.id,
            department="IT Operations",
            access_level="SUPER_ADMIN"
        )
        db.add(admin)
        print("Created new hospital admin profile for Admin Eve.")
        
    db.commit()
    print("Admin seeded successfully!")

if __name__ == "__main__":
    seed_admin()
