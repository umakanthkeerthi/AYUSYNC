from typing import TypedDict, Annotated
from langgraph.graph import StateGraph, END

class AgentState(TypedDict):
    patient_id: str
    raw_text: str
    vitals_recorded: bool
    risk_score: int
    needs_action: bool

def patient_agent(state: AgentState): return state
def patient_state_agent(state: AgentState): return state
def monitoring_agent(state: AgentState): return state
def risk_predictor_agent(state: AgentState): return state
def care_planning_agent(state: AgentState): return state
def care_coordinator_agent(state: AgentState): return state
def medication_adherence_agent(state: AgentState): return state

# 1. Initialize Graph
workflow = StateGraph(AgentState)

# 2. Add Nodes (The 6 Thinking Agents)
workflow.add_node("Patient_State_Agent", patient_state_agent)
workflow.add_node("Monitoring_Agent", monitoring_agent)
workflow.add_node("Risk_Predictor_Agent", risk_predictor_agent)
workflow.add_node("Care_Planning_Agent", care_planning_agent)
workflow.add_node("Care_Coordinator_Agent", care_coordinator_agent)
workflow.add_node("Medication_Adherence_Agent", medication_adherence_agent)

# 3. Define Edges (The Chain Reaction)
workflow.set_entry_point("Patient_State_Agent")
workflow.add_edge("Patient_State_Agent", "Monitoring_Agent")

# From Monitoring Agent, it branches to Risk or Adherence (or both)
workflow.add_edge("Monitoring_Agent", "Risk_Predictor_Agent")
workflow.add_edge("Monitoring_Agent", "Medication_Adherence_Agent")

# Both Risk and Adherence feed into Care Planning
workflow.add_edge("Risk_Predictor_Agent", "Care_Planning_Agent")
workflow.add_edge("Medication_Adherence_Agent", "Care_Planning_Agent")

workflow.add_edge("Care_Planning_Agent", "Care_Coordinator_Agent")
workflow.add_edge("Care_Coordinator_Agent", END)

# 4. Compile Graph
app = workflow.compile()

# 5. Export to PNG
try:
    img_bytes = app.get_graph().draw_mermaid_png()
    with open("../agent_graphs/thinking_agents_architecture.png", "wb") as f:
        f.write(img_bytes)
    print("✅ Successfully generated LangGraph diagram at agent_graphs/thinking_agents_architecture.png")
except Exception as e:
    print(f"❌ Failed to generate diagram: {str(e)}")
