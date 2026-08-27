# Caregiver Agent

## Core Functionality
The secondary interface for the patient's support network (family, friends, or designated home aides). It provides passive updates and serves as the first level of escalation if the patient is unresponsive.

## How It Works
1. **Passive Notifications**: Sends daily or weekly milestone summaries ("Dad's vitals look great today!").
2. **Escalation Trigger**: If the Escalation State Machine hits `CAREGIVER_ESCALATION` (e.g., because the patient ignored a 4-hour timeout for a medication reminder), this agent immediately alerts the caregiver via SMS or Email to intervene physically.
3. **Resolution**: If the caregiver replies confirming the issue is resolved, it parses the response and publishes it to the Event Bus to reset the system's severity level back to normal.

## Architecture
* **Technology**: Python worker.
* **Integrations**: Twilio (SMS) and Amazon SES (Simple Email Service). Reads from `system.agent_commands` on EventBridge.
