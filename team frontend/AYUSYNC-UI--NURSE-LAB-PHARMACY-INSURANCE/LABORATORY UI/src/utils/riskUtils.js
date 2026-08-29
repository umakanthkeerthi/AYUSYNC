export const riskUtils = {
    getRiskLevel: (score) => {
        if (score >= 70) return 'High';
        if (score >= 40) return 'Medium';
        return 'Low';
    },

    getRiskBadgeClass: (score) => {
        if (score >= 70) return 'badge-danger';
        if (score >= 40) return 'badge-warning';
        return 'badge-success';
    },

    getStatusBadgeClass: (status) => {
        switch(status.toLowerCase()) {
            case 'scheduled': return 'badge-gray';
            case 'pending': return 'badge-orange';
            case 'collected': return 'badge-info';
            case 'processing': return 'badge-purple'; // Need to add to CSS
            case 'completed': return 'badge-success';
            case 'critical': return 'badge-danger';
            case 'cancelled': return 'badge-gray';
            default: return 'badge-gray';
        }
    },

    getUrgencyBadgeClass: (urgency) => {
        switch(urgency.toLowerCase()) {
            case 'urgent': return 'badge-danger';
            case 'priority': return 'badge-warning';
            case 'routine': return 'badge-success';
            default: return 'badge-gray';
        }
    }
};
