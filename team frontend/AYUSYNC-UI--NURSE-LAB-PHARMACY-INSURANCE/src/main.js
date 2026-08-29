import { patientService } from './services/patientService.js';
import { taskService } from './services/taskService.js';

// State
let currentFilters = {
    urgency: 'All',
    taskType: 'All',
    status: 'All',
    sortBy: 'Highest urgency'
};
let searchQuery = '';

// DOM Elements
const els = {
    patientList: document.getElementById('patient-list'),
    
    // Stats
    statUrgent: document.getElementById('stat-urgent'),
    statFollowup: document.getElementById('stat-followup'),
    statOntrack: document.getElementById('stat-ontrack'),
    statTotal: document.getElementById('stat-total'),
    statCards: document.querySelectorAll('.filter-card'),
    
    // Search & Filters
    searchInput: document.getElementById('search-input'),
    toggleFilterPanel: document.getElementById('toggle-filter-panel'),
    filterPanel: document.getElementById('filter-panel'),
    clearFilters: document.getElementById('clear-filters'),
    filterUrgency: document.getElementById('filter-urgency'),
    filterTasktype: document.getElementById('filter-tasktype'),
    filterStatus: document.getElementById('filter-status'),
    filterSort: document.getElementById('filter-sort'),
    resultsCount: document.getElementById('results-count'),

    // Sidebar
    sidebar: document.getElementById('sidebar'),
    sidebarOverlay: document.getElementById('sidebar-overlay'),
    mobileMenuToggle: document.getElementById('mobile-menu-toggle'),
    closeSidebarBtn: document.getElementById('close-sidebar'),
    navItems: document.querySelectorAll('.nav-item'),
    pageContent: document.getElementById('page-content'),
    placeholderPage: document.getElementById('placeholder-page'),
    pageTitle: document.getElementById('page-title'),

    // New Views
    patientsView: document.getElementById('patients-view'),
    allPatientsTbody: document.getElementById('all-patients-tbody'),
    tasksView: document.getElementById('tasks-view'),
    tasksPending: document.getElementById('tasks-pending'),
    tasksInprogress: document.getElementById('tasks-inprogress'),
    tasksCompleted: document.getElementById('tasks-completed'),
    countPending: document.getElementById('count-pending'),
    countInprogress: document.getElementById('count-inprogress'),
    countCompleted: document.getElementById('count-completed'),

    // Dropdowns
    notifBtn: document.getElementById('notif-btn'),
    notifDropdown: document.getElementById('notif-dropdown'),
    notifCount: document.getElementById('notif-count'),
    notifList: document.getElementById('notif-list'),
    profileBtn: document.getElementById('profile-btn'),
    profileDropdown: document.getElementById('profile-dropdown'),

    // Modal
    modalOverlay: document.getElementById('patient-modal'),
    modalTitle: document.getElementById('modal-title'),
    modalPatientId: document.getElementById('modal-patient-id'),
    modalOverview: document.getElementById('modal-overview'),
    modalStatus: document.getElementById('modal-status'),
    modalTasks: document.getElementById('modal-tasks'),
    closeModalBtns: document.querySelectorAll('.close-modal'),
    actionBtns: document.querySelectorAll('.action-btn')
};

// --- INIT ---
function init() {
    setupEventListeners();
    updateDashboard();
}

// --- CORE RENDERING ---
function updateDashboard() {
    const stats = patientService.getDashboardStats();
    els.statUrgent.textContent = stats.urgent;
    els.statFollowup.textContent = stats.followUp;
    els.statOntrack.textContent = stats.onTrack;
    els.statTotal.textContent = stats.total;

    renderPatientQueue();
    updateNotifications();
    renderPatientsDirectory();
    renderTasksBoard();
    renderLabCoordination();
    renderAppointments();
    renderAlerts();
    renderMessages();
    renderReports();
}

