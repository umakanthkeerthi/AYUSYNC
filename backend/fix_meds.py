from sqlalchemy import create_engine, text

engine = create_engine('postgresql://postgres:2631umakanth@database-1.ctgsyi80ixan.eu-north-1.rds.amazonaws.com:5432/postgres?sslmode=require')

with engine.connect() as conn:
    meds = conn.execute(text("SELECT id FROM medications WHERE patient_id = '56974909-8834-4fbd-a738-28266e9f3a62'")).fetchall()
    if len(meds) >= 2:
        conn.execute(text("UPDATE medications SET drug_name = 'Metformin', dosage = '500mg', frequency = '1 tablet twice daily' WHERE id = :id"), {"id": meds[0][0]})
        conn.execute(text("UPDATE medications SET drug_name = 'Aspirin', dosage = '81mg', frequency = '1 tablet daily' WHERE id = :id"), {"id": meds[1][0]})
        conn.commit()
        print("Updated Ramesh's medications successfully!")
    else:
        print("Could not find medications for Ramesh.")
