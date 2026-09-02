import os
import sys
import uuid
import random
from datetime import datetime, timezone
from sqlalchemy.orm import Session

# Setup python path so we can import from app
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.core.database_session import SessionLocal
from app.models.database import PharmacyOrder, Medication, Organization, OrgType

def seed_pharmacy_orders():
    db = SessionLocal()
    try:
        # Check if we have a pharmacy organization
        pharmacy_org = db.query(Organization).filter(Organization.org_type == OrgType.PHARMACY).first()
        if not pharmacy_org:
            pharmacy_org = Organization(
                id=str(uuid.uuid4()),
                org_type=OrgType.PHARMACY,
                name="AyuSync Central Pharmacy"
            )
            db.add(pharmacy_org)
            db.commit()
            db.refresh(pharmacy_org)

        # Clear existing orders
        db.query(PharmacyOrder).delete()
        
        # Get all medications
        medications = db.query(Medication).all()
        if not medications:
            print("No medications found. Run seed_risk_scores.py or seed_doctor_patients.py first.")
            return

        # Create orders for some medications
        statuses = ["REQUESTED", "IN_STOCK", "BACKORDERED", "PICKED_UP"]
        orders_created = 0
        
        for med in medications[:10]: # Pick the first 10 meds to create orders
            order = PharmacyOrder(
                id=str(uuid.uuid4()),
                medication_id=med.id,
                pharmacy_id=pharmacy_org.id,
                status=random.choice(statuses),
                is_proactive_10_day=random.choice([True, False])
            )
            db.add(order)
            orders_created += 1

        db.commit()
        print(f"Successfully seeded {orders_created} dynamic pharmacy orders into the database!")

    except Exception as e:
        print(f"Error seeding pharmacy orders: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    seed_pharmacy_orders()
