import { initialPatients, initialTasks } from '../data/seed.js';

export const storageService = {
    getPatients: () => {
        const data = localStorage.getItem('ayusync_patients');
        if (!data) {
            localStorage.setItem('ayusync_patients', JSON.stringify(initialPatients));
            return initialPatients;
        }
        return JSON.parse(data);
    },
    
    savePatients: (patients) => {
        localStorage.setItem('ayusync_patients', JSON.stringify(patients));
    },

    getTasks: () => {
        const data = localStorage.getItem('ayusync_tasks');
        if (!data) {
            localStorage.setItem('ayusync_tasks', JSON.stringify(initialTasks));
            return initialTasks;
        }
        return JSON.parse(data);
    },

    saveTasks: (tasks) => {
        localStorage.setItem('ayusync_tasks', JSON.stringify(tasks));
    }
};
