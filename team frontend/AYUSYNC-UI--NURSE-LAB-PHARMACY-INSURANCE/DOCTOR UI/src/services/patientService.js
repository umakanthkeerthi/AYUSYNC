import { storageService } from './storageService.js';
import { riskUtils } from '../utils/riskUtils.js';

export const patientService = {
    getAllPatients: () => {
        return storageService.getPatients();
    },
    
    getPatientById: (id) => {
        return storageService.getPatients().find(p => p.id === id);
    },

    getDashboardStats: () => {
        const patients = storageService.getPatients();
        let total = patients.length;
        let stable = 0;
        let monitoring = 0;
        let intervention = 0;

        patients.forEach(p => {
            const status = riskUtils.getPatientStatus(p);
            if (status === 'Stable') stable++;
            else if (status === 'Monitoring') monitoring++;
            else if (status === 'Need Intervention') intervention++;
        });

        return { total, stable, monitoring, intervention };
    },

    filterPatients: (filters = {}) => {
        let patients = storageService.getPatients();

        if (filters.search) {
            const q = filters.search.toLowerCase();
            patients = patients.filter(p => 
                p.name.toLowerCase().includes(q) ||
                p.id.toLowerCase().includes(q) ||
                p.diagnosis.toLowerCase().includes(q) ||
                p.condition.toLowerCase().includes(q) ||
                p.recentChanges.some(c => c.toLowerCase().includes(q))
            );
        }

        if (filters.riskLevel && filters.riskLevel !== 'All') {
            patients = patients.filter(p => riskUtils.getRiskLevel(p.riskScore) === filters.riskLevel);
        }

        if (filters.urgency && filters.urgency !== 'All') {
            patients = patients.filter(p => p.urgency === filters.urgency);
        }

        if (filters.minRisk !== undefined && filters.maxRisk !== undefined) {
            patients = patients.filter(p => p.riskScore >= filters.minRisk && p.riskScore <= filters.maxRisk);
        }
        
        if (filters.status && filters.status !== 'All') {
            patients = patients.filter(p => riskUtils.getPatientStatus(p) === filters.status);
        }

        // Sorting
        if (filters.sortBy) {
            switch (filters.sortBy) {
                case 'Highest Risk':
                    patients.sort((a, b) => b.riskScore - a.riskScore);
                    break;
                case 'Lowest Risk':
                    patients.sort((a, b) => a.riskScore - b.riskScore);
                    break;
                case 'Patient Name A-Z':
                    patients.sort((a, b) => a.name.localeCompare(b.name));
                    break;
                case 'Most Recent Update':
                    patients.sort((a, b) => new Date(b.lastUpdated) - new Date(a.lastUpdated));
                    break;
            }
        } else {
            // Default sort: highest risk first
            patients.sort((a, b) => b.riskScore - a.riskScore);
        }

        return patients;
    },

    getInterventionQueue: () => {
        // Patients who need intervention
        const patients = storageService.getPatients();
        return patients.filter(p => riskUtils.getPatientStatus(p) === 'Need Intervention')
                       .sort((a, b) => b.riskScore - a.riskScore);
    }
};
