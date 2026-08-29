import { storageService } from './storageService.js';

export const taskService = {
    getAllTasks: () => {
        return storageService.getTasks();
    },

    getTasksForPatient: (patientId) => {
        return storageService.getTasks().filter(t => t.patientId === patientId);
    },

    addTask: (task) => {
        const tasks = storageService.getTasks();
        tasks.push({
            id: `T${Math.floor(Math.random() * 10000)}`,
            ...task,
            status: 'Pending'
        });
        storageService.saveTasks(tasks);
    },

    updateTaskStatus: (taskId, newStatus) => {
        const tasks = storageService.getTasks();
        const index = tasks.findIndex(t => t.id === taskId);
        if (index !== -1) {
            tasks[index].status = newStatus;
            storageService.saveTasks(tasks);
            return true;
        }
        return false;
    }
};
