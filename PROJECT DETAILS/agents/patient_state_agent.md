# Patient State Agent

## Core Functionality
The Patient State Agent acts as the definitive Single Source of Truth (SSOT) for the entire Ayusync Multi-Agent System. It maintains the temporal graph (timeline) of the patient's recovery, storing vitals, medication adherence, lab results, and reported symptoms.

## How It Works
1. **Event Ingestion**: It continuously listens to the central Event Bus for incoming structured data (e.g., a "medication taken" event from the Patient Agent, or a "new lab result" from the Laboratory Agent).
2. **State Updates**: It acts as a strict state machine. It does not use LLMs to guess or extract data from unstructured text; it relies on upstream Actionable Agents to parse data into clean JSON.
3. **Temporal Mapping**: It updates the patient's timeline in the database, ensuring that every data point is timestamped and historically accurate.

## Architecture
* **Technology**: Python FastAPI background worker.
* **Database**: Amazon RDS (PostgreSQL). It strictly enforces relational database schemas to ensure clinical data integrity.
* **Integration**: Subscribes to `telemetry.*`, `clinical.*`, and `interaction.*` topics on Amazon EventBridge.
