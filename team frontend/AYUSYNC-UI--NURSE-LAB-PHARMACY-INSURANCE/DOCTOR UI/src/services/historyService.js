const STORAGE_KEY = 'ayusync_doctor_history';

export const historyService = {
    init: () => {
        if (!localStorage.getItem(STORAGE_KEY) || JSON.parse(localStorage.getItem(STORAGE_KEY)).length === 0) {
            const mockHistory = [
                {
                    id: 'hist-1', patientId: 'PT-1001', doctorName: 'Dr. Mehta',
                    createdAt: new Date(Date.now() - 86400000 * 2).toISOString(), // 2 days ago
                    currentCondition: 'Patient reported slight dizziness in the morning.',
                    doctorsNotes: 'BP slightly elevated. Advised to reduce sodium intake.',
                    recentChanges: ['BP 145/90'], assessment: 'Mild hypertension flare-up.',
                    plan: 'Monitor BP daily for a week.', followUpRequired: false
                },
                {
                    id: 'hist-2', patientId: 'PT-1005', doctorName: 'Dr. Mehta',
                    createdAt: new Date(Date.now() - 86400000).toISOString(), // 1 day ago
                    currentCondition: 'Experiencing shortness of breath at rest.',
                    doctorsNotes: 'Symptoms indicate worsening heart failure. Patient gained 2kg in 24 hours.',
                    recentChanges: ['Weight +2kg', 'SpO2 93%'], assessment: 'Fluid overload secondary to CHF.',
                    plan: 'Increase Diuretic dosage.', followUpRequired: true, followUpDate: new Date(Date.now() + 86400000).toISOString().split('T')[0], followUpNotes: 'Check weight and breathing.'
                },
                {
                    id: 'hist-3', patientId: 'PT-1005', doctorName: 'Dr. Sharma',
                    createdAt: new Date(Date.now() - 86400000 * 5).toISOString(), // 5 days ago
                    currentCondition: 'Routine checkup post-discharge.',
                    doctorsNotes: 'Patient was stable. Prescribed standard CHF regimen.',
                    recentChanges: [], assessment: 'Stable post-discharge.',
                    plan: 'Continue current meds.', followUpRequired: false
                }
            ];
            localStorage.setItem(STORAGE_KEY, JSON.stringify(mockHistory));
        }
    },

    getAllHistory: () => {
        return JSON.parse(localStorage.getItem(STORAGE_KEY) || '[]');
    },

    getHistoryForPatient: (patientId) => {
        const history = historyService.getAllHistory();
        return history.filter(h => h.patientId === patientId).sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
    },
    
    getHistoryEntry: (id) => {
        return historyService.getAllHistory().find(h => h.id === id);
    },

    saveEntry: (entry) => {
        const history = historyService.getAllHistory();
        
        if (entry.id) {
            // Update
            const index = history.findIndex(h => h.id === entry.id);
            if (index !== -1) {
                history[index] = { ...history[index], ...entry, updatedAt: new Date().toISOString() };
            }
        } else {
            // Create
            entry.id = 'hist-' + Date.now().toString(36) + Math.random().toString(36).substr(2);
            entry.createdAt = entry.createdAt || new Date().toISOString();
            entry.updatedAt = entry.createdAt;
            history.push(entry);
        }
        
        localStorage.setItem(STORAGE_KEY, JSON.stringify(history));
        return entry;
    },

    deleteEntry: (id) => {
        const history = historyService.getAllHistory();
        const filtered = history.filter(h => h.id !== id);
        localStorage.setItem(STORAGE_KEY, JSON.stringify(filtered));
    }
};
