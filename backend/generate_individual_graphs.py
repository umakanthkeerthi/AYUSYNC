import os
from typing import TypedDict
from langgraph.graph import StateGraph, END

def save_graph(workflow: StateGraph, filename: str):
    app = workflow.compile()
    try:
        img_bytes = app.get_graph().draw_mermaid_png()
        path = f"c:/Users/keert/Desktop/AYUSYNC/agent_graphs/{filename}"
        with open(path, "wb") as f:
            f.write(img_bytes)
        print(f"✅ Generated {filename}")
    except Exception as e:
        print(f"❌ Failed to generate {filename}: {e}")

class State(TypedDict): pass
def node(state: State): return state

# 1. Patient State Agent Graph
state_agent = StateGraph(State)
state_agent.add_node("Receive_Telemetry_Event", node)
state_agent.add_node("Save_Vitals_To_Database", node)
state_agent.add_node("Fire_State_Updated_Event", node)
state_agent.set_entry_point("Receive_Telemetry_Event")
state_agent.add_edge("Receive_Telemetry_Event", "Save_Vitals_To_Database")
state_agent.add_edge("Save_Vitals_To_Database", "Fire_State_Updated_Event")
state_agent.add_edge("Fire_State_Updated_Event", END)
save_graph(state_agent, "patient_state_agent_internal.png")

# 2. Monitoring Agent Graph
monitor = StateGraph(State)
monitor.add_node("Receive_State_Update", node)
monitor.add_node("Evaluate_Clinical_Rules", node)
monitor.add_node("Normal_Vitals", node)
monitor.add_node("Abnormal_Vitals", node)
monitor.add_node("Fire_Risk_Trigger", node)
monitor.set_entry_point("Receive_State_Update")
monitor.add_edge("Receive_State_Update", "Evaluate_Clinical_Rules")
monitor.add_edge("Evaluate_Clinical_Rules", "Normal_Vitals")
monitor.add_edge("Evaluate_Clinical_Rules", "Abnormal_Vitals")
monitor.add_edge("Abnormal_Vitals", "Fire_Risk_Trigger")
monitor.add_edge("Normal_Vitals", END)
monitor.add_edge("Fire_Risk_Trigger", END)
save_graph(monitor, "monitoring_agent_internal.png")

# 3. Risk Predictor Agent Graph
risk = StateGraph(State)
risk.add_node("Receive_Trigger", node)
risk.add_node("Query_PostgreSQL_DB", node)
risk.add_node("Format_Live_API_Payload", node)
risk.add_node("POST_to_ML_API", node)
risk.add_node("Extract_Risk_Level_and_SBAR", node)
risk.add_node("Fire_Analysis_Event", node)
risk.set_entry_point("Receive_Trigger")
risk.add_edge("Receive_Trigger", "Query_PostgreSQL_DB")
risk.add_edge("Query_PostgreSQL_DB", "Format_Live_API_Payload")
risk.add_edge("Format_Live_API_Payload", "POST_to_ML_API")
risk.add_edge("POST_to_ML_API", "Extract_Risk_Level_and_SBAR")
risk.add_edge("Extract_Risk_Level_and_SBAR", "Fire_Analysis_Event")
risk.add_edge("Fire_Analysis_Event", END)
save_graph(risk, "risk_predictor_agent_internal.png")

# 4. Care Planning Agent Graph
plan = StateGraph(State)
plan.add_node("Receive_Risk_Score", node)
plan.add_node("Fetch_Doctor_Protocol", node)
plan.add_node("Evaluate_Thresholds", node)
plan.add_node("Safe_Parameters", node)
plan.add_node("Exceeds_Threshold", node)
plan.add_node("Strictly_Apply_Protocol", node)
plan.set_entry_point("Receive_Risk_Score")
plan.add_edge("Receive_Risk_Score", "Fetch_Doctor_Protocol")
plan.add_edge("Fetch_Doctor_Protocol", "Evaluate_Thresholds")
plan.add_edge("Evaluate_Thresholds", "Safe_Parameters")
plan.add_edge("Evaluate_Thresholds", "Exceeds_Threshold")
plan.add_edge("Exceeds_Threshold", "Strictly_Apply_Protocol")
plan.add_edge("Strictly_Apply_Protocol", END)
plan.add_edge("Safe_Parameters", END)
save_graph(plan, "care_planning_agent_internal.png")

# 5. Care Coordinator Agent Graph
coord = StateGraph(State)
coord.add_node("Receive_Proposed_Plan", node)
coord.add_node("Translate_into_Action", node)
coord.add_node("Schedule_Doctor_Action", node)
coord.add_node("Schedule_Patient_Action", node)
coord.set_entry_point("Receive_Proposed_Plan")
coord.add_edge("Receive_Proposed_Plan", "Translate_into_Action")
coord.add_edge("Translate_into_Action", "Schedule_Doctor_Action")
coord.add_edge("Translate_into_Action", "Schedule_Patient_Action")
coord.add_edge("Schedule_Doctor_Action", END)
coord.add_edge("Schedule_Patient_Action", END)
save_graph(coord, "care_coordinator_agent_internal.png")

# 6. Medication Adherence Agent Graph
med = StateGraph(State)
med.add_node("Receive_Adherence_Trigger", node)
med.add_node("Query_Adherence_Logs", node)
med.add_node("Calculate_30_Day_Score", node)
med.add_node("Fire_Adherence_Event", node)
med.set_entry_point("Receive_Adherence_Trigger")
med.add_edge("Receive_Adherence_Trigger", "Query_Adherence_Logs")
med.add_edge("Query_Adherence_Logs", "Calculate_30_Day_Score")
med.add_edge("Calculate_30_Day_Score", "Fire_Adherence_Event")
med.add_edge("Fire_Adherence_Event", END)
save_graph(med, "medication_adherence_agent_internal.png")
