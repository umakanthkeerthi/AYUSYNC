import sys
import os

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.core.database_session import SessionLocal
from app.models.database import CareTask

def main():
    db = SessionLocal()
    tasks = db.query(CareTask).filter(CareTask.assigned_role == "NURSE").all()
    
    advanced_descriptions = [
        "Post-Operative Wound Assessment & Debridement",
        "Evaluate Patient Response to New Cardiac Medication",
        "Perform Comprehensive Neurological Exam",
        "Titrate IV Fluids based on recent Renal Panel",
        "Formulate Comprehensive Care Plan for Discharge"
    ]
    
    for i, task in enumerate(tasks):
        if i < len(advanced_descriptions):
            task.task_description = advanced_descriptions[i]
            
    db.commit()
    db.close()
    print("Care tasks updated to advanced nursing tasks!")

if __name__ == "__main__":
    main()
