# Care Planning Agent

## Core Functionality
Executes the pre-approved clinical workflow for a patient based on their current risk and adherence scores. It acts as the tactical planner but strictly follows human doctor protocols.

## How It Works
1. **Protocol Execution (The Loophole Fix)**: It does *not* use LLMs to hallucinate or invent new medical plans based on generic guidelines. It strictly loads the exact Care Plan prescribed by the patient's doctor.
2. **Contraindication Check (The Loophole Fix)**: Before proposing any standing order (like continuing a specific drug), it performs a safety check against an external medical API (like Lexicomp or Epocrates). If it detects that a new diagnosis (e.g., from an external hospital visit) conflicts with the current plan, it immediately suspends the action and triggers an escalation to the doctor.
3. **Proposal**: Outputs a `CarePlanUpdate` array (e.g., `[Send_Refill_Reminder]`) to the Policy Engine.

## Architecture
* **Technology**: Python microservice utilizing LangGraph for deterministic, stateful workflow execution.
* **Integration**: Makes synchronous REST API calls to external FHIR databases or Medical Interaction APIs (Lexicomp/Epocrates) to perform the contraindication safety checks.
