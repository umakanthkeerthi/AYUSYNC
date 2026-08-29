import { initialPatients } from '../data/seedData.js';

const STORAGE_KEY = 'ayusync_doctor_patients';

export const storageService = {
    init: () => {
        if (!localStorage.getItem(STORAGE_KEY)) {
            localStorage.setItem(STORAGE_KEY, JSON.stringify(initialPatients));
        }
    },

    getPatients: () => {
        return JSON.parse(localStorage.getItem(STORAGE_KEY) || '[]');
    },

    savePatients: (patients) => {
        localStorage.setItem(STORAGE_KEY, JSON.stringify(patients));
    },

    updatePatient: (id, updates) => {
        const patients = storageService.getPatients();
        const index = patients.findIndex(p => p.id === id);
        if (index !== -1) {
            patients[index] = { ...patients[index], ...updates, lastUpdated: new Date().toISOString() };
            storageService.savePatients(patients);
            return patients[index];
        }
        return null;
    },
    
    resetData: () => {
        localStorage.setItem(STORAGE_KEY, JSON.stringify(initialPatients));
    }
};
