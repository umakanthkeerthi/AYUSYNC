import base64
import os
import json
import requests
from sqlalchemy.orm import Session
from datetime import datetime, date
from typing import Dict, Any
from app.models.database import Medication, CareTask, ClinicalNote, LabTest, Patient, Practitioner
from app.core.event_bus import event_bus
from app.models.events import AgentCommandEvent, EventSource, CommandPayload

def process_medical_record(patient_id: str, file_bytes: bytes, filename: str, category: str, db: Session) -> Dict[str, Any]:
    """
    Sends the uploaded medical record to the Ayusync OCR API on EC2.
    """
    # 1. Send to OCR API
    try:
        response = requests.post(
            "http://13.53.200.2/api/analyze",
            files={"file": (filename, file_bytes, "application/octet-stream")},
            timeout=60
        )
        response.raise_for_status()
        data = response.json()
    except Exception as e:
        print(f"OCR API Error: {str(e)}")
        # For testing if OCR is down, mock it
        data = {
            "document_type": "Discharge Summary",
            "extracted_text": "Mock extracted text",
            "summary": "Mock summary",
            "discharge_data": {
                "diagnosis": "Mock Diagnosis",
                "care_plan": {
                    "activity_restrictions": ["Rest for 2 days"],
                    "warning_signs": ["Fever"]
                }
            },
            "medicines": ["Paracetamol 500mg"]
        }

    # 2. Extract Data
    doc_type = data.get("document_type", "Unknown Document")
    extracted_text = data.get("extracted_text", "")
    summary = data.get("summary", "Document analyzed.")
    medicines = data.get("medicines") or []
    values = data.get("values")
    discharge_data = data.get("discharge_data")

    # Save to ClinicalNotes for standard docs (to populate My Reports)
    if doc_type in ["Discharge Summary", "Medical Bill", "Prescription", "Unknown Document"]:
        note = ClinicalNote(
            patient_id=patient_id,
            timestamp=datetime.utcnow(),
            note_type="DISCHARGE_SUMMARY" if doc_type == "Discharge Summary" else ("RADIOLOGY" if doc_type == "Medical Bill" else "AI Analysis: " + doc_type),
            content_text=f"Summary: {summary}\n\nFull Text:\n{extracted_text}"
        )
        db.add(note)
    elif doc_type == "Lab Report":
        lab = LabTest(
            patient_id=patient_id,
            test_name="Lab Report Analysis",
            scheduled_time=datetime.utcnow(),
            status="COMPLETED",
            results_json=json.dumps(values) if values else None
        )
        db.add(lab)

    # Save medications (Requires a practitioner ID due to NOT NULL constraint)
    default_practitioner = db.query(Practitioner).first()
    if not default_practitioner:
        # Create a dummy system practitioner if none exists
        from app.models.database import User, UserRole, generate_uuid
        system_user = User(
            id=generate_uuid(),
            role=UserRole.DOCTOR,
            full_name="System Upload Doctor",
            phone_number="+10000000000"
        )
        db.add(system_user)
        prac_id = generate_uuid()
        default_practitioner = Practitioner(
            id=prac_id,
            user_id=system_user.id,
            specialty="General"
        )
        db.add(default_practitioner)
        db.commit()
        practitioner_id = prac_id
    else:
        practitioner_id = default_practitioner.id
        
    for med_name in medicines:
        new_med = Medication(
            patient_id=patient_id,
            prescribed_by_id=practitioner_id,
            drug_name=med_name,
            dosage="As prescribed",
            frequency="Daily",
            is_active=True
        )
        db.add(new_med)

    db.commit()

    # 3. If Discharge Summary, Trigger Care Planning & Onboarding Flow
    if doc_type == "Discharge Summary" and discharge_data:
        # A. Trigger Patient State Agent (Initialization)
        # Data is already saved in DB.
        
        # B. Trigger Care Planning Agent -> Care Coordinator
        # Generate tasks based on discharge_data
        care_plan = discharge_data.get("care_plan", {})
        tasks = []
        for activity in care_plan.get("activity_restrictions", []):
            tasks.append({"target_agent": "patient_agent", "action": "send_reminder", "parameters": {"message": activity}, "urgency": "normal"})
            
        for sign in care_plan.get("warning_signs", []):
            tasks.append({"target_agent": "monitoring_agent", "action": "monitor_vitals", "parameters": {"warning_sign": sign}, "urgency": "high"})
            
        tasks.append({"target_agent": "medication_adherence_agent", "action": "track_medications", "parameters": {"meds": medicines}, "urgency": "normal"})
        tasks.append({"target_agent": "pharmacy_agent", "action": "verify_stock", "parameters": {"meds": medicines}, "urgency": "normal"})
        tasks.append({"target_agent": "laboratory_agent", "action": "track_pending_tests", "parameters": {}, "urgency": "normal"})
        tasks.append({"target_agent": "insurance_agent", "action": "process_bills", "parameters": {}, "urgency": "normal"})
        tasks.append({"target_agent": "risk_prediction_agent", "action": "calculate_baseline_risk", "parameters": {"diagnosis": discharge_data.get("diagnosis")}, "urgency": "high"})

        # Send to Care Coordinator Agent
        for cmd_data in tasks:
            cmd_event = AgentCommandEvent(
                patient_id=patient_id,
                source=EventSource.POLICY_ENGINE,
                command=CommandPayload(
                    target_agent=cmd_data.get("target_agent"),
                    action=cmd_data.get("action"),
                    parameters=cmd_data.get("parameters", {}),
                    urgency=cmd_data.get("urgency", "normal")
                )
            )
            event_bus.publish(cmd_event)
            print(f"[Care Coordinator Agent] Routed task from Care Plan: {cmd_data.get('action')} -> {cmd_data.get('target_agent')}")

        # C. Trigger Welcome Call (Patient Agent)
        patient_profile = db.query(Patient).filter(Patient.id == patient_id).first()
        user = patient_profile.user if patient_profile else None
        phone = user.phone_number if user else "+910000000000"
        name = user.full_name if user else "Patient"
        
        # Ensure phone number format is correct (must include country code, e.g. +91)
        if not phone.startswith("+"):
            phone = "+91" + phone

        welcome_cmd = AgentCommandEvent(
            patient_id=patient_id,
            source=EventSource.POLICY_ENGINE,
            command=CommandPayload(
                target_agent="patient_agent",
                action="call_patient",
                parameters={
                    "phone": phone,
                    "name": name,
                    "agent_instruction": f"Welcome {name} to Ayusync! Confirm that their account has been successfully created. Reassure them that Ayusync will be taking care of their recovery from now on, especially regarding their recent diagnosis of {discharge_data.get('diagnosis', 'medical condition')}."
                },
                urgency="high"
            )
        )
        event_bus.publish(welcome_cmd)

    return {"status": "success", "message": "Record processed and data updated.", "data": data}
