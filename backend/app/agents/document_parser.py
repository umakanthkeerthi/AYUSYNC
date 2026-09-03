import base64
import os
import json
from sqlalchemy.orm import Session
from datetime import datetime, date, timedelta
from typing import Dict, Any
from groq import Groq
from app.models.database import Medication, CareTask, ClinicalNote

def process_medical_record(patient_id: str, base64_image: str, db: Session) -> Dict[str, Any]:
    """
    Sends the uploaded medical record image to Groq Vision AI.
    Extracts medications and required tasks.
    Updates the database with the new data.
    """
    api_key = os.getenv("GROQ_API_KEY")
    client = Groq(api_key=api_key)
    
    prompt = """
    You are a medical AI assistant. The user has uploaded a medical document (prescription or lab report).
    Analyze the image and extract the following information in strict JSON format:
    {
      "type": "prescription" | "lab_report",
      "summary": "A brief 2 sentence summary of what this document is.",
      "medications": [
        {
          "name": "Medication Name",
          "dosage": "Dosage (e.g., 500mg)",
          "frequency": "Frequency (e.g., twice daily)"
        }
      ],
      "tasks": [
        {
          "title": "Task title (e.g., Check Blood Pressure, Drink Water, Follow-up Call)",
          "description": "Task description"
        }
      ]
    }
    Only output valid JSON, nothing else.
    """

    try:
        response = client.chat.completions.create(
            messages=[
                {
                    "role": "user",
                    "content": [
                        {"type": "text", "text": prompt},
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": f"data:image/jpeg;base64,{base64_image}",
                            },
                        },
                    ],
                }
            ],
            model="llama-3.2-90b-vision-preview",
            temperature=0.1,
            max_tokens=1024,
        )
        
        json_str = response.choices[0].message.content
        
        # Clean up JSON if wrapped in markdown code blocks
        if json_str.startswith("```json"):
            json_str = json_str.replace("```json\n", "").replace("```", "")
            
        data = json.loads(json_str)
        
        # Save summary as ClinicalNote
        note = ClinicalNote(
            patient_id=patient_id,
            timestamp=datetime.utcnow(),
            note_type="AI Analysis: " + data.get("type", "Document"),
            content=data.get("summary", "Analyzed uploaded document.")
        )
        db.add(note)
        
        # Save Medications
        medications = data.get("medications", [])
        for med in medications:
            new_med = Medication(
                patient_id=patient_id,
                drug_name=med.get("name", ""),
                dosage=med.get("dosage", ""),
                frequency=med.get("frequency", ""),
                is_active=True
            )
            db.add(new_med)
            
        # Save Tasks for today
        tasks = data.get("tasks", [])
        today = date.today()
        for t in tasks:
            new_task = CareTask(
                patient_id=patient_id,
                task_type="AI_GENERATED",
                title=t.get("title", ""),
                description=t.get("description", ""),
                scheduled_date=today,
                scheduled_time=datetime.now().time(),
                is_completed=False
            )
            db.add(new_task)
            
        db.commit()
        return {"status": "success", "message": "Record processed and data updated.", "data": data}
        
    except Exception as e:
        db.rollback()
        raise e
