import { storageService } from './storageService.js';
import { seedRecords } from '../data/seedData.js';
import { riskUtils } from '../utils/riskUtils.js';

export const labService = {
    init: () => {
        let records = storageService.getRecords();
        if (records.length === 0) {
            // Recalculate dynamic fields on seed
            records = seedRecords.map(r => ({
                ...r,
                riskLevel: riskUtils.getRiskLevel(r.riskScore)
            }));
            storageService.saveRecords(records);
        }
    },

    getAllRecords: () => {
        return storageService.getRecords();
    },

    getRecordById: (id) => {
        const records = storageService.getRecords();
        return records.find(r => r.id === id);
    },

    updateRecord: (updatedRecord) => {
        updatedRecord.updatedAt = new Date().toISOString();
        if (updatedRecord.resultStatus === 'Critical' || updatedRecord.criticalFlag) {
            updatedRecord.status = 'Critical';
            updatedRecord.criticalFlag = true;
        }

        const records = storageService.getRecords();
        const index = records.findIndex(r => r.id === updatedRecord.id);
        if (index !== -1) {
            records[index] = updatedRecord;
            storageService.saveRecords(records);
        }
    },

    getDashboardStats: () => {
        const records = storageService.getRecords();
        return {
            pending: records.filter(r => r.status === 'Pending').length,
            collected: records.filter(r => r.status === 'Collected').length,
            processing: records.filter(r => r.status === 'Processing').length,
            critical: records.filter(r => r.status === 'Critical' || r.criticalFlag).length,
            completed: records.filter(r => r.status === 'Completed').length
        };
    },

    getScheduleQueue: () => {
        const records = storageService.getRecords();
        return records.filter(r => ['Scheduled', 'Pending', 'Collected', 'Processing'].includes(r.status));
    },

    updateStatus: (id, newStatus) => {
        const record = labService.getRecordById(id);
        if (record) {
            record.status = newStatus;
            if (newStatus === 'Completed') {
                // Should only be set via the result form, but as a fallback
                if (!record.resultStatus) record.resultStatus = 'Normal';
            }
            labService.updateRecord(record);
        }
    },

    addResult: (id, resultData) => {
        const record = labService.getRecordById(id);
        if (record) {
            record.status = resultData.resultStatus === 'Critical' ? 'Critical' : 'Completed';
            record.result = resultData.result;
            record.unit = resultData.unit;
            record.referenceRange = resultData.referenceRange;
            record.resultStatus = resultData.resultStatus;
            record.notes = resultData.notes;
            record.criticalFlag = (resultData.resultStatus === 'Critical');
            labService.updateRecord(record);
        }
    }
};
