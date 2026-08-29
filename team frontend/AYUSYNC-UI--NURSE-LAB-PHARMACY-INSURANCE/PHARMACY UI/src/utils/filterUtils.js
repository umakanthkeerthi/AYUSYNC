export const filterUtils = {
    applyFilters: (records, filters) => {
        return records.filter(r => {
            // Text Search
            if (filters.search) {
                const searchLower = filters.search.toLowerCase();
                const textToSearch = [
                    r.patientName, r.patientId, r.id, r.prescriptionId,
                    r.prescribedBy, r.medications, r.medicine, r.category
                ].filter(Boolean).join(' ').toLowerCase();
                
                if (!textToSearch.includes(searchLower)) return false;
            }

            // Status fields
            if (filters.status && filters.status !== 'All') {
                const recordStatus = r.prescriptionStatus || r.status || r.stockStatus || r.deliveryStatus;
                if (recordStatus && recordStatus.toLowerCase() !== filters.status.toLowerCase()) return false;
            }

            // Urgency
            if (filters.urgency && filters.urgency !== 'All') {
                if (r.urgency && r.urgency.toLowerCase() !== filters.urgency.toLowerCase()) return false;
            }

            // Risk Score Range
            if (filters.minRisk !== undefined && filters.maxRisk !== undefined && r.riskScore !== undefined) {
                if (r.riskScore < filters.minRisk || r.riskScore > filters.maxRisk) return false;
            }

            return true;
        });
    },

    sortRecords: (records, sortBy) => {
        return [...records].sort((a, b) => {
            switch(sortBy) {
                case 'Highest Risk': return (b.riskScore || 0) - (a.riskScore || 0);
                case 'Highest Urgency': 
                    const u = {'urgent': 3, 'priority': 2, 'routine': 1};
                    return (u[(b.urgency||'').toLowerCase()] || 0) - (u[(a.urgency||'').toLowerCase()] || 0);
                case 'Newest': return new Date(b.createdAt || b.date || 0) - new Date(a.createdAt || a.date || 0);
                case 'Oldest': return new Date(a.createdAt || a.date || 0) - new Date(b.createdAt || b.date || 0);
                case 'Patient A-Z': return (a.patientName || '').localeCompare(b.patientName || '');
                default: return 0;
            }
        });
    }
};
