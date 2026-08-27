# 🧠 Ayusync Project Context (AI Agent Onboarding)

> **FOR AI AGENTS:** Read this document entirely before making any code changes or architectural suggestions for the Ayusync project. It contains the strict rules, technology stack, and architectural patterns required for this system.

---

## 1. Project Overview
**Name**: Ayusync (Autonomous Care Coordination System / Doc AI)
**Mission**: Automate post-discharge patient care to prevent hospital readmissions. The system continuously monitors patients, predicts clinical deterioration, coordinates logistics, and safely escalates to human doctors when necessary.
**Core Principle**: Safety first. The system explicitly prevents "runaway AI" loops, alert fatigue, and LLM medical hallucinations.

---

## 2. Technology Stack
Do not suggest technologies outside of this stack unless explicitly requested by the user.

*   **Cloud Infrastructure**: AWS (Amazon Web Services)
*   **Backend & APIs**: Python 3.11+, FastAPI (Dockerized on Amazon ECS/Fargate)
*   **Agent Orchestration**: LangGraph (for stateful, cyclic agent workflows)
*   **Event Bus**: Amazon EventBridge (or Amazon MSK for high-throughput telemetry)
*   **Database (Single Source of Truth)**: Amazon RDS (PostgreSQL)
*   **Frontend (Unified Web & Mobile)**: Flutter (Dart). Used for Web Dashboards (Doctors) and Mobile Apps (Nurses/Patients).
*   **Machine Learning**: XGBoost (hosted on Amazon SageMaker) for deterministic risk scoring.
*   **LLMs**: Google Gemini 1.5 Pro (via API) or Amazon Bedrock.
*   **External Integrations**: Vobiz (Outbound Voice AI), Twilio (SMS), FHIR/HL7 APIs (EHR integration).

---

## 3. System Architecture (Multi-Agent System)
The system is built on an **Event-Driven Architecture (EDA)**. It strictly separates agents that "Think" from agents that "Act" to prevent circular dependencies.

### A. The Intelligence Layer (Thinking Agents)
These agents operate entirely internally. They consume events, update state, and compute risk. **They are forbidden from talking to the outside world.**

1.  **Patient State Agent**: The definitive data repository (SSOT in PostgreSQL). Receives structured event payloads and maintains the patient's temporal graph.
2.  **Monitoring Agent**: The watchdog. Uses lightweight deterministic rules to trigger other agents, preventing continuous, expensive polling.
3.  **Risk Prediction Agent**: Uses an ML model (XGBoost) for numerical scoring. **CRITICAL RULE**: It must extract mathematical feature importance (SHAP values) and pass them into strict templates for human explanations. It must *never* use an LLM to "guess" why a score is high.
4.  **Medication Adherence Agent**: Tracks compliance. **CRITICAL RULE**: It must cross-reference the Pharmacy Agent's supply status before flagging a patient as non-compliant (prevents penalizing patients for stock shortages).
5.  **Care Planning Agent**: Evaluates the patient state against the doctor's active care plan. **CRITICAL RULE**: It does *not* use LLMs to suggest new medical interventions. It strictly follows the doctor's plan. Before executing an order, it must perform a Contraindication Check against external APIs (e.g., Lexicomp) to catch new conflicting diagnoses/drugs.
6.  **Care Coordinator Agent (Policy Engine)**: The governor. Handles conflict resolution and debouncing. **CRITICAL RULE**: Debounce logic (e.g., grouping 5 minor alerts in 10 mins) must include a "Critical Override" bypass for high-risk events (e.g., chest pain) to escalate immediately.

### B. The Execution Layer (Actionable Agents)
These agents receive validated commands from the Policy Engine via EventBridge and interact with stakeholders.

1.  **Patient Agent**: Uses Vobiz (Voice) and Twilio (SMS) to check in on patients and remind them of care plans.
2.  **Doctor / Nurse / Caregiver Agents**: Route escalated alerts, dashboard updates, and summaries to human caregivers.
3.  **Laboratory / Insurance Agents**: Handle external API requests (HL7/FHIR, Payer APIs).
4.  **Pharmacy Agent**: Manages the medication supply chain. **CRITICAL RULE**: Must proactively request refills 10 days before the patient's current supply depletes.

---

## 4. The Escalation State Machine
To prevent a patient from being ignored if they don't respond to the AI, the system enforces strict timeouts:
1.  **Low Severity**: AI texts/calls the patient. Starts a 4-hour timeout.
2.  **Caregiver Escalation**: If the 4-hour timer expires, the AI alerts the family. Starts a 2-hour timeout.
3.  **Medium Severity**: If the 2-hour timer expires, the patient is added to a human Nurse's urgent triage queue.
4.  **High Severity (Emergency)**: Triggered immediately if the Risk Agent flags high risk, bypassing all timers. Instantly pages the Doctor with a grounded clinical summary.

---

## 5. Development Guidelines
*   When implementing backend features, use FastAPI and ensure it publishes/subscribes to EventBridge cleanly.
*   When implementing frontend features, use Flutter (Dart) with Material 3 design patterns. Ensure Riverpod/Provider is used for state management.
*   When implementing AI workflows, prioritize deterministic rules and mathematically grounded ML over open-ended LLM generation to ensure absolute patient safety.
