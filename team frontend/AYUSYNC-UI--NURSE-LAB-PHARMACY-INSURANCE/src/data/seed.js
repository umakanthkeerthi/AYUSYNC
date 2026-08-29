export const initialPatients = [
    {
        id: "P1001", name: "Rahul Kumar", age: 45, gender: "Male",
        condition: "Medication adherence low", status: "Active", urgency: "urgent",
        taskType: "Medication", taskDescription: "Review adherence and adjust dosage",
        dischargeDate: "2026-08-17", followUpDate: "2026-08-25",
        medicationAdherence: "Low", appointmentStatus: "Scheduled", labStatus: "Completed",
        lastUpdated: "2026-08-22T10:00:00Z"
    },
    {
        id: "P1002", name: "Priya Sharma", age: 32, gender: "Female",
        condition: "Lab report pending", status: "Post Discharge", urgency: "follow-up",
        taskType: "Lab Test", taskDescription: "Check CBC results",
        dischargeDate: "2026-08-19", followUpDate: "2026-08-23",
        medicationAdherence: "High", appointmentStatus: "Confirmed", labStatus: "Pending",
        lastUpdated: "2026-08-22T11:30:00Z"
    },
    {
        id: "P1003", name: "Arjun Rao", age: 60, gender: "Male",
        condition: "Appointment not confirmed", status: "Active", urgency: "follow-up",
        taskType: "Appointment", taskDescription: "Call patient to confirm cardiology consult",
        dischargeDate: "2026-08-15", followUpDate: "2026-08-24",
        medicationAdherence: "Medium", appointmentStatus: "Not Confirmed", labStatus: "Completed",
        lastUpdated: "2026-08-21T14:20:00Z"
    },
    {
        id: "P1004", name: "Meera Iyer", age: 28, gender: "Female",
        condition: "Recovery progressing normally", status: "Completed", urgency: "on-track",
        taskType: "General", taskDescription: "Routine wellness check",
        dischargeDate: "2026-08-18", followUpDate: "2026-08-26",
        medicationAdherence: "High", appointmentStatus: "Confirmed", labStatus: "Completed",
        lastUpdated: "2026-08-20T09:15:00Z"
    },
    {
        id: "P1005", name: "Ananya Patel", age: 55, gender: "Female",
        condition: "High Blood Pressure spike", status: "Active", urgency: "urgent",
        taskType: "Medication", taskDescription: "Administer Stat dose and monitor",
        dischargeDate: "2026-08-21", followUpDate: "2026-08-22",
        medicationAdherence: "Low", appointmentStatus: "Confirmed", labStatus: "Pending",
        lastUpdated: "2026-08-22T08:45:00Z"
    },
    {
        id: "P1006", name: "Vikram Singh", age: 72, gender: "Male",
        condition: "Post-op wound care", status: "Post Discharge", urgency: "follow-up",
        taskType: "Follow-up", taskDescription: "Check dressing and signs of infection",
        dischargeDate: "2026-08-16", followUpDate: "2026-08-23",
        medicationAdherence: "High", appointmentStatus: "Scheduled", labStatus: "Completed",
        lastUpdated: "2026-08-21T16:00:00Z"
    },
    {
        id: "P1007", name: "Sneha Reddy", age: 41, gender: "Female",
        condition: "Awaiting MRI results", status: "Active", urgency: "follow-up",
        taskType: "Lab Test", taskDescription: "Coordinate with radiology",
        dischargeDate: "2026-08-20", followUpDate: "2026-08-24",
        medicationAdherence: "High", appointmentStatus: "Confirmed", labStatus: "Pending",
        lastUpdated: "2026-08-22T13:10:00Z"
    },
    {
        id: "P1008", name: "Karan Mehta", age: 38, gender: "Male",
        condition: "Allergic reaction reported", status: "Active", urgency: "urgent",
        taskType: "General", taskDescription: "Assess allergy severity and update chart",
        dischargeDate: "2026-08-22", followUpDate: "2026-08-22",
        medicationAdherence: "Medium", appointmentStatus: "Not Confirmed", labStatus: "Completed",
        lastUpdated: "2026-08-22T14:05:00Z"
    },
    {
        id: "P1009", name: "Neha Kapoor", age: 25, gender: "Female",
        condition: "Routine maternal check", status: "Completed", urgency: "on-track",
        taskType: "Appointment", taskDescription: "Monthly checkup",
        dischargeDate: "2026-07-22", followUpDate: "2026-08-28",
        medicationAdherence: "High", appointmentStatus: "Confirmed", labStatus: "Completed",
        lastUpdated: "2026-08-15T10:00:00Z"
    },
    {
        id: "P1010", name: "Aditya Rao", age: 65, gender: "Male",
        condition: "Diabetic ketoacidosis risk", status: "Active", urgency: "urgent",
        taskType: "Medication", taskDescription: "Monitor insulin intake closely",
        dischargeDate: "2026-08-19", followUpDate: "2026-08-23",
        medicationAdherence: "Low", appointmentStatus: "Scheduled", labStatus: "Pending",
        lastUpdated: "2026-08-22T11:45:00Z"
    },
    {
        id: "P1011", name: "Rajesh Khanna", age: 50, gender: "Male",
        condition: "Chest pain", status: "Active", urgency: "urgent",
        taskType: "Lab Test", taskDescription: "ECG and Troponin levels",
        dischargeDate: "2026-08-22", followUpDate: "2026-08-22",
        medicationAdherence: "High", appointmentStatus: "Confirmed", labStatus: "Pending",
        lastUpdated: "2026-08-22T15:20:00Z"
    },
    {
        id: "P1012", name: "Sunita Verma", age: 29, gender: "Female",
        condition: "Post-partum care", status: "Post Discharge", urgency: "on-track",
        taskType: "Follow-up", taskDescription: "Call for wellness check",
        dischargeDate: "2026-08-18", followUpDate: "2026-08-25",
        medicationAdherence: "High", appointmentStatus: "Scheduled", labStatus: "Completed",
        lastUpdated: "2026-08-20T12:30:00Z"
    },
    {
        id: "P1013", name: "Amitabh Bachchan", age: 80, gender: "Male",
        condition: "Joint pain assessment", status: "Active", urgency: "follow-up",
        taskType: "Appointment", taskDescription: "Orthopedic consult",
        dischargeDate: "2026-08-10", followUpDate: "2026-08-27",
        medicationAdherence: "Medium", appointmentStatus: "Not Confirmed", labStatus: "Completed",
        lastUpdated: "2026-08-21T09:00:00Z"
    },
    {
        id: "P1014", name: "Kareena Kapoor", age: 42, gender: "Female",
        condition: "Migraine management", status: "Completed", urgency: "on-track",
        taskType: "Medication", taskDescription: "Refill prescription",
        dischargeDate: "2026-08-01", followUpDate: "2026-09-01",
        medicationAdherence: "High", appointmentStatus: "Confirmed", labStatus: "Completed",
        lastUpdated: "2026-08-10T14:15:00Z"
    },
    {
        id: "P1015", name: "Shahrukh Khan", age: 58, gender: "Male",
        condition: "Back injury rehab", status: "Post Discharge", urgency: "follow-up",
        taskType: "General", taskDescription: "Physiotherapy progress check",
        dischargeDate: "2026-08-15", followUpDate: "2026-08-29",
        medicationAdherence: "High", appointmentStatus: "Scheduled", labStatus: "Completed",
        lastUpdated: "2026-08-21T11:10:00Z"
    },
    {
        id: "P1016", name: "Aishwarya Rai", age: 49, gender: "Female",
        condition: "Thyroid level check", status: "Active", urgency: "follow-up",
        taskType: "Lab Test", taskDescription: "Review TSH levels",
        dischargeDate: "2026-08-20", followUpDate: "2026-08-26",
        medicationAdherence: "High", appointmentStatus: "Confirmed", labStatus: "Pending",
        lastUpdated: "2026-08-22T08:00:00Z"
    }
];

export const initialTasks = [
    {
        id: "T101", patientId: "P1001", type: "Medication", description: "Review adherence and adjust dosage", priority: "High", dueDate: "2026-08-22", status: "Pending", assignedNurse: "Nurse Priya"
    },
    {
        id: "T102", patientId: "P1002", type: "Lab Test", description: "Check CBC results", priority: "Medium", dueDate: "2026-08-23", status: "Pending", assignedNurse: "Nurse Priya"
    },
    {
        id: "T103", patientId: "P1005", type: "Medication", description: "Administer Stat dose and monitor", priority: "High", dueDate: "2026-08-22", status: "In Progress", assignedNurse: "Nurse Priya"
    }
];
