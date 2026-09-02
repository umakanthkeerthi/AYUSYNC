import sqlite3
import uuid
from datetime import datetime, timezone

conn = sqlite3.connect('ayusync.db')
c = conn.cursor()
c.execute("INSERT INTO users (id, role, full_name, username, hashed_password, phone_number, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)", (str(uuid.uuid4()), "PHARMACIST", "Dr. Pharmacist", "pharmacy_admin", "securepass123", "+15559990000", datetime.now(timezone.utc)))
conn.commit()
print("Pharmacist created! Username: pharmacy_admin, Password: securepass123")
