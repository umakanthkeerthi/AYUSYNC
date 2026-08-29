import { storageService } from './storageService.js';

export const patientService = {
    getAllPatients: () => {
        return storageService.getPatients();
    },

    getPatientById: (id) => {
        return storageService.getPatients().find(p => p.id === id);
    },

    updatePatientUrgency: (id, newUrgency) => {
        const patients = storageService.getPatients();
        const index = patients.findIndex(p => p.id === id);
        if (index !== -1) {
            patients[index].urgency = newUrgency;
            patients[index].lastUpdated = new Date().toISOString();
            storageService.savePatients(patients);
            return true;
        }
        return false;
    },

    getDashboardStats: () => {
        const patients = storageService.getPatients();
        return {
            urgent: patients.filter(p => p.urgency === 'urgent').length,
            followUp: patients.filter(p => p.urgency === 'follow-up').length,
            onTrack: patients.filter(p => p.urgency === 'on-track').length,
            total: patients.length
        };
    },

    filterPatients: (filters, searchQuery = '') => {
        let patients = storageService.getPatients();

        // Search
        if (searchQuery) {
            const query = searchQuery.toLowerCase();
            patients = patients.filter(p => 
                p.name.toLowerCase().includes(query) ||
                p.id.toLowerCase().includes(query) ||
                p.condition.toLowerCase().includes(query) ||
                p.taskType.toLowerCase().includes(query) ||
                p.status.toLowerCase().includes(query)
            );
        }

        // Filtering
        if (filters.urgency && filters.urgency !== 'All') {
            patients = patients.filter(p => p.urgency === filters.urgency);
        }
        if (filters.taskType && filters.taskType !== 'All') {
            patients = patients.filter(p => p.taskType === filters.taskType);
        }
        if (filters.status && filters.status !== 'All') {
            patients = patients.filter(p => p.status === filters.status);
        }

        // Sorting
        if (filters.sortBy) {
            switch (filters.sortBy) {
                case 'Highest urgency':
                    const priorityWeight = { 'urgent': 3, 'follow-up': 2, 'on-track': 1 };
                    patients.sort((a, b) => priorityWeight[b.urgency] - priorityWeight[a.urgency]);
                    break;
                case 'Most recent':
                    patients.sort((a, b) => new Date(b.lastUpdated) - new Date(a.lastUpdated));
                    break;
                case 'Oldest':
                    patients.sort((a, b) => new Date(a.lastUpdated) - new Date(b.lastUpdated));
                    break;
                case 'Patient name A-Z':
                    patients.sort((a, b) => a.name.localeCompare(b.name));
                    break;
            }
        }

        return patients;
    }
};
