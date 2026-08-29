/**
 * @typedef {Object} Patient
 * @property {string} id
 * @property {string} name
 * @property {number} age
 * @property {string} gender
 * @property {string} condition
 * @property {string} status - 'Active' | 'Post Discharge' | 'Completed'
 * @property {string} urgency - 'urgent' | 'follow-up' | 'on-track'
 * @property {string} taskType
 * @property {string} taskDescription
 * @property {string} dischargeDate
 * @property {string} followUpDate
 * @property {string} medicationAdherence - 'High' | 'Medium' | 'Low'
 * @property {string} appointmentStatus
 * @property {string} labStatus
 * @property {string} lastUpdated
 */

/**
 * @typedef {Object} Task
 * @property {string} id
 * @property {string} patientId
 * @property {string} type
 * @property {string} description
 * @property {string} priority - 'High' | 'Medium' | 'Low'
 * @property {string} dueDate
 * @property {string} status - 'Pending' | 'In Progress' | 'Completed'
 * @property {string} assignedNurse
 */

export {};
