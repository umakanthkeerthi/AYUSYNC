# Laboratory Agent

## Core Functionality
Coordinates diagnostics and lab testing. It handles the scheduling of tests and the ingestion of the resulting clinical data back into the system.

## How It Works
1. **Scheduling**: If the Care Plan requires a blood test in 30 days, it sends a scheduling request to the external lab.
2. **Patient Prep**: It pushes a command to the Patient Agent to remind the patient to fast for 12 hours before the scheduled lab visit.
3. **Data Ingestion**: It continuously polls or receives webhooks from the external lab (e.g., Quest/Labcorp). When a PDF or JSON lab report is ready, it parses the results (e.g., Creatinine levels) and publishes them as a structured `clinical.ehr_update` event to the Event Bus.

## Architecture
* **Technology**: Python worker specializing in data parsing (OCR for PDFs, JSON parsing for modern APIs).
* **Integrations**: HL7/FHIR integrations with external lab systems. Subscribes to `system.agent_commands` on EventBridge and publishes to `clinical.ehr_updates`.
