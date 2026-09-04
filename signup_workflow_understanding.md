# Understanding of the Ayusync Patient Signup Workflow

Based on your description and the comprehensive list of Ayusync agents, here is the detailed breakdown of the proposed patient signup and onboarding workflow. This flow connects the user interface, the OCR document analysis API, and seamlessly orchestrates all Thinking and Actionable agents.

## 1. Patient Details & Signup
- **Action:** The patient navigates to the signup page.
- **Process:** The system prompts the user to fill out their basic demographic and contact information (Name, Phone Number, Age, Gender, etc.) to create their profile.

## 2. Medical Document Upload
- **Action:** Post-details submission, the system prompts the patient to upload their medical records.
- **Process:** The patient uploads essential documents such as Discharge Summaries, Lab Reports, Prescriptions, and X-rays.
- **OCR Processing & Digitization:** The system sends *all* the uploaded files to the **Medical Document Intelligence API (OCR)** (`POST http://13.53.200.2/api/analyze`). The goal here is to digitize physical papers so they can be securely stored and viewed in the app.

## 3. State Initialization (Patient State Agent)
- **Action:** Establishing the Single Source of Truth.
- **Process:** The **Patient State Agent** receives the clean, structured JSON from the OCR API for all the documents and initializes the patient's temporal graph/timeline in the database.

## 4. Care Plan Generation (Care Planning Agent)
- **Action:** Creating the recovery roadmap.
- **Process:** The **Care Planning Agent** loads *only the Discharge Summary* parsed by the OCR API. It strictly uses the discharge summary to map out the patient's recovery care plan. It does *not* use lab reports, X-rays, or prescriptions for the core plan generation.
- **Task List Creation:** The Care Planning Agent generates a specific list of tasks designated for each of the other thinking agents (e.g., track these meds, monitor these vitals). 

## 5. Task Delegation (Care Coordinator Agent)
- **Action:** Distributing work to the ecosystem.
- **Process:** The Care Planning Agent hands the complete list of tasks to the **Care Coordinator Agent (Policy Engine)**. The Care Coordinator Agent acts as the central router and officially delivers the respective tasks to every other thinking and actionable agent:
  - **Medication Adherence Agent:** Tasked to track the patient's compliance with medications.
  - **Monitoring Agent:** Programmed to watch the Patient State Agent for specific incoming vital signs or lab results.
  - **Risk Prediction Agent:** Triggered to calculate the patient's initial baseline risk score.
  - **Pharmacy Agent:** Alerted to verify stock and process incoming prescriptions.
  - **Laboratory Agent:** Alerted to track any pending diagnostic tests.
  - **Insurance Agent:** Alerted to review and process medical bills.
  - **Caregiver / Nurse / Doctor Agents:** Dashboards primed with the patient's new data.

## 6. Dashboard Population
- **Action:** Organizing patient data for the UI.
- **Process:** All the digitized files (Lab Reports, Prescriptions, X-rays, Discharge Summaries) and extracted values are securely stored and displayed in the patient's **"My Reports"** section.

## 7. Welcome & Reassurance Call (Patient Agent & Calling API)
- **Action:** Personalized voice onboarding.
- **Process:** The **Patient Agent** hits the **Voice Calling Agent API** (`POST https://ayusync.toplabs.in/api/call`). 
- **Execution:** An automated outbound call is made to the patient's registered phone number. The AI agent warmly welcomes the patient, confirms that their account has been created, and reassures them that Ayusync will be taking care of their recovery from now on.
