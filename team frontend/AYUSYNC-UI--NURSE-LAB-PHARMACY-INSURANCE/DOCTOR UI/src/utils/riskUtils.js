export const riskUtils = {
    getRiskLevel: (score) => {
        if (score >= 70) return 'High Risk';
        if (score >= 40) return 'Medium Risk';
        return 'Low Risk';
    },
    
    getRiskClass: (score) => {
        if (score >= 70) return 'risk-high';
        if (score >= 40) return 'risk-medium';
        return 'risk-low';
    },

    getUrgencyClass: (urgency) => {
        switch (urgency) {
            case 'Urgent': return 'badge-danger';
            case 'Follow-up': return 'badge-warning';
            default: return 'badge-success';
        }
    },
    
    getPatientStatus: (patient) => {
        // Needs Intervention if High Risk, Urgent, or Critical Labs
        if (patient.riskScore >= 70 || patient.urgency === 'Urgent' || patient.labStatus === 'Abnormal' || patient.interventionStatus === 'Required') {
            return 'Need Intervention';
        }
        
        // Monitoring if Medium Risk or Follow-up urgency
        if (patient.riskScore >= 40 || patient.urgency === 'Follow-up') {
            return 'Monitoring';
        }
        
        return 'Stable';
    }
};
