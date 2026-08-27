# Care Coordinator Agent (Policy Engine)

## Core Functionality
The "Governor" of the Multi-Agent System. It sits between the Thinking Agents and the Actionable Agents to ensure absolute patient safety, prevent alert fatigue, and resolve conflicts.

## How It Works
1. **Conflict Resolution**: Applies hard-coded tie-breakers. If the Adherence Agent says the patient is doing great (100%), but the Risk Agent flags severe danger (95%), it prioritizes Risk and escalates.
2. **Debouncing**: To prevent spamming nurses or patients, it batches minor state changes. If 5 minor events happen in 10 minutes, it sends 1 consolidated update instead of 5 distinct alerts.
3. **Critical Override (The Loophole Fix)**: If an incoming event is flagged as high clinical risk (e.g., severe chest pain), it bypasses the debounce timer entirely and immediately publishes the emergency escalation command.
4. **Command Publishing**: Once a care plan update passes all safety guardrails, it converts it into an executable command (e.g., `command.patient_agent.call_patient`) and publishes it to the Event Bus.

## Architecture
* **Technology**: Python microservice acting as the central LangGraph orchestrator node.
* **State Management**: Uses Amazon ElastiCache (Redis) to handle the stateful timers required for the Debounce windows.
* **Integration**: The final gatekeeper that publishes to the `system.agent_commands` topic on Amazon EventBridge.
