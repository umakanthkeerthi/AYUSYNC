# Ayusync: Comprehensive Tech Stack Plan

This document outlines the recommended technology stack required to build the Autonomous Care Coordination System outlined in the `solution.md` architecture. It covers the core Multi-Agent System (MAS) backend, as well as the necessary frontend applications for all stakeholders.

---

## 1. Stakeholder Mapping & Application Requirements

Before selecting the tech stack, we must identify what each stakeholder needs:

1.  **Patient**: Low-friction interaction. Primarily relies on SMS/WhatsApp and Voice Calls (Vobiz). An optional **Mobile App** can be built for manual vitals entry and history.
2.  **Caregiver**: Passive notifications via SMS/Email. No dedicated app needed.
3.  **Nurse**: Needs a **Web Dashboard** (for triage/call queues) and a **Mobile App** (for home visits and offline notes).
4.  **Doctor**: Needs a secure, high-information **Web Dashboard** for reviewing AI-generated risk summaries and authorizing interventions.
5.  **External Systems (Lab, Pharmacy, EHR)**: Requires robust REST/FHIR **API Integrations**.

---

## 2. Core Backend & Agent Orchestration (The "Brain")

The backend must handle high-throughput event processing, complex AI reasoning, and strict state machines. 

*   **Primary Language**: Python 3.11+
*   **Web Framework (API Layer)**: **FastAPI**. Extremely fast, supports asynchronous operations (crucial for I/O bound agent tasks), and auto-generates Swagger documentation.
*   **Multi-Agent Orchestration**: **LangGraph** (or AutoGen). LangGraph is specifically designed to build cyclic, stateful multi-agent systems with explicit control flows.
*   **Event Bus (The Ingestion Layer)**: **Amazon EventBridge** (for serverless event routing between agents) or **Amazon MSK (Managed Streaming for Apache Kafka)** (if ingesting massive amounts of real-time wearable telemetry). EventBridge is highly recommended for building this Event-Driven Architecture on AWS.
*   **Background Task Workers**: **AWS Step Functions** or Celery/Redis for managing the Timeout State Machine.

---

## 3. Data, AI Layer, & Deployment (AWS Infrastructure)

*   **Primary Database (Patient State)**: **Amazon RDS (PostgreSQL)**. A managed relational database is strongly recommended for healthcare to ensure strict schema enforcement, automated backups, High Availability (Multi-AZ), and HIPAA compliance out of the box.
*   **Cloud Deployment**: **Amazon ECS (Elastic Container Service) / AWS Fargate**. Containerizing the FastAPI backend and Agent models into Docker and running them on Fargate provides a highly scalable, serverless infrastructure without managing EC2 instances.
*   **Machine Learning (Risk Prediction)**: **Amazon SageMaker** to host the XGBoost models, or native Scikit-learn inside the backend containers.
*   **LLM Provider**: **Google Gemini 1.5 Pro** via API (or Amazon Bedrock if keeping all AI strictly within the AWS VPC for compliance). 
*   **Prompt Grounding**: Using mathematical SHAP values passed into strict JSON templates to prevent hallucinations.

---

## 4. Unified Frontend Applications (Web & Mobile)

By choosing **Flutter**, you gain the massive advantage of a truly unified frontend. You can compile the exact same codebase into native iOS apps, Android apps, and high-performance Web Applications (for the Doctor/Nurse portals).

*   **Framework**: **Flutter**. Compiled to native ARM code for mobile (incredibly fast) and WebGL/CanvasKit for the web dashboards.
*   **Language**: **Dart**. Strongly typed, object-oriented, and highly optimized for UI development.
*   **State Management**: **Riverpod** or **Provider**. Essential for managing the complex state of clinical dashboards and syncing data with the backend.
*   **UI/Design System**: **Material 3 (Material Design)**. Flutter comes with a vast, beautiful library of pre-built Material components that are highly accessible and look native on all platforms. This ensures the Doctor Web Dashboard and the Nurse Mobile App feel like part of the exact same ecosystem.
*   **Offline Support (Nurse App)**: **Hive** or **Isar Database**. These are incredibly fast, NoSQL local databases for Flutter that allow nurses to take notes in dead zones and sync to AWS when reconnected.

---

## 5. Integrations & Telephony

*   **Voice Calling (Patient/Nurse Agent)**: **Vobiz (via Plivo)**. Handles outbound AI voice calls with dynamic instructions.
*   **SMS & WhatsApp (Patient/Caregiver Agent)**: **Twilio API**.
*   **EHR / Clinical Data**: RESTful APIs using the **FHIR (Fast Healthcare Interoperability Resources)** standard.

---

## Summary of the Tech Stack

| Component | Technology |
| :--- | :--- |
| **Cloud Provider** | AWS (Amazon Web Services) |
| **Backend API** | Python / FastAPI (Dockerized on Amazon ECS/Fargate) |
| **Agent Framework** | LangGraph |
| **Event Bus** | Amazon EventBridge / Amazon MSK |
| **Database** | Amazon RDS (PostgreSQL) |
| **Unified Frontend (Web + Mobile)** | Flutter (Dart) |
| **AI Models** | XGBoost (SageMaker), Gemini/Bedrock |
| **Telephony/SMS** | Vobiz, Twilio |
