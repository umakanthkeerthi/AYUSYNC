import sys
sys.path.insert(0, '.')
from app.core.database_session import engine
from sqlalchemy import text

with engine.connect() as conn:
    r = conn.execute(text("DELETE FROM users WHERE username = 'AYU-4833'"))
    conn.commit()
    print(f'Users deleted: {r.rowcount}')
