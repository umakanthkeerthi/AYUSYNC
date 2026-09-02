import sys
sys.path.insert(0, '.')

from app.core.database_session import engine
from sqlalchemy import text

with engine.connect() as conn:
    result = conn.execute(text(
        "SELECT column_name FROM information_schema.columns "
        "WHERE table_name='patients' AND column_name='caregiver_relation'"
    ))
    exists = result.fetchone()
    if exists:
        print('Column already exists - no change needed.')
    else:
        conn.execute(text('ALTER TABLE patients ADD COLUMN caregiver_relation VARCHAR'))
        conn.commit()
        print('FIXED: caregiver_relation column added. Login should work now!')
