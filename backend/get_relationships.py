import sqlite3

def get_patient_doctor_relationships():
    conn = sqlite3.connect("ayusync.db")
    cursor = conn.cursor()
    
    query = """
    SELECT u_pat.full_name AS PatientName, u_doc.full_name AS DoctorName
    FROM patients p
    JOIN users u_pat ON p.user_id = u_pat.id
    LEFT JOIN appointments a ON a.patient_id = p.id
    LEFT JOIN practitioners pr ON a.practitioner_id = pr.id
    LEFT JOIN users u_doc ON pr.user_id = u_doc.id;
    """
    
    cursor.execute(query)
    results = cursor.fetchall()
    
    print("Patient - Doctor Relationships (from Appointments):")
    for row in results:
        patient = row[0]
        doctor = row[1] if row[1] else "None"
        print(f"Patient: {patient} -> Doctor: {doctor}")
        
    query2 = """
    SELECT u_pat.full_name AS PatientName, u_doc.full_name AS DoctorName
    FROM patients p
    JOIN users u_pat ON p.user_id = u_pat.id
    JOIN care_plans cp ON cp.patient_id = p.id
    JOIN practitioners pr ON cp.doctor_id = pr.id
    JOIN users u_doc ON pr.user_id = u_doc.id;
    """
    
    cursor.execute(query2)
    results2 = cursor.fetchall()
    
    print("\nPatient - Doctor Relationships (from Care Plans):")
    for row in results2:
        patient = row[0]
        doctor = row[1] if row[1] else "None"
        print(f"Patient: {patient} -> Doctor: {doctor}")

    conn.close()

if __name__ == "__main__":
    get_patient_doctor_relationships()
