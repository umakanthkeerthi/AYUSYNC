# Mock EHR API Documentation

This document outlines all the available API endpoints in your Mock EHR backend. You can use these endpoints to fetch clinical data when building your Post-Discharge Solution. 

**Base URL**: `http://<YOUR_AWS_IP_ADDRESS>/api` 
*(Currently: `http://13.60.9.54/api`)*

---

## 🧍 Patients API

### 1. List All Patients
*Fetches a list of all patients currently in the EHR, including their basic demographics.*
- **Endpoint**: `GET /patients/`
- **Response**: Array of Patient objects.
- **Example Usage**: `curl http://13.60.9.54/api/patients/`

### 2. Get Single Patient
*Fetches demographic details for a specific patient by their ID.*
- **Endpoint**: `GET /patients/{patient_id}`
- **Response**: Single Patient object.

### 3. Get Patient Encounters (Hospital Visits)
*Fetches all hospital visits/encounters for a specific patient. Use this to check if a patient was recently discharged.*
- **Endpoint**: `GET /patients/{patient_id}/encounters`
- **Response**: Array of Encounter objects (includes `status`, `period_start`, `period_end`, `reason`).

### 4. Get Patient Conditions (Medical History)
*Fetches the chronic and acute medical conditions diagnosed for a specific patient.*
- **Endpoint**: `GET /patients/{patient_id}/conditions`
- **Response**: Array of Condition objects (includes `name`, `clinical_status`).

### 5. Get Patient Medications
*Fetches the medications prescribed to a specific patient.*
- **Endpoint**: `GET /patients/{patient_id}/medications`
- **Response**: Array of MedicationRequest objects (includes `medication_name`, `status`, `dosage_instruction`).

### 6. Get Patient Observations (Vitals/Labs)
*Fetches lab results and vital signs for a specific patient.*
- **Endpoint**: `GET /patients/{patient_id}/observations`
- **Response**: Array of Observation objects (includes `name`, `value`, `unit`).

---

## 🏥 Encounters API

### 1. Get Single Encounter
*Fetches details of a specific hospital encounter by its ID.*
- **Endpoint**: `GET /encounters/{encounter_id}`
- **Response**: Single Encounter object.

---

## 👩‍⚕️ Practitioners API

### 1. List All Practitioners
*Fetches a list of all doctors and nurses registered in the system.*
- **Endpoint**: `GET /practitioners/`
- **Response**: Array of Practitioner objects.

---

> 💡 **Developer Tip**: You can interactively test all of these APIs and see the exact JSON structure they return by visiting the auto-generated Swagger UI at **`http://<YOUR_AWS_IP_ADDRESS>/docs`** in your browser!
