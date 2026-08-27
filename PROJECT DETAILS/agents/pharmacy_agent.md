# Pharmacy Agent

## Core Functionality
Manages the medication supply chain to ensure the patient always has access to their prescribed drugs, preventing systemic failures from impacting the patient's health or adherence scores.

## How It Works
1. **Proactive Refills (The Loophole Fix)**: It tracks the patient's current supply. Exactly 10 days before the medication runs out (if the prescription is still active), it proactively sends an authorization request to the pharmacy to prepare a refill.
2. **Stock Checking**: It checks if the pharmacy actually has the drug in stock.
3. **Status Broadcasting**: It reminds the patient to pick up the prescription. Crucially, if there is a stock issue or insurance delay, it flags the delay in the system. The Medication Adherence Agent reads this flag to avoid penalizing the patient for missing a dose they couldn't physically obtain.

## Architecture
* **Technology**: Python worker.
* **Integrations**: Pharmacy Benefit Manager (PBM) APIs or Surescripts (via REST/HL7). Subscribes to `system.agent_commands` on EventBridge.
