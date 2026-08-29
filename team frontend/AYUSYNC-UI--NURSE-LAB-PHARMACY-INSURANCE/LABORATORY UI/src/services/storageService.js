const STORAGE_KEY = 'ayusync_lab_records';
const SETTINGS_KEY = 'ayusync_lab_settings';

export const storageService = {
    getRecords: () => {
        const data = localStorage.getItem(STORAGE_KEY);
        return data ? JSON.parse(data) : [];
    },
    
    saveRecords: (records) => {
        localStorage.setItem(STORAGE_KEY, JSON.stringify(records));
    },
    
    getSettings: () => {
        const data = localStorage.getItem(SETTINGS_KEY);
        return data ? JSON.parse(data) : {};
    },
    
    saveSettings: (settings) => {
        localStorage.setItem(SETTINGS_KEY, JSON.stringify(settings));
    },

    clearAll: () => {
        localStorage.removeItem(STORAGE_KEY);
        localStorage.removeItem(SETTINGS_KEY);
    }
};
