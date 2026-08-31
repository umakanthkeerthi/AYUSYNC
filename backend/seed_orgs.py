import sys, os, uuid
from app.core.database_session import SessionLocal
from app.models.database import Organization, OrgType

def seed_orgs():
    db = SessionLocal()
    
    orgs = [
        (OrgType.PHARMACY, "AyuSync Pharmacy", "https://ayusync.pharmacy.toplabs.in"),
        (OrgType.LABORATORY, "AyuSync Lab", "https://ayusync.lab.toplabs.in"),
        (OrgType.HOSPITAL, "AyuSync Hospital", "https://ayusync.hospital.toplabs.in"),
        (OrgType.INSURANCE, "Insurance", "https://ayusync.insurance.toplabs.in")
    ]
    
    for otype, name, endpoint in orgs:
        org = db.query(Organization).filter(Organization.org_type == otype).first()
        if org:
            org.name = name
            org.api_endpoint = endpoint
            print(f"Updated {name}")
        else:
            org = Organization(
                id=str(uuid.uuid4()),
                org_type=otype,
                name=name,
                api_endpoint=endpoint
            )
            db.add(org)
            print(f"Created {name}")
            
    db.commit()
    print("Organizations seeded successfully!")

if __name__ == "__main__":
    seed_orgs()
