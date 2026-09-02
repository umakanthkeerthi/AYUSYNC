import sqlite3
import os

db_path = "ayusync.db"
output_file = "../database_information.md"

def dump_db():
    if not os.path.exists(db_path):
        print(f"Database not found at {db_path}")
        return
        
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Get all tables
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
    tables = [row[0] for row in cursor.fetchall() if not row[0].startswith('sqlite_') and row[0] != 'alembic_version']
    
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write("# Ayusync Database Total Information\n\n")
        f.write("This file contains a complete snapshot of all the tables and their current data in `ayusync.db`.\n\n")
        
        for table in tables:
            f.write(f"## Table: `{table}`\n\n")
            
            # Get table schema
            cursor.execute(f"PRAGMA table_info({table})")
            schema = cursor.fetchall()
            if not schema:
                f.write("*No schema found.*\n\n")
                continue
                
            columns = [col[1] for col in schema]
            
            try:
                cursor.execute(f"SELECT * FROM {table}")
                rows = cursor.fetchall()
                if not rows:
                    f.write("*Table is empty.*\n\n")
                else:
                    # Manually build markdown table
                    f.write("| " + " | ".join(columns) + " |\n")
                    f.write("| " + " | ".join(["---"] * len(columns)) + " |\n")
                    for row in rows:
                        row_strs = [str(item).replace('|', '\\|').replace('\n', ' ') for item in row]
                        f.write("| " + " | ".join(row_strs) + " |\n")
                    f.write("\n\n")
            except Exception as e:
                f.write(f"*Error reading data: {e}*\n\n")
                
    conn.close()
    print(f"Successfully dumped database information to {output_file}")

if __name__ == "__main__":
    dump_db()
