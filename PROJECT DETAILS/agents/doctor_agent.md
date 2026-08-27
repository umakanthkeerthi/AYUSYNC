# Doctor Agent

## Core Functionality
The clinical decision hub. It does *not* replace the doctor. Instead, it prepares highly condensed, relevant clinical summaries of *why* a patient is being escalated, allowing the doctor to make rapid, informed decisions.

## How It Works
1. **High-Severity Paging**: Triggered instantly during a `HIGH_SEVERITY` escalation (e.g., the Risk Prediction Agent flags severe deterioration, overriding all debounces).
2. **Summary Presentation**: Pushes a push notification/pager alert to the doctor. When the doctor opens their Flutter Web Dashboard, the agent presents the XGBoost/SHAP-grounded explanation of the risk.
3. **Action Routing**: Presents actionable buttons (e.g., "Authorize Readmission", "Adjust Prescription"). When the doctor clicks a button, the agent validates the authorization and publishes the doctor's command to the Event Bus, which downstream agents (like Pharmacy or Insurance) will act on.

## Architecture
* **Technology**: Python worker/API backend serving the Flutter Web Dashboard.
* **Integrations**: Push notification services (FCM/APNs), hospital paging systems. Subscribes to `system.agent_commands` on EventBridge.
