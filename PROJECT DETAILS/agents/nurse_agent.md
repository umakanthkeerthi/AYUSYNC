# Nurse Agent

## Core Functionality
Orchestrates nursing workflows and home health logistics. It acts as the bridge between the AI system and the human nursing staff, managing their daily triage queues and field visits.

## How It Works
1. **Triage Management**: When the system reaches `MEDIUM_SEVERITY` (e.g., repeated ignored alerts or moderate symptoms), this agent automatically adds the patient to the on-call Nurse's digital call list on their Web Dashboard.
2. **Home Visit Scheduling**: Coordinates logistics for physical visits (e.g., wound care checkups).
3. **Note Ingestion**: When a nurse finishes a home visit and types notes into their Flutter Mobile App, this agent ingests the notes, structures them, and publishes the clinical updates to the Event Bus.

## Architecture
* **Technology**: Python worker/API backend serving the Flutter Web/Mobile frontend.
* **Integrations**: Connects internal hospital nursing portals via REST APIs. Subscribes to `system.agent_commands` on EventBridge.
