# Patient Agent

## Core Functionality
The primary interface between the AI system and the patient. It communicates via natural language (voice or text) to provide reminders, check symptoms, and offer education.

## How It Works
1. **Command Execution**: Receives commands from the Care Coordinator via the Event Bus (e.g., `send_medication_reminder`).
2. **Interaction**: Calls the Vobiz API to initiate a voice call or Twilio to send an SMS/WhatsApp message. It injects dynamic `agent_instruction` prompts into the call so the AI voice behaves exactly as intended.
3. **Feedback Parsing**: When the patient replies (either via voice transcript or SMS text), the agent uses an LLM to parse the unstructured natural language into structured data (e.g., extracting "Pain Level: 8").
4. **Data Publishing**: Pushes this newly structured data back to the Event Bus for the Patient State Agent to record.

## Architecture
* **Technology**: Python worker utilizing FastAPI to manage webhooks.
* **Integrations**: Makes outbound REST API calls to Vobiz (for telephony) and Twilio (for messaging). Subscribes to `system.agent_commands` on EventBridge.
