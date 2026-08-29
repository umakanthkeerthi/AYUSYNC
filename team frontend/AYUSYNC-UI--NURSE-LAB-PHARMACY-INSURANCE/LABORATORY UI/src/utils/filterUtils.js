export const filterUtils = {
    applyFilters: (records, filters) => {
        return records.filter(r => {
            // Search
            if (filters.search) {
                const searchLower = filters.search.toLowerCase();
                const matches = 
                    r.patientName.toLowerCase().includes(searchLower) ||
                    r.patientId.toLowerCase().includes(searchLower) ||
                    r.testName.toLowerCase().includes(searchLower) ||
                    r.id.toLowerCase().includes(searchLower);
                if (!matches) return false;
            }

            // Status
            if (filters.status && filters.status !== 'All') {
                if (r.status.toLowerCase() !== filters.status.toLowerCase()) return false;
            }

            // Urgency
            if (filters.urgency && filters.urgency !== 'All') {
                if (r.urgency.toLowerCase() !== filters.urgency.toLowerCase()) return false;
            }

            // Risk Level
            if (filters.riskLevel && filters.riskLevel !== 'All') {
                if (r.riskLevel.toLowerCase() !== filters.riskLevel.toLowerCase()) return false;
            }

            // Risk Score Range
            if (filters.minRisk !== undefined && filters.maxRisk !== undefined) {
                if (r.riskScore < filters.minRisk || r.riskScore > filters.maxRisk) return false;
            }

            return true;
        });
    },

    sortRecords: (records, sortBy) => {
        return [...records].sort((a, b) => {
            switch(sortBy) {
                case 'Highest Risk': return b.riskScore - a.riskScore;
                case 'Lowest Risk': return a.riskScore - b.riskScore;
                case 'Earliest Collection': return new Date(a.collectionTime || a.createdAt) - new Date(b.collectionTime || b.createdAt);
                case 'Latest Collection': return new Date(b.collectionTime || b.createdAt) - new Date(a.collectionTime || a.createdAt);
                case 'Patient Name A-Z': return a.patientName.localeCompare(b.patientName);
                case 'Recently Updated': return new Date(b.updatedAt) - new Date(a.updatedAt);
                default: return 0;
            }
        });
    }
};
