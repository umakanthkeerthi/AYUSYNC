import sys, os, re
from sqlalchemy import text

# 1. Update database.py
db_path = r"C:\AyuSync\backend\app\models\database.py"
with open(db_path, "r", encoding="utf-8") as f:
    content = f.read()

if "caregiver_relation =" not in content:
    content = content.replace(
        'caregiver_id = Column(String, ForeignKey("users.id"), nullable=True) # Links to a User with role CAREGIVER',
        'caregiver_id = Column(String, ForeignKey("users.id"), nullable=True) # Links to a User with role CAREGIVER\n    caregiver_relation = Column(String, nullable=True)'
    )
    with open(db_path, "w", encoding="utf-8") as f:
        f.write(content)
    print("Updated database.py")
else:
    print("database.py already has caregiver_relation")

# 2. Update database_schema.md
schema_path = r"C:\AyuSync\PROJECT DETAILS\database_schema.md"
with open(schema_path, "r", encoding="utf-8") as f:
    schema = f.read()

if "caregiver_relation" not in schema.lower():
    schema = re.sub(
        r'(\*\s+\*\*caregiver_id\*\*.*?\n)',
        r'\1*   **caregiver_relation**: String\n',
        schema,
        flags=re.IGNORECASE
    )
    with open(schema_path, "w", encoding="utf-8") as f:
        f.write(schema)
    print("Updated database_schema.md")
else:
    print("database_schema.md already has caregiver_relation")

# 3. Alter Table & Seed DB
sys.path.insert(0, r"C:\AyuSync\backend")
from app.core.database_session import engine, SessionLocal
from app.models.database import User, Patient

try:
    with engine.begin() as conn:
        conn.execute(text("ALTER TABLE patients ADD COLUMN caregiver_relation VARCHAR;"))
        print("ALTER TABLE executed.")
except Exception as e:
    print("ALTER TABLE skipped/failed:", e)

db = SessionLocal()
relations = {
    "Ramesh Gupta": "Father",
    "Swathi Reddy": "Mother",
    "Varun Verma": "Brother",
    "Ananya Sharma": "Sister",
    "Vikram Chawla": "Uncle",
    "Mock Patient": "Friend"
}

for full_name, rel in relations.items():
    user = db.query(User).filter(User.full_name == full_name).first()
    if user:
        pat = db.query(Patient).filter(Patient.user_id == user.id).first()
        if pat:
            pat.caregiver_relation = rel
            print(f"Set relation for {full_name} -> {rel}")

db.commit()
print("Done seeding relations.")
