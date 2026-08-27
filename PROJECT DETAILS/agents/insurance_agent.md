# Insurance Agent

## Core Functionality
Administrative support for billing, coverage validation, and prior authorizations. It operates strictly reactively to minimize friction in emergency situations.

## How It Works
1. **Reactive Operation**: It only triggers *after* the Doctor Agent records a confirmed clinical decision (e.g., the doctor clicks "Authorize Readmission").
2. **Authorization Prep**: It automatically pre-fills prior authorization forms based on the patient's clinical history stored in the Patient State Agent.
3. **Policy Validation**: It validates active policy status with the payer (e.g., Medicare, private insurance) to speed up emergency admissions or expensive medication approvals, reducing the administrative burden on human hospital staff.

## Architecture
* **Technology**: Python worker.
* **Integrations**: Payer APIs (e.g., Change Healthcare, Eligible). Subscribes to `system.agent_commands` on EventBridge.