function renderPatientQueue() {
    const patients = patientService.filterPatients(currentFilters, searchQuery);
    els.patientList.innerHTML = '';
    els.resultsCount.textContent = `Showing ${patients.length} patients`;

    if (patients.length === 0) {
        els.patientList.innerHTML = `<div class="empty-state">No matching records found.</div>`;
        return;
    }

    patients.forEach(p => {
        const priorityClass = 
            p.urgency === 'urgent' ? 'badge-urgent' :
            p.urgency === 'follow-up' ? 'badge-followup' : 'badge-ontrack';
        
        const priorityLabel = 
            p.urgency === 'urgent' ? 'Urgent' :
            p.urgency === 'follow-up' ? 'Follow-up' : 'On Track';

        const row = document.createElement('div');
        row.className = 'patient-row';
        row.innerHTML = `
            <div class="patient-info-col">
                <img src="https://ui-avatars.com/api/?name=${encodeURIComponent(p.name)}&background=random" alt="${p.name}" class="emoji-avatar" style="border-radius:50%; object-fit:cover;">
                <div class="patient-details">
                    <h3>${p.name}</h3>
                    <p>${p.condition}</p>
                    <span class="patient-meta">Age ${p.age} • ${p.status}</span>
                </div>
            </div>
            <div class="patient-actions-col">
                <span class="priority-badge ${priorityClass}">${priorityLabel}</span>
                <button class="btn btn-outline view-btn" data-id="${p.id}">View</button>
            </div>
        `;
        els.patientList.appendChild(row);
    });

    document.querySelectorAll('.view-btn').forEach(btn => {
        btn.addEventListener('click', (e) => openModal(e.currentTarget.getAttribute('data-id')));
    });
}

function updateNotifications() {
    const urgentPatients = patientService.filterPatients({urgency: 'urgent'});
    els.notifCount.textContent = urgentPatients.length;
    els.notifCount.style.display = urgentPatients.length > 0 ? 'inline-block' : 'none';

    els.notifList.innerHTML = '';
    if (urgentPatients.length === 0) {
        els.notifList.innerHTML = `<div class="notif-item text-secondary">No new notifications.</div>`;
    } else {
        urgentPatients.forEach(p => {
            els.notifList.innerHTML += `
                <div class="notif-item">
                    <strong class="text-danger">🔴 Urgent:</strong> ${p.name} requires attention (${p.condition}).
                </div>
            `;
        });
    }
}

// --- NEW RENDERERS ---
function renderPatientsDirectory() {
    const allPatients = patientService.getAllPatients();
    els.allPatientsTbody.innerHTML = '';
    
    allPatients.forEach(p => {
        const priorityClass = 
            p.urgency === 'urgent' ? 'badge-urgent' :
            p.urgency === 'follow-up' ? 'badge-followup' : 'badge-ontrack';
        
        const priorityLabel = 
            p.urgency === 'urgent' ? 'Urgent' :
            p.urgency === 'follow-up' ? 'Follow-up' : 'On Track';

        const row = document.createElement('tr');
        row.innerHTML = `
            <td>
                <div style="display:flex; align-items:center; gap:0.5rem;">
                    <img src="https://ui-avatars.com/api/?name=${encodeURIComponent(p.name)}&background=random" style="width:2rem; border-radius:50%;">
                    <strong>${p.name}</strong>
                </div>
            </td>
            <td>${p.id}</td>
            <td>${p.condition}</td>
            <td>${p.status}</td>
            <td><span class="badge ${priorityClass}">${priorityLabel}</span></td>
            <td><button class="btn btn-sm btn-outline view-btn" data-id="${p.id}">View</button></td>
        `;
        els.allPatientsTbody.appendChild(row);
    });

    els.allPatientsTbody.querySelectorAll('.view-btn').forEach(btn => {
        btn.addEventListener('click', (e) => openModal(e.currentTarget.getAttribute('data-id')));
    });
}

