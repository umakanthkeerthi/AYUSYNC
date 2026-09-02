import sys
sys.path.insert(0, '.')

from app.core.database_session import engine
from sqlalchemy import text

MOCK_PATIENT_ID = 'patient_123_mock'
MOCK_USER_ID = '60c13094-fe0b-40df-8d0f-05b282'

with engine.connect() as conn:
    print("=== Deleting Mock Patient and all associated data ===\n")

    # --- Collect IDs needed for child-of-child deletes ---
    r = conn.execute(text("SELECT id FROM medications WHERE patient_id = :pid"), {"pid": MOCK_PATIENT_ID})
    med_ids = [row[0] for row in r.fetchall()]
    print(f"medications: {len(med_ids)}")

    r = conn.execute(text("SELECT id FROM lab_orders WHERE patient_id = :pid"), {"pid": MOCK_PATIENT_ID})
    lab_order_ids = [row[0] for row in r.fetchall()]
    print(f"lab_orders:  {len(lab_order_ids)}")

    # --- Delete in strict FK dependency order ---

    # 1. adherence_logs -> medications
    for mid in med_ids:
        r = conn.execute(text("DELETE FROM adherence_logs WHERE medication_id = :id"), {"id": mid})
        print(f"  adherence_logs ({mid[:8]}) -> {r.rowcount} deleted")

    # 2. pharmacy_orders -> medications
    for mid in med_ids:
        r = conn.execute(text("DELETE FROM pharmacy_orders WHERE medication_id = :id"), {"id": mid})
        print(f"  pharmacy_orders ({mid[:8]}) -> {r.rowcount} deleted")

    # 3. lab_results -> lab_orders
    for oid in lab_order_ids:
        r = conn.execute(text("DELETE FROM lab_results WHERE lab_order_id = :id"), {"id": oid})
        print(f"  lab_results ({oid[:8]}) -> {r.rowcount} deleted")

    # 4. Now safe to delete medications & lab_orders
    r = conn.execute(text("DELETE FROM medications WHERE patient_id = :pid"), {"pid": MOCK_PATIENT_ID})
    print(f"  medications -> {r.rowcount} deleted")

    r = conn.execute(text("DELETE FROM lab_orders WHERE patient_id = :pid"), {"pid": MOCK_PATIENT_ID})
    print(f"  lab_orders -> {r.rowcount} deleted")

    # 5. Direct patient_id references
    for table in [
        "conditions",
        "vitals",
        "care_tasks",
        "care_plans",
        "encounters",
        "emergency_dispatches",
        "clinical_notes",
        "triage_queues",
        "appointments",
        "lab_tests",
        "doctor_escalations",
    ]:
        try:
            r = conn.execute(text(f"DELETE FROM {table} WHERE patient_id = :pid"), {"pid": MOCK_PATIENT_ID})
            print(f"  {table} -> {r.rowcount} deleted")
        except Exception as e:
            print(f"  {table} -> SKIP ({e})")

    # 6. patients record
    r = conn.execute(text("DELETE FROM patients WHERE id = :pid"), {"pid": MOCK_PATIENT_ID})
    print(f"  patients -> {r.rowcount} deleted")

    # 7. users record
    r = conn.execute(text("DELETE FROM users WHERE id = :uid"), {"uid": MOCK_USER_ID})
    print(f"  users -> {r.rowcount} deleted")

    conn.commit()
    print("\n✅ Mock Patient fully removed!\n")

    # Verify remaining patients
    r = conn.execute(text(
        "SELECT u.username, u.full_name FROM users u WHERE u.role = 'PATIENT' ORDER BY u.created_at"
    ))
    rows = r.fetchall()
    print(f"📋 Remaining patients ({len(rows)}):")
    for row in rows:
        print(f"  {row[0]}  -  {row[1]}")
