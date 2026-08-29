import { storageService } from './storageService.js';

export const inventoryService = {
    getAll: () => {
        return storageService.getData().inventory;
    },
    
    updateQuantity(id, changeAmount) {
        const data = storageService.getData();
        const item = data.inventory.find(i => i.id === id);
        if(item) {
            item.available += parseInt(changeAmount);
            if(item.available < 0) item.available = 0;
            
            // Recalculate status
            if(item.available === 0) item.status = 'Out of Stock';
            else if(item.available <= item.reorderLevel) item.status = 'Low Stock';
            else {
                item.status = 'In Stock'; 
            }
            
            storageService.saveData(data);
        }
    },
    
    checkAlerts: () => {
        const inv = storageService.getData().inventory;
        const alerts = [];
        inv.forEach(item => {
            if (item.available === 0) alerts.push(`Out of Stock: ${item.medicine}`);
            else if (item.available < item.reorderLevel) alerts.push(`Low Stock: ${item.medicine}`);
            
            // Check expiry within 30 days
            const expDate = new Date(item.expiry);
            const now = new Date();
            const diffDays = Math.ceil((expDate - now) / (1000 * 60 * 60 * 24));
            if (diffDays > 0 && diffDays <= 30) {
                alerts.push(`Expiring Soon: ${item.medicine} (in ${diffDays} days)`);
            }
        });
        return alerts;
    }
};