function renderTasksBoard() {
    const allTasks = taskService.getAllTasks();
    const pending = allTasks.filter(t => t.status === 'Pending');
    const inProgress = allTasks.filter(t => t.status === 'In Progress');
    const completed = allTasks.filter(t => t.status === 'Completed');

    els.countPending.textContent = pending.length;
    els.countInprogress.textContent = inProgress.length;
    els.countCompleted.textContent = completed.length;

    const buildTaskCard = (t) => {
        const priorityColor = t.priority === 'High' ? 'text-danger' : t.priority === 'Medium' ? 'text-warning' : 'text-success';
        return `
            <div class="task-card">
                <h4>${t.type}: ${t.description}</h4>
                <p>Patient ID: ${t.patientId}</p>
                <div class="task-card-footer">
                    <span class="${priorityColor}"><strong>${t.priority} Priority</strong></span>
                    <span class="text-secondary"><i class="fa-regular fa-calendar"></i> ${t.dueDate}</span>
                </div>
            </div>
        `;
    };

    els.tasksPending.innerHTML = pending.map(buildTaskCard).join('');
    els.tasksInprogress.innerHTML = inProgress.map(buildTaskCard).join('');
    els.tasksCompleted.innerHTML = completed.map(buildTaskCard).join('');
}

function renderLabCoordination() {
    const tbody = document.getElementById('lab-tbody');
    const labs = [
        { name: 'Arjun Desai', test: 'Complete Blood Count', date: '2023-11-01', status: 'Pending' },
        { name: 'Priya Sharma', test: 'Lipid Panel', date: '2023-11-02', status: 'Processing' },
        { name: 'Vikram Singh', test: 'HbA1c', date: '2023-10-30', status: 'Completed' },
        { name: 'Neha Gupta', test: 'Urinalysis', date: '2023-11-03', status: 'Pending' }
    ];
    tbody.innerHTML = labs.map(l => `
        <tr>
            <td><strong>${l.name}</strong></td>
            <td>${l.test}</td>
            <td>${l.date}</td>
            <td><span class="badge ${l.status === 'Completed' ? 'badge-ontrack' : l.status === 'Processing' ? 'badge-followup' : 'badge-urgent'}">${l.status}</span></td>
            <td><button class="btn btn-sm btn-outline">View Details</button></td>
        </tr>
    `).join('');
}

function renderAppointments() {
    const list = document.getElementById('appointments-list');
    const appts = [
        { name: 'Ravi Kumar', time: '10:00 AM - Today', type: 'Follow-up' },
        { name: 'Anjali Verma', time: '11:30 AM - Today', type: 'Consultation' },
        { name: 'Sunil Das', time: '02:00 PM - Today', type: 'Routine Checkup' },
        { name: 'Meera Patel', time: '09:00 AM - Tomorrow', type: 'Test Review' }
    ];
    list.innerHTML = appts.map(a => `
        <div class="task-card">
            <h4>${a.name}</h4>
            <p><i class="fa-regular fa-clock"></i> ${a.time}</p>
            <div class="task-card-footer mt-4">
                <span class="text-secondary">${a.type}</span>
                <button class="btn btn-sm btn-text">Reschedule</button>
            </div>
        </div>
    `).join('');
}

function renderAlerts() {
    const list = document.getElementById('alerts-page-list');
    const alerts = [
        { msg: 'System Maintenance scheduled for 12:00 AM.', level: 'Medium' },
        { msg: 'Abnormal vitals detected for patient ID P1032.', level: 'High' },
        { msg: 'Dr. Mehta requested a consultation for Room 4B.', level: 'Medium' },
        { msg: 'Inventory low on Syringes (5ml).', level: 'Low' }
    ];
    list.innerHTML = alerts.map(a => `
        <div class="task-item" style="display:flex; justify-content:space-between; align-items:center; background: var(--bg-card); padding: 1rem; border-radius: var(--radius-md); border: 1px solid var(--border-color);">
            <div><strong>Alert:</strong> ${a.msg}</div>
            <span class="badge ${a.level === 'High' ? 'badge-urgent' : a.level === 'Medium' ? 'badge-followup' : 'badge-ontrack'}">${a.level}</span>
        </div>
    `).join('');
}

function renderMessages() {
    const sidebar = document.getElementById('messages-sidebar');
    const contacts = ['Dr. Anil Gupta (Cardiology)', 'Nurse Sarah (ICU)', 'Pharmacy Dept', 'Dr. Ramesh (Pediatrics)', 'Reception'];
    sidebar.innerHTML = contacts.map(c => `
        <div class="message-thread">
            <img src="https://ui-avatars.com/api/?name=${encodeURIComponent(c)}&background=random" style="width:2.5rem; height:2.5rem; border-radius:50%;">
            <div>
                <h4>${c}</h4>
                <p>Hey, just checking on the latest reports...</p>
            </div>
        </div>
    `).join('');
}

