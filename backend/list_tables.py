import sqlite3

def list_tables():
    conn = sqlite3.connect("ayusync.db")
    cursor = conn.cursor()
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
    tables = cursor.fetchall()
    print("Tables in ayusync.db:")
    for table in tables:
        print(table[0])
        
        # Also print some rows for patients, practitioners, care_plans
        if table[0] in ['users', 'patients', 'practitioners', 'care_plans', 'medications', 'doctor_escalations']:
            cursor.execute(f"SELECT * FROM {table[0]} LIMIT 2")
            print(f"  Rows in {table[0]}: {cursor.fetchall()}")
            
    conn.close()

if __name__ == "__main__":
    list_tables()
