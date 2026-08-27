# Monitoring Agent

## Core Functionality
The Monitoring Agent acts as the system's "Watchdog". Its sole purpose is to prevent computationally expensive AI agents (like the Risk Prediction Agent) from constantly polling the database. It saves money and compute resources by only firing triggers when necessary.

## How It Works
1. **Observation**: It observes the clean, structured data outputted by the Patient State Agent.
2. **Deterministic Rules**: It applies lightweight, hardcoded logic rules. For example: `IF new_lab_result_received == TRUE THEN fire trigger.risk_assessment`. 
3. **Trigger Generation**: When a rule threshold is met, it publishes a specific internal trigger to the Event Bus, waking up the heavier Thinking Agents.

## Architecture
* **Technology**: Python microservice running on AWS ECS (Fargate).
* **Logic Engine**: A lightweight deterministic rules engine (simple Python conditional statements, no ML/LLMs).
* **Integration**: Subscribes to state updates from the Patient State Agent and publishes `trigger.*` events to Amazon EventBridge.