function renderReports() {
    const list = document.getElementById('reports-list');
    const reports = ['Monthly Admission Stats', 'Infection Control Summary', 'Staffing Analytics - Nov', 'Medication Error Log'];
    list.innerHTML = reports.map(r => `
        <div class="task-card" style="text-align: center; padding: 2rem 1rem;">
            <i class="fa-regular fa-file-pdf text-danger" style="font-size: 2.5rem; margin-bottom: 1rem;"></i>
            <h4>${r}</h4>
            <p>Generated: Today</p>
            <button class="btn btn-outline mt-4" style="width: 100%; justify-content:center;">Download</button>
        </div>
    `).join('');
}

// --- EVENT LISTENERS ---
function setupEventListeners() {
    // Search
    els.searchInput.addEventListener('input', (e) => {
        searchQuery = e.target.value;
        renderPatientQueue();
    });

    // Filter Panel Toggle
    els.toggleFilterPanel.addEventListener('click', () => {
        els.filterPanel.classList.toggle('open');
    });

    // Filter Selects
    const applyFilters = () => {
        currentFilters = {
            urgency: els.filterUrgency.value,
            taskType: els.filterTasktype.value,
            status: els.filterStatus.value,
            sortBy: els.filterSort.value
        };
        // Reset card highlights if manually filtering
        els.statCards.forEach(c => c.classList.remove('active'));
        renderPatientQueue();
    };

    els.filterUrgency.addEventListener('change', applyFilters);
    els.filterTasktype.addEventListener('change', applyFilters);
    els.filterStatus.addEventListener('change', applyFilters);
    els.filterSort.addEventListener('change', applyFilters);

    // Clear Filters
    els.clearFilters.addEventListener('click', () => {
        els.filterUrgency.value = 'All';
        els.filterTasktype.value = 'All';
        els.filterStatus.value = 'All';
        els.filterSort.value = 'Highest urgency';
        els.searchInput.value = '';
        searchQuery = '';
        applyFilters();
        els.statCards.forEach(c => c.classList.remove('active'));
        document.querySelector('[data-filter="All"]').classList.add('active');
    });

    // Top Cards Click
    els.statCards.forEach(card => {
        card.addEventListener('click', () => {
            els.statCards.forEach(c => c.classList.remove('active'));
            card.classList.add('active');
            
            const filterValue = card.getAttribute('data-filter');
            els.filterUrgency.value = filterValue;
            applyFilters();
        });
    });

    // Sidebar & Mobile
    const toggleSidebar = () => {
        els.sidebar.classList.toggle('open');
        els.sidebarOverlay.classList.toggle('active');
    };
    els.mobileMenuToggle.addEventListener('click', toggleSidebar);
    els.closeSidebarBtn.addEventListener('click', toggleSidebar);
    els.sidebarOverlay.addEventListener('click', toggleSidebar);

    els.navItems.forEach(item => {
        item.addEventListener('click', (e) => {
            e.preventDefault();
            
            const page = item.getAttribute('data-page');

            // Sync active state across both sidebar and bottom nav
            els.navItems.forEach(nav => {
                nav.classList.remove('active');
                if (nav.getAttribute('data-page') === page) {
                    nav.classList.add('active');
                }
            });
            
            // Close sidebar on mobile instead of toggling
            if(window.innerWidth <= 768) {
                els.sidebar.classList.remove('open');
                els.sidebarOverlay.classList.remove('active');
            }

            // Handle Page switching
            els.pageTitle.textContent = item.querySelector('span').textContent;
            
            // Hide all pages
            const pages = ['dashboard-view', 'patients-view', 'tasks-view', 'lab-view', 'appointments-view', 'alerts-view', 'messages-view', 'reports-view', 'placeholder-page'];
            pages.forEach(p => {
                const el = document.getElementById(p);
                if(el) el.classList.add('hidden');
            });

            // Show selected
            if (page === 'dashboard') {
                document.getElementById('dashboard-view').classList.remove('hidden');
            } else if (page === 'patients') {
                document.getElementById('patients-view').classList.remove('hidden');
            } else if (page === 'tasks') {
                document.getElementById('tasks-view').classList.remove('hidden');
            } else if (page === 'lab') {
                document.getElementById('lab-view').classList.remove('hidden');
            } else if (page === 'appointments') {
                document.getElementById('appointments-view').classList.remove('hidden');
            } else if (page === 'alerts') {
                document.getElementById('alerts-view').classList.remove('hidden');
            } else if (page === 'messages') {
                document.getElementById('messages-view').classList.remove('hidden');
            } else if (page === 'reports') {
                document.getElementById('reports-view').classList.remove('hidden');
            } else {
                els.placeholderPage.classList.remove('hidden');
            }
        });
    });

    // Dropdowns
    document.addEventListener('click', (e) => {
        // Profile
        if (els.profileBtn.contains(e.target)) {
            els.profileDropdown.parentElement.classList.toggle('active');
        } else {
            els.profileDropdown.parentElement.classList.remove('active');
        }
        // Notifications
        if (els.notifBtn.contains(e.target)) {
            els.notifDropdown.parentElement.classList.toggle('active');
        } else if (!els.notifDropdown.contains(e.target)) {
            els.notifDropdown.parentElement.classList.remove('active');
        }
    });

    // Modal close
    els.closeModalBtns.forEach(btn => {
        btn.addEventListener('click', closeModal);
    });
    els.modalOverlay.addEventListener('click', (e) => {
        if (e.target === els.modalOverlay) closeModal();
    });

    // Action Buttons in Modal
    els.actionBtns.forEach(btn => {
        btn.addEventListener('click', (e) => {
            const action = e.currentTarget.getAttribute('data-action');
            const patientId = els.modalOverlay.getAttribute('data-current-patient');
            if (action && patientId) {
                patientService.updatePatientUrgency(patientId, action);
                updateDashboard();
                openModal(patientId); // Refresh modal
            }
        });
    });
}

