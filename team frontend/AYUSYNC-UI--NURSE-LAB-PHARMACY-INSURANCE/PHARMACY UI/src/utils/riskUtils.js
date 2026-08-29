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

    getUrgencyBadgeClass: (urgency) => {
        switch(urgency.toLowerCase()) {
            case 'urgent': return 'badge-danger';
            case 'priority': return 'badge-warning';
            case 'routine': return 'badge-success';
            default: return 'badge-gray';
        }
    },

    getPrescriptionStatusBadge: (status) => {
        switch(status.toLowerCase()) {
            case 'new': return 'badge-orange';
            case 'verified': return 'badge-info';
            case 'preparing': return 'badge-purple';
            case 'ready': return 'badge-success';
            case 'dispensed': return 'badge-gray';
            case 'cancelled': return 'badge-danger';
            default: return 'badge-gray';
        }
    },
    
    getDeliveryStatusBadge: (status) => {
        switch(status.toLowerCase()) {
            case 'pending': return 'badge-orange';
            case 'out for delivery': return 'badge-info';
            case 'delivered': return 'badge-success';
            case 'failed': return 'badge-danger';
            default: return 'badge-gray';
        }
    },

    getInventoryStatusBadge: (status) => {
        switch(status.toLowerCase()) {
            case 'in stock': return 'badge-success';
            case 'low stock': return 'badge-warning';
            case 'out of stock': return 'badge-danger';
            case 'expiring soon': return 'badge-purple';
            default: return 'badge-gray';
        }
    }
};
