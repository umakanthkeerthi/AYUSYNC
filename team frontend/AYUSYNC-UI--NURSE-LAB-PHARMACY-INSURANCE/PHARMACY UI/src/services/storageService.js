const STORAGE_KEY = 'ayusync_pharmacy_data';

export const storageService = {
    getData: () => {
        const data = localStorage.getItem(STORAGE_KEY);
        return data ? JSON.parse(data) : {
            prescriptions: [],
            refills: [],
            deliveries: [],
            inventory: [],
            notifications: []
        };
    },
    
    saveData: (data) => {
        localStorage.setItem(STORAGE_KEY, JSON.stringify(data));
    },

    clearAll: () => {
        localStorage.removeItem(STORAGE_KEY);
    }
};
