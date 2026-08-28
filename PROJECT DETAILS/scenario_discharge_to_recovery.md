# Scenario: Post-Operative Discharge to Full Recovery

This document outlines an end-to-end patient journey to illustrate how the **Doc AI Multi-Agent System** seamlessly collaborates to manage a patient from the moment they leave the hospital until their full recovery.

## The Patient
- **Name:** Ramesh Kumar (55 M)
- **Procedure:** Coronary Artery Bypass Grafting (CABG)
- **Status:** Discharged on Day 0 with a 14-day recovery protocol.

---

### Phase 1: The Discharge (Day 0)

1. **Hospital Emits Discharge Summary:** The hospital's EMR generates Ramesh's final discharge summary (PDF) and medication list.
2. **Ingestion (`Patient State Agent`)**: The agent receives the PDF, extracts the structured clinical entities using NLP (Diagnoses: Post-CABG, Meds: Aspirin, Beta-blockers), and updates Ramesh's unified profile in the central PostgreSQL/Firestore database. It fires a `state.updated` event.
3. **Strategy (`Care Planning Agent`)**: Wakes up to the `state.updated` event. Acting as the Senior Medical Officer, it reads the extracted data and drafts a 14-day Care Plan:
   - *Requirement 1:* Daily Blood Pressure & Heart Rate checks at 9:00 AM.
   - *Requirement 2:* Medication adherence check twice daily.
   - *Requirement 3:* Schedule a follow-up Cardiology consult on Day 14.
4. **Coordination (`Care Coordinator Agent`)**: Receives the drafted plan. It acts as the hospital administrator, mapping the text into scheduled **System Commands**:
   - Creates a daily cron trigger for 9:00 AM.
   - Dispatches a command to the `Pharmacy Agent` to arrange delivery of the prescribed discharge medications to Ramesh's home.

---

### Phase 2: Routine At-Home Monitoring (Days 1 - 7)

1. **Daily Check-in (`Care Coordinator Agent`)**: At 9:00 AM every day, the scheduled cron job fires, prompting the Coordinator to send a "request_vitals" command to the Patient Agent.
2. **Patient Outreach (`Patient Agent`)**: The agent sends a friendly, localized WhatsApp message to Ramesh: *"Namaste Ramesh-ji, time for your morning check! Did you take your Aspirin today? Please also share your Blood Pressure reading."*
3. **Data Logging (`Patient State Agent`)**: Ramesh replies: *"Yes, took meds. BP is 120/80."* The Patient Agent forwards this text to the State Agent, which updates the database.
4. **Safety Check (`Monitoring Agent`)**: Constantly watching the database, the Monitoring Agent sees the new BP reading, confirms it is within normal limits, and takes no action. Ramesh is safe.

---

### Phase 3: The Anomaly (Day 8)

1. **The Incident:** At 9:00 AM on Day 8, Ramesh reports feeling slightly dizzy and submits a BP reading of **165/100** (Hypertension).
2. **Detection (`Monitoring Agent`)**: The agent immediately flags `165/100` as a severe anomaly and fires a `trigger.risk_assessment` event.
3. **Analysis (`Risk Predictor Agent`)**: 
   - Queries the external Machine Learning Vitals API, which returns a **High Risk (88%)** probability for cardiac distress.
   - Queries the Groq LLM (e.g., Llama-3) to analyze the trend. The LLM generates an **SBAR Note**: *"Situation: Sudden hypertension on Day 8 post-CABG. Background: Previously normotensive. Assessment: High risk for post-op complications or medication non-compliance. Recommendation: Urgent physician review."*
4. **Emergency Strategy (`Care Planning Agent`)**: Receives the High Risk score (88%) which exceeds the safe threshold (50%). It queries Groq to draft an emergency intervention plan: *"Hold morning beta-blockers, page on-call cardiologist immediately for a telehealth consult."*
5. **Execution (`Care Coordinator Agent`)**: Translates the emergency plan into immediate commands:
   - `page -> doctor_agent (critical priority)`
   - `notify -> patient_agent ("Please rest, the doctor is being notified")`

---

### Phase 4: Intervention & Recovery (Day 8 - 14)

1. **Physician Alert (`Doctor Agent`)**: Receives the critical page. It triggers an SMS/Push Notification to the on-call Cardiologist's phone and populates their Doc AI portal with Ramesh's sudden BP spike and the LLM's SBAR note.
2. **Clinical Decision (`Doctor Agent`)**: The doctor reviews the dashboard, clicks a button to adjust the medication dosage, and initiates a quick video call with Ramesh.
3. **Plan Update (`Patient State Agent`)**: The new medication dosage is saved to the database.
4. **The Final Milestone (`Care Coordinator Agent`)**: On Day 13, the Coordinator fulfills the final step of the original Care Plan by dispatching a command to the `Laboratory Agent`.
5. **Logistics (`Laboratory Agent`)**: Automatically interfaces with a 3rd-party lab partner (e.g., Apollo Diagnostics) to schedule a phlebotomist to visit Ramesh's home on Day 14.
6. **Recovery Concluded (`Care Planning Agent`)**: Once the Day 14 lab results return normal, the Care Planning agent officially marks the episode as **Resolved**.

---

### Agent Journey Summary Matrix

| Agent | Role in the Journey |
| :--- | :--- |
| **Patient State Agent** | Ingests the initial discharge papers and acts as the central brain recording every WhatsApp reply and lab result. |
| **Care Planning Agent** | The clinical strategist. Drafts the 14-day roadmap and steps in during the Day 8 emergency to dictate the intervention. |
| **Care Coordinator Agent** | The engine. Schedules the daily ping, routes commands to the Pharmacy, Doctor, and Lab agents exactly when needed. |
| **Patient Agent** | The empathetic interface communicating with Ramesh via WhatsApp. |
| **Monitoring Agent** | The silent guardian. Detected the Day 8 anomaly that triggered the emergency protocol. |
| **Risk Predictor Agent** | Provided the statistical ML risk score and the LLM-generated clinical reasoning (SBAR) during the Day 8 spike. |
| **Doctor/Nurse/Lab Agents** | The external actors executing real-world tasks (alerting humans, scheduling home visits). |
