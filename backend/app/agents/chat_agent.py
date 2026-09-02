import json
from typing import List, Dict, Any
from sqlalchemy.orm import Session
from app.models.database import Patient, ClinicalNote, LabTest, CarePlan, Medication, User
from langchain_groq import ChatGroq
from langchain_core.messages import SystemMessage, HumanMessage, AIMessage
import os
from pydantic import BaseModel

# In a real app, this would be a persistent vector DB (pgvector or Pinecone).
# Since we are constrained from modifying DB models, we simulate a lightweight
# in-memory semantic retriever for Clinical Guidelines.
class ClinicalGuidelineVectorDB:
    def __init__(self):
        self.guidelines = [
            "GUIDELINE: For chest pain, always escalate to ER or immediately notify doctor.",
            "GUIDELINE: For mild headache, recommend rest and hydration. Do not prescribe new medications.",
            "GUIDELINE: If patient reports missing a dose, advise them to take it as soon as possible unless it's almost time for the next dose.",
            "GUIDELINE: Normal blood pressure is below 120/80 mmHg.",
            "GUIDELINE: Fasting blood sugar should be under 100 mg/dL.",
            "GUIDELINE: Do not alter treatment plans without physician authorization."
        ]
        
    def search(self, query: str, top_k: int = 3) -> List[str]:
        # Simple keyword matching as a fallback for the vector DB constraint
        query_words = query.lower().split()
        scored = []
        for g in self.guidelines:
            score = sum(1 for w in query_words if w in g.lower())
            scored.append((score, g))
        scored.sort(key=lambda x: x[0], reverse=True)
        return [g for score, g in scored[:top_k]]

guideline_db = ClinicalGuidelineVectorDB()

class ChatAgent:
    def __init__(self, db: Session, patient_id: str):
        self.db = db
        self.patient_id = patient_id
        
        # Initialize Groq LLM
        api_key = os.getenv("GROQ_API_KEY")
        model_name = os.getenv("GROQ_MODEL_NAME", "llama3-8b-8192")
        self.llm = ChatGroq(groq_api_key=api_key, model_name=model_name)
        
    def _get_patient_context(self) -> str:
        """Retrieves patient-specific data to act as the Patient Vector Context"""
        patient = self.db.query(Patient).filter(Patient.id == self.patient_id).first()
        if not patient:
            return "No patient data found."
            
        context_parts = [
            f"Patient Name: {patient.user.full_name}",
            f"DOB: {patient.date_of_birth}",
            f"Blood Type: {patient.blood_type}"
        ]
        
        # Get active medications
        meds = self.db.query(Medication).filter(Medication.patient_id == self.patient_id, Medication.is_active == True).all()
        if meds:
            context_parts.append("\nACTIVE MEDICATIONS:")
            for m in meds:
                context_parts.append(f"- {m.drug_name}: {m.dosage} ({m.frequency})")
                
        # Get latest clinical notes
        notes = self.db.query(ClinicalNote).filter(ClinicalNote.patient_id == self.patient_id).order_by(ClinicalNote.timestamp.desc()).limit(3).all()
        if notes:
            context_parts.append("\nRECENT CLINICAL NOTES:")
            for n in notes:
                context_parts.append(f"- [{n.note_type}]: {n.content_text}")
                
        return "\n".join(context_parts)
        
    def process_message(self, user_message: str, chat_history: List[Dict[str, str]]) -> str:
        """Processes a new chat message using Dual-RAG and returns the AI response"""
        
        # 1. Retrieve Patient Context
        patient_context = self._get_patient_context()
        
        # 2. Retrieve Clinical Guidelines Context
        guideline_context = "\n".join(guideline_db.search(user_message))
        
        # 3. Construct the prompt with strict medical constraints
        system_prompt = f"""You are the AyuSync AI Care Assistant. 
You are speaking directly to the patient. Be warm, empathetic, and patient-friendly.

CRITICAL MEDICAL KNOWLEDGE & GUIDELINES (Retrieved Context):
{guideline_context}

PATIENT PROFILE (Retrieved Context):
{patient_context}

STRICT SAFETY CONSTRAINTS:
1. DO NOT diagnose the patient.
2. DO NOT recommend new medications or treatments.
3. DO NOT alter the existing care plan.
4. You may ONLY answer based on the Patient Profile and Guidelines provided above.
5. If the patient reports a dangerous symptom (e.g., chest pain), advise them to seek immediate medical attention and state that you are notifying their care coordinator.

FORMATTING RULES:
- Format your response using plain text, paragraphs, and simple bullet points (-).
- DO NOT use Markdown tables, as the mobile chat UI cannot render them properly.
- Keep responses concise and easy to read on a small mobile screen.
"""
        
        messages = [SystemMessage(content=system_prompt)]
        
        # Add conversation history
        for msg in chat_history:
            if msg["sender"] == "user":
                messages.append(HumanMessage(content=msg["text"]))
            else:
                messages.append(AIMessage(content=msg["text"]))
                
        # Add current message
        messages.append(HumanMessage(content=user_message))
        
        # Call Groq LLM
        response = self.llm.invoke(messages)
        return response.content
        
    def summarize_chat(self, chat_history: List[Dict[str, str]]) -> str:
        """Summarizes the entire chat session for the clinical records."""
        if not chat_history:
            return "No chat history to summarize."
            
        chat_text = "\n".join([f"{m['sender']}: {m['text']}" for m in chat_history])
        
        prompt = f"""Please provide a concise clinical summary of the following chat session between a patient and the AI assistant. 
Focus on symptoms reported, medication adherence issues, or any concerning statements.

CHAT TRANSCRIPT:
{chat_text}

SUMMARY:"""

        response = self.llm.invoke([HumanMessage(content=prompt)])
        return response.content
