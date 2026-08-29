import { storageService } from './storageService.js';
import { seedData } from '../data/seedData.js';
import { riskUtils } from '../utils/riskUtils.js';

export const pharmacyService = {
    init: () => {
        let data = storageService.getData();
        if (data.prescriptions.length === 0) {
            // Recalculate risk levels on seed
            data.prescriptions = seedData.prescriptions.map(r => ({
                ...r,
                riskLevel: riskUtils.getRiskLevel(r.riskScore)
            }));
            data.refills = seedData.refills.map(r => ({ ...r }));
            data.deliveries = seedData.deliveries.map(r => ({ ...r }));
            data.inventory = seedData.inventory.map(r => ({ ...r }));
            data.notifications = [
                { id: 'N1', type: 'Urgent Prescription', msg: 'Urgent prescription received for Sohan Das.', read: false },
                { id: 'N2', type: 'Low Stock', msg: 'Atorvastatin 20mg stock is below reorder level.', read: false }
            ];
            storageService.saveData(data);
        }
    },

    getData: () => storageService.getData(),

    updatePrescriptionStatus: (id, newStatus) => {
        const data = storageService.getData();
        const rx = data.prescriptions.find(r => r.id === id);
        if (rx) {
            rx.status = newStatus;
            storageService.saveData(data);
        }
    },
    
    updateRefillStatus: (id, newStatus) => {
        const data = storageService.getData();
        const rf = data.refills.find(r => r.id === id);
        if (rf) {
            rf.status = newStatus;
            storageService.saveData(data);
        }
    },

    updateDeliveryStatus: (id, newStatus) => {
        const data = storageService.getData();
        const dl = data.deliveries.find(r => r.id === id);
        if (dl) {
            dl.status = newStatus;
            storageService.saveData(data);
        }
    },

    addPrescription: (newRx) => {
        const data = storageService.getData();
        newRx.id = `RX-2026-${Math.floor(1000 + Math.random()*9000)}`;
        newRx.status = 'New';
        newRx.date = new Date().toISOString();
        newRx.riskLevel = riskUtils.getRiskLevel(newRx.riskScore || 0);
        data.prescriptions.unshift(newRx);
        storageService.saveData(data);
        return newRx;
    },

    getDashboardStats: () => {
        const data = storageService.getData();
        return {
            newPrescriptions: data.prescriptions.filter(r => r.status === 'New').length,
            refills: data.refills.filter(r => ['Requested', 'Under Review'].includes(r.status)).length,
            deliveryPending: data.deliveries.filter(r => r.status === 'Pending').length,
            urgent: data.prescriptions.filter(r => r.urgency === 'Urgent' && !['Dispensed', 'Cancelled'].includes(r.status)).length
        };
    }
};
