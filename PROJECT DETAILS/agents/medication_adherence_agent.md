# Medication Adherence Agent

## Core Functionality
Tracks a patient's compliance with their prescribed medication schedule over time and flags recurring non-adherence patterns to inform care plans.

## How It Works
1. **Time-Series Analysis**: It compares the doctor's prescribed medication schedule against the actual recorded intake events (gathered from the Patient State Agent).
2. **Supply Chain Cross-Reference (The Loophole Fix)**: Before flagging a patient as non-compliant, it strictly cross-references the **Pharmacy Agent's** supply status. If the Pharmacy Agent reports a stock shortage, insurance denial, or delivery delay, the Adherence Agent notes this as a "Systemic Delay" rather than "Patient Non-Compliance," preventing the system from unfairly scolding the patient.
3. **Scoring**: Outputs an `AdherenceScore` (e.g., 85%) and a context flag.

## Architecture
* **Technology**: Python microservice running on AWS ECS.
* **Logic**: Time-series analytics algorithms (Pandas/NumPy) to detect compliance patterns over rolling windows (e.g., 7-day, 30-day).
* **Integration**: Consumes from EventBridge and directly queries the Pharmacy Agent's state before publishing results.
