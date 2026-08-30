# Phase 3: Actionable Agents Implementation Plan

This plan outlines the architecture for the 7 Actionable (Execution) Agents. It is divided into two independent tracks so that two developers (and their AI assistants) can work in parallel without merge conflicts.

## Proposed Architecture for Actionable Agents

Unlike the Thinking Agents which use LLMs to perform complex reasoning, the Actionable Agents are **Execution Engines**. Their job is simple:
1. Listen to the `system.agent_commands` EventBridge topic.
2. Check if the command is addressed to them (e.g., `if payload['target_agent'] == 'nurse_agent'`).
3. Execute the payload instruction (For the PoC, we will simulate this by `print`ing highly visible logs, or sending mock API requests).
4. (Optional) Publish a success event back to the bus so the Care Coordinator knows it's done.

---

## 👨‍💻 Track A: The Clinical & Patient Team
**Scope:** Building the agents responsible for direct human communication and clinical alerts.

### Proposed Files to Create

#### 1. `backend/app/agents/patient_agent.py`
- **Role:** Communicates with the patient via WhatsApp/SMS.
- **Implementation:** Listens for commands like `request_vitals` or `notify`. Mock behavior: Print `📱 [Patient Agent] Sending WhatsApp to Ramesh: "Please submit your vitals."`

#### 2. `backend/app/agents/doctor_agent.py`
- **Role:** Handles critical escalations and care plan approvals.
- **Implementation:** Listens for `page` or `review_plan`. Mock behavior: Print `🚨 [Doctor Agent] Paging Dr. Smith: "CRITICAL: Patient 123 has abnormal vitals."`

#### 3. `backend/app/agents/nurse_agent.py`
- **Role:** Handles manual triage and follow-up tasks.
- **Implementation:** Listens for `follow_up_call` or `dispatch`. Mock behavior: Print `🩺 [Nurse Agent] Adding task to Nurse Station Dashboard: "Call Ramesh regarding missed medication."`

#### 4. `backend/app/agents/caregiver_agent.py`
- **Role:** Keeps family members in the loop.
- **Implementation:** Listens for `update_family`. Mock behavior: Print `👨‍👩‍👦 [Caregiver Agent] Sending SMS to emergency contact: "Ramesh's condition is stable."`

---

## 👩‍💻 Track B: Operations & Logistics
**Scope:** Building the agents that interact with external hospital systems (B2B integrations).

### Proposed Files to Create

#### 1. `backend/app/agents/pharmacy_agent.py`
- **Role:** Handles medication dispensing and delivery.
- **Implementation:** Listens for `process_prescription` or `deliver_meds`. Mock behavior: Print `💊 [Pharmacy Agent] API Call to Apollo Pharmacy: "Dispatching Aspirin to Patient 123."`

#### 2. `backend/app/agents/laboratory_agent.py`
- **Role:** Schedules diagnostic tests.
- **Implementation:** Listens for `schedule_home_draw` or `request_results`. Mock behavior: Print `🔬 [Laboratory Agent] API Call to Diagnostics Partner: "Scheduling Phlebotomist for Day 14."`

#### 3. `backend/app/agents/insurance_agent.py`
- **Role:** Handles pre-authorizations and claims.
- **Implementation:** Listens for `verify_coverage` or `submit_claim`. Mock behavior: Print `🛡️ [Insurance Agent] Verifying policy for telemetry equipment coverage. Status: APPROVED.`

#### 4. Verification Setup (`backend/test_poc.py`)
- **Role:** The developer on Track B should also import and register their new agents (Pharmacy, Lab, Insurance) into the `test_poc.py` script so that they wake up and print logs when triggered. (Track A developer will do the same for their agents).

---

## Instructions for the AI Agents
When you (the AI agent) begin working on your assigned Track:
1. Create the `.py` files inside `backend/app/agents/`.
2. Model the basic structure off the existing event-listeners (e.g., using `def handle_event(topic, payload):`).
3. Make sure to ONLY process events where `topic == "system.agent_commands"` AND `payload.get('data', {}).get('target_agent') == 'YOUR_AGENT_NAME'`.
+































































































































































































































































































































