// --- MODAL LOGIC ---
function openModal(patientId) {
    const p = patientService.getPatientById(patientId);
    if (!p) return;

    els.modalOverlay.setAttribute('data-current-patient', p.id);
    els.modalTitle.textContent = p.name;
    els.modalPatientId.textContent = `ID: ${p.id}`;

    els.modalOverview.innerHTML = `
        <li><span>Age:</span> ${p.age}</li>
        <li><span>Gender:</span> ${p.gender}</li>
        <li><span>Diagnosis:</span> ${p.condition}</li>
        <li><span>Discharge:</span> ${p.dischargeDate}</li>
    `;

    els.modalStatus.innerHTML = `
        <li><span>Urgency:</span> <strong class="${p.urgency === 'urgent' ? 'text-danger' : p.urgency === 'follow-up' ? 'text-warning' : 'text-success'}">${p.urgency.toUpperCase()}</strong></li>
        <li><span>Med Adherence:</span> ${p.medicationAdherence}</li>
        <li><span>Lab Status:</span> ${p.labStatus}</li>
        <li><span>Appt Status:</span> ${p.appointmentStatus}</li>
    `;

    const tasks = taskService.getTasksForPatient(p.id);
    els.modalTasks.innerHTML = '';
    if (tasks.length === 0) {
        els.modalTasks.innerHTML = `<div class="task-item text-secondary">No active tasks.</div>`;
    } else {
        tasks.forEach(t => {
            els.modalTasks.innerHTML += `
                <div class="task-item" style="display:flex; justify-content:space-between;">
                    <div><strong>${t.type}:</strong> ${t.description}</div>
                    <span class="badge ${t.priority==='High'?'badge-urgent':'badge-ontrack'}">${t.status}</span>
                </div>
            `;
        });
    }

    els.modalOverlay.classList.add('active');
}

function closeModal() {
    els.modalOverlay.classList.remove('active');
    els.modalOverlay.removeAttribute('data-current-patient');
}

// Start
document.addEventListener('DOMContentLoaded', init);
