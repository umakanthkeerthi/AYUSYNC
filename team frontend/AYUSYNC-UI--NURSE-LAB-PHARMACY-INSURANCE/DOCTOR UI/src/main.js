import { storageService } from './services/storageService.js';
import { patientService } from './services/patientService.js';
import { historyService } from './services/historyService.js';
import { riskUtils } from './utils/riskUtils.js';

const els = {
    // Navigation
    sidebar: document.getElementById('sidebar'),
    sidebarOverlay: document.getElementById('sidebar-overlay'),
    mobileMenuToggle: document.getElementById('mobile-menu-toggle'),
    closeSidebarBtn: document.getElementById('close-sidebar'),
    navItems: document.querySelectorAll('.nav-item'),
    pageTitle: document.getElementById('page-title'),
    
    // Profile Dropdown
    profileBtn: document.getElementById('profile-btn'),
    profileDropdown: document.getElementById('profile-dropdown'),

    // Views
    overviewView: document.getElementById('overview-view'),
    patientsView: document.getElementById('patients-view'),
    alertsView: document.getElementById('alerts-view'),
    interventionsView: document.getElementById('interventions-view'),
    messagesView: document.getElementById('messages-view'),
    reportsView: document.getElementById('reports-view'),
    settingsView: document.getElementById('settings-view'),
    
    // Dashboard Stats
    statTotal: document.getElementById('stat-total'),
    statStable: document.getElementById('stat-stable'),
    statMonitoring: document.getElementById('stat-monitoring'),
    statIntervention: document.getElementById('stat-intervention'),
    
    // Data Containers
    interventionList: document.getElementById('intervention-list'),
    allPatientsTbody: document.getElementById('all-patients-tbody'),
    alertsList: document.getElementById('alerts-list'),
    fullInterventionList: document.getElementById('full-intervention-list'),
    messagesSidebar: document.getElementById('messages-sidebar'),
    reportsList: document.getElementById('reports-list'),
    
    // Filters
    filterBtn: document.getElementById('filter-btn'),
    filterPanel: document.getElementById('filter-panel'),
    patientSearch: document.getElementById('patient-search'),
    filterRiskLevel: document.getElementById('filter-risk-level'),
    filterUrgency: document.getElementById('filter-urgency'),
    filterStatus: document.getElementById('filter-status'),
    filterSort: document.getElementById('filter-sort'),
    filterMinRisk: document.getElementById('filter-min-risk'),
    filterMaxRisk: document.getElementById('filter-max-risk'),
    riskScoreDisplay: document.getElementById('risk-score-display'),
    applyFiltersBtn: document.getElementById('apply-filters-btn'),
    clearFiltersBtn: document.getElementById('clear-filters-btn'),
    filterResultsCount: document.getElementById('filter-results-count'),
    
    // Modals
    patientModal: document.getElementById('patient-modal'),
    closeModal: document.getElementById('close-modal'),
    modalContent: document.getElementById('modal-content'),
    
    historyModal: document.getElementById('history-modal'),
    closeHistoryModalBtn: document.getElementById('close-history-modal'),
    cancelHistoryBtn: document.getElementById('cancel-history-btn'),
    histPatientName: document.getElementById('history-patient-name'),
    histPatientMeta: document.getElementById('history-patient-meta'),
    previousHistoryContainer: document.getElementById('previous-history-container'),
    
    confirmModal: document.getElementById('confirm-modal'),
    confirmCancelBtn: document.getElementById('confirm-cancel'),
    confirmActionBtn: document.getElementById('confirm-action'),
    confirmTitle: document.getElementById('confirm-title'),
    confirmMsg: document.getElementById('confirm-msg'),

    toastContainer: document.getElementById('toast-container')
};

// State
let activeFilters = {
    search: '',
    riskLevel: 'All',
    urgency: 'All',
    status: 'All',
    sortBy: 'Highest Risk',
    minRisk: 0,
    maxRisk: 100
};

const DOCTOR_NAME = "Dr. Mehta";
let confirmCallback = null;

// Initialize
function init() {
    storageService.init();
    historyService.init();
    setupNavigation();
    setupProfileDropdown();
    setupFilters();
    setupModals();
    
    // Initial Render
    renderDashboard();
    renderPatients();
    renderOtherTabs();
}

function showToast(message, type = 'success') {
    const toast = document.createElement('div');
    toast.className = 'toast';
    toast.innerHTML = `
        <i class="fa-solid fa-circle-check toast-icon"></i>
        <div class="toast-content">
            <h4>Success</h4>
            <p>${message}</p>
        </div>
    `;
    els.toastContainer.appendChild(toast);
    
    setTimeout(() => toast.classList.add('show'), 10);
    setTimeout(() => {
        toast.classList.remove('show');
        setTimeout(() => toast.remove(), 300);
    }, 3000);
}

function showConfirm(title, message, onConfirm, isDestructive = false) {
    els.confirmTitle.textContent = title;
    els.confirmMsg.textContent = message;
    confirmCallback = onConfirm;
    
    if (isDestructive) {
        els.confirmActionBtn.classList.remove('btn-primary');
        els.confirmActionBtn.classList.add('btn-danger');
        els.confirmActionBtn.style.background = 'var(--color-danger)';
        els.confirmActionBtn.style.color = 'white';
        els.confirmActionBtn.textContent = 'Delete';
    } else {
        els.confirmActionBtn.style.background = '';
        els.confirmActionBtn.classList.add('btn-primary');
        els.confirmActionBtn.textContent = 'Confirm';
    }
    
    els.confirmModal.classList.add('active');
}

function renderDashboard() {
    const stats = patientService.getDashboardStats();
    els.statTotal.textContent = stats.total;
    els.statStable.textContent = stats.stable;
    els.statMonitoring.textContent = stats.monitoring;
    els.statIntervention.textContent = stats.intervention;

    const queue = patientService.getInterventionQueue().slice(0, 5);
    els.interventionList.innerHTML = queue.map(pt => createPatientCard(pt)).join('');
    
    setTimeout(() => { queue.forEach(pt => drawChart(`chart-${pt.id}`, pt)); }, 100);
    
    document.querySelectorAll('.metric-card').forEach(card => {
        card.addEventListener('click', () => {
            const label = card.querySelector('.metric-label').textContent;
            els.navItems.forEach(n => {
                if(n.getAttribute('data-page') === 'patients') n.click();
            });
            if(label === 'Stable') { els.filterStatus.value = 'Stable'; }
            else if(label === 'Monitoring') { els.filterStatus.value = 'Monitoring'; }
            else if(label === 'Need Intervention') { els.filterStatus.value = 'Need Intervention'; }
            else { els.filterStatus.value = 'All'; }
            
            els.filterPanel.classList.remove('hidden');
            els.applyFiltersBtn.click();
        });
    });
}

function createPatientCard(pt) {
    const riskLvl = riskUtils.getRiskLevel(pt.riskScore);
    const riskCls = riskUtils.getRiskClass(pt.riskScore);
    
    return `
        <div class="intervention-card">
            <div class="card-left">
                <img src="https://ui-avatars.com/api/?name=${encodeURIComponent(pt.name)}&background=random" alt="${pt.name}" class="patient-avatar">
                <div class="patient-details">
                    <h3>${pt.name} <span style="font-size: 0.8rem; font-weight: normal; color: var(--text-secondary); margin-left: 0.5rem;">${pt.id}</span></h3>
                    <p class="patient-meta">Age ${pt.age} &bull; ${pt.gender} &bull; Post Discharge: ${pt.postDischargeDays} days</p>
                    <p class="recent-changes">Recent Changes</p>
                    <ul class="changes-list">
                        ${pt.recentChanges.map(c => `<li>${c}</li>`).join('')}
                    </ul>
                </div>
            </div>
            <div class="card-right">
                <div style="display:flex; gap:0.5rem;">
                    <span class="risk-badge ${riskUtils.getUrgencyClass(pt.urgency)}">${pt.urgency}</span>
                    <span class="risk-badge ${riskCls}">${riskLvl}</span>
                </div>
                <div class="risk-score">
                    <p class="risk-score-title">Risk Score</p>
                    <p class="risk-score-val">${pt.riskScore}/100</p>
                    <div class="chart-container">
                        <canvas id="chart-${pt.id}"></canvas>
                    </div>
                </div>
                <button class="btn btn-primary" onclick="window.openPatientModal('${pt.id}')">View Patient</button>
            </div>
        </div>
    `;
}

function generateMockTrend(currentScore) {
    return [currentScore - 10, currentScore - 5, currentScore - 8, currentScore - 2, currentScore - 4, currentScore + 2, currentScore];
}

function drawChart(canvasId, pt) {
    const canvas = document.getElementById(canvasId);
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    const color = pt.riskScore >= 70 ? '#ef4444' : pt.riskScore >= 40 ? '#f59e0b' : '#10b981';
    
    new Chart(ctx, {
        type: 'line',
        data: {
            labels: ['1', '2', '3', '4', '5', '6', '7'],
            datasets: [{
                data: generateMockTrend(pt.riskScore),
                borderColor: color,
                borderWidth: 2,
                tension: 0.4,
                pointRadius: 0
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { display: false }, tooltip: { enabled: false } },
            scales: { x: { display: false }, y: { display: false, min: 0, max: 100 } },
            layout: { padding: 0 }
        }
    });
}

function renderPatients() {
    const patients = patientService.filterPatients(activeFilters);
    els.filterResultsCount.textContent = `Showing ${patients.length} patient${patients.length !== 1 ? 's' : ''}`;
    
    const isMobile = window.innerWidth <= 768;
    
    if (isMobile) {
        els.allPatientsTbody.parentElement.style.display = 'none';
        let container = document.getElementById('mobile-patients-container');
        if (!container) {
            container = document.createElement('div');
            container.id = 'mobile-patients-container';
            container.style.display = 'flex';
            container.style.flexDirection = 'column';
            container.style.gap = '1rem';
            els.allPatientsTbody.parentElement.parentElement.appendChild(container);
        }
        container.style.display = 'flex';
        container.innerHTML = patients.map(p => `
            <div class="card" style="padding: 1rem;">
                <div style="display:flex; justify-content:space-between; align-items:flex-start;">
                    <div>
                        <h4 style="margin-bottom:0.25rem;">${p.name}</h4>
                        <p style="font-size:0.8rem; color:var(--text-secondary);">${p.id} &bull; Age ${p.age}</p>
                    </div>
                    <span class="risk-badge ${riskUtils.getRiskClass(p.riskScore)}">${p.riskScore}/100</span>
                </div>
                <div style="margin-top:1rem; display:flex; justify-content:space-between; align-items:center;">
                    <span style="font-size:0.85rem;"><strong>Status:</strong> ${riskUtils.getPatientStatus(p)}</span>
                    <button class="btn btn-primary btn-sm" style="padding: 0.4rem 1rem;" onclick="window.openPatientModal('${p.id}')">View</button>
                </div>
            </div>
        `).join('');
    } else {
        els.allPatientsTbody.parentElement.style.display = 'table';
        const container = document.getElementById('mobile-patients-container');
        if (container) container.style.display = 'none';
        
        els.allPatientsTbody.innerHTML = patients.map(p => `
            <tr>
                <td>
                    <div style="display:flex; align-items:center; gap:0.5rem;">
                        <img src="https://ui-avatars.com/api/?name=${encodeURIComponent(p.name)}&background=random" style="width:2rem; border-radius:50%;">
                        <div>
                            <strong>${p.name}</strong><br>
                            <span style="font-size:0.75rem; color:var(--text-secondary);">${p.id}</span>
                        </div>
                    </div>
                </td>
                <td>${p.age}</td>
                <td>${p.condition}</td>
                <td>
                    <div style="display:flex; flex-direction:column; gap:0.25rem;">
                        <span class="risk-badge ${riskUtils.getRiskClass(p.riskScore)}">${p.riskScore} - ${riskUtils.getRiskLevel(p.riskScore)}</span>
                        <span class="risk-badge ${riskUtils.getUrgencyClass(p.urgency)}">${p.urgency}</span>
                    </div>
                </td>
                <td><button class="btn btn-primary" style="padding: 0.4rem 1rem; font-size: 0.8rem;" onclick="window.openPatientModal('${p.id}')">View</button></td>
            </tr>
        `).join('');
    }
}

window.addEventListener('resize', () => {
    if (!els.patientsView.classList.contains('hidden')) renderPatients();
});

function renderOtherTabs() {
    const allPts = patientService.getAllPatients();
    const alerts = allPts.filter(p => p.riskScore >= 70 || p.labStatus === 'Abnormal');
    
    els.alertsList.innerHTML = alerts.map(a => `
        <div class="intervention-card" style="align-items:center; flex-direction:row;">
            <div style="display:flex; gap:1rem; align-items:center;">
                <div style="font-size: 1.5rem;">${a.labStatus === 'Abnormal' ? '🟠' : '🔴'}</div>
                <div>
                    <h4 style="margin-bottom:0.25rem;">${a.labStatus === 'Abnormal' ? 'Lab Alert' : 'High Risk Alert'}</h4>
                    <p style="font-size:0.9rem; color:var(--text-secondary);">${a.name} (${a.id}) requires review. ${a.recentChanges[0] || ''}</p>
                </div>
            </div>
            <button class="btn btn-primary" onclick="window.openPatientModal('${a.id}')">Review</button>
        </div>
    `).join('');

    if(alerts.length === 0) els.alertsList.innerHTML = `<p style="text-align:center; padding: 2rem; color: var(--text-secondary);">No active alerts.</p>`;

    const fullQueue = patientService.getInterventionQueue();
    els.fullInterventionList.innerHTML = fullQueue.map(pt => createPatientCard(pt)).join('');
    setTimeout(() => { fullQueue.forEach(pt => drawChart(`chart-${pt.id}`, pt)); }, 100);

    const contacts = ['Nurse Sarah', 'Dr. Sharma (Cardio)', 'Admin Desk', 'Pharmacy'];
    els.messagesSidebar.innerHTML = contacts.map(c => `
        <div class="message-thread" onclick="alert('Mock conversation with ${c} loaded.')">
            <span style="font-size: 1.5rem; background: var(--brand-bg); border-radius: 50%; padding: 0.2rem; display: flex; align-items: center; justify-content: center; width: 2.5rem; height: 2.5rem;">${c.includes('Dr') ? '👨‍⚕️' : '👩‍⚕️'}</span>
            <div>
                <h4 style="font-size:0.9rem;">${c}</h4>
                <p style="font-size:0.75rem; color:var(--text-secondary);">Tap to view message...</p>
            </div>
        </div>
    `).join('');

    els.reportsList.innerHTML = ['Risk Distribution', 'Monthly Patient Outcomes', 'Readmission Risk Analysis', 'Medication Adherence Report'].map(r => `
        <div class="metric-card" style="padding: 2rem; cursor:pointer;" onclick="alert('Downloading ${r}.pdf')">
            <i class="fa-regular fa-file-pdf text-danger" style="font-size: 2.5rem; margin-bottom: 1rem;"></i>
            <h4 style="font-size: 0.95rem;">${r}</h4>
            <p style="font-size: 0.75rem; color: var(--text-secondary); margin-top:0.5rem;">Generated Today</p>
        </div>
    `).join('');
}

function setupFilters() {
    els.filterBtn.addEventListener('click', () => els.filterPanel.classList.toggle('hidden'));
    
    const updateRiskDisplay = () => {
        let min = parseInt(els.filterMinRisk.value);
        let max = parseInt(els.filterMaxRisk.value);
        if (min > max) { let temp = min; min = max; max = temp; }
        els.riskScoreDisplay.textContent = `${min} - ${max}`;
    };
    els.filterMinRisk.addEventListener('input', updateRiskDisplay);
    els.filterMaxRisk.addEventListener('input', updateRiskDisplay);

    els.applyFiltersBtn.addEventListener('click', () => {
        let min = parseInt(els.filterMinRisk.value);
        let max = parseInt(els.filterMaxRisk.value);
        if (min > max) { let temp = min; min = max; max = temp; }
        
        activeFilters = {
            search: els.patientSearch.value,
            riskLevel: els.filterRiskLevel.value,
            urgency: els.filterUrgency.value,
            status: els.filterStatus.value,
            sortBy: els.filterSort.value,
            minRisk: min,
            maxRisk: max
        };
        renderPatients();
    });

    els.clearFiltersBtn.addEventListener('click', () => {
        els.patientSearch.value = '';
        els.filterRiskLevel.value = 'All';
        els.filterUrgency.value = 'All';
        els.filterStatus.value = 'All';
        els.filterSort.value = 'Highest Risk';
        els.filterMinRisk.value = 0;
        els.filterMaxRisk.value = 100;
        updateRiskDisplay();
        els.applyFiltersBtn.click();
    });

    els.patientSearch.addEventListener('keyup', (e) => {
        if(e.key === 'Enter') els.applyFiltersBtn.click();
    });
}

function setupNavigation() {
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

            const allNavs = document.querySelectorAll('.nav-item');
            allNavs.forEach(nav => {
                nav.classList.remove('active');
                if (nav.getAttribute('data-page') === page) nav.classList.add('active');
            });

            if(window.innerWidth <= 768) {
                els.sidebar.classList.remove('open');
                els.sidebarOverlay.classList.remove('active');
            }

            const titleSpan = item.querySelector('span');
            if(titleSpan && els.pageTitle) els.pageTitle.textContent = titleSpan.textContent;
            
            const views = ['overview-view', 'patients-view', 'alerts-view', 'interventions-view', 'messages-view', 'reports-view', 'settings-view'];
            views.forEach(v => {
                const el = document.getElementById(v);
                if(el) el.classList.add('hidden');
            });

            const selectedEl = document.getElementById(`${page}-view`);
            if (selectedEl) {
                selectedEl.classList.remove('hidden');
                window.dispatchEvent(new Event('resize')); 
            }
        });
    });
}

function setupProfileDropdown() {
    els.profileBtn.addEventListener('click', (e) => {
        e.stopPropagation();
        els.profileDropdown.classList.toggle('hidden');
    });
    document.addEventListener('click', () => els.profileDropdown.classList.add('hidden'));
    els.profileDropdown.addEventListener('click', (e) => e.stopPropagation());
    
    els.profileDropdown.querySelectorAll('.dropdown-item').forEach(item => {
        item.addEventListener('click', (e) => {
            e.preventDefault();
            els.profileDropdown.classList.add('hidden');
            const page = item.getAttribute('data-page');
            if(page) {
                els.navItems.forEach(n => {
                    if(n.getAttribute('data-page') === page && n.closest('.sidebar')) n.click();
                });
            } else if (item.textContent === 'Logout') {
                alert('Logging out...');
            }
        });
    });
}

function setupModals() {
    els.closeModal.addEventListener('click', () => els.patientModal.classList.remove('active'));
    els.patientModal.addEventListener('click', (e) => {
        if(e.target === els.patientModal) els.patientModal.classList.remove('active');
    });
    
    // History Modal
    const closeHistory = () => els.historyModal.classList.remove('active');
    els.closeHistoryModalBtn.addEventListener('click', closeHistory);
    els.cancelHistoryBtn.addEventListener('click', closeHistory);

    // Confirm Modal
    els.confirmCancelBtn.addEventListener('click', () => els.confirmModal.classList.remove('active'));
    els.confirmActionBtn.addEventListener('click', () => {
        if (confirmCallback) confirmCallback();
        els.confirmModal.classList.remove('active');
    });
}

window.openPatientModal = (patientId) => {
    const pt = patientService.getPatientById(patientId);
    if(!pt) return;
    
    els.modalContent.innerHTML = `
        <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom: 2rem; flex-wrap:wrap; gap:1rem;">
            <div style="display:flex; gap:1.5rem; align-items:center;">
                <img src="https://ui-avatars.com/api/?name=${encodeURIComponent(pt.name)}&background=random" style="width:5rem; height:5rem; border-radius:50%;">
                <div>
                    <h2 style="font-size: 1.5rem; font-weight:600; margin-bottom:0.25rem;">${pt.name}</h2>
                    <p class="text-secondary">${pt.id} &bull; ${pt.age} yrs &bull; ${pt.gender}</p>
                    <p style="font-weight:600; margin-top:0.5rem;">${pt.diagnosis}</p>
                </div>
            </div>
            <div style="text-align:right;">
                <div style="display:flex; gap:0.5rem; justify-content:flex-end; margin-bottom: 0.5rem;">
                    <span class="risk-badge ${riskUtils.getUrgencyClass(pt.urgency)}">${pt.urgency}</span>
                    <span class="risk-badge ${riskUtils.getRiskClass(pt.riskScore)}">${riskUtils.getRiskLevel(pt.riskScore)}</span>
                </div>
                <div class="risk-score-val" style="font-size: 2rem;">${pt.riskScore}/100</div>
            </div>
        </div>

        <div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 2rem;">
            <!-- Clinical Details -->
            <div>
                <h4 style="margin-bottom: 1rem; padding-bottom:0.5rem; border-bottom: 1px solid var(--border-color);">Clinical Overview</h4>
                <p><strong>Condition:</strong> ${pt.condition}</p>
                <p><strong>Post Discharge:</strong> ${pt.postDischargeDays} days</p>
                <p><strong>Lab Status:</strong> ${pt.labStatus}</p>
                <p><strong>Last Updated:</strong> ${new Date(pt.lastUpdated).toLocaleString()}</p>
                
                <h4 style="margin-top: 1.5rem; margin-bottom: 1rem; padding-bottom:0.5rem; border-bottom: 1px solid var(--border-color);">Recent Changes</h4>
                <ul style="padding-left: 1.25rem; font-size: 0.9rem; display:flex; flex-direction:column; gap:0.5rem;">
                    ${pt.recentChanges.map(c => `<li>${c}</li>`).join('')}
                </ul>
            </div>
            
            <!-- Medications & Actions -->
            <div style="display:flex; flex-direction:column;">
                <h4 style="margin-bottom: 1rem; padding-bottom:0.5rem; border-bottom: 1px solid var(--border-color);">Medications</h4>
                ${pt.medications.length === 0 ? '<p class="text-secondary">No active medications.</p>' : `
                    <div style="display:flex; flex-direction:column; gap:1rem; flex:1;">
                        ${pt.medications.map(m => `
                            <div class="card" style="padding:1rem; box-shadow:none;">
                                <div style="display:flex; justify-content:space-between;">
                                    <strong>${m.name}</strong>
                                    <span class="risk-badge ${m.adherence === 'High' ? 'risk-low' : m.adherence === 'Medium' ? 'risk-medium' : 'risk-high'}">${m.adherence} Adherence</span>
                                </div>
                                <p style="font-size:0.85rem; color:var(--text-secondary); margin-top:0.25rem;">${m.dose} &bull; ${m.frequency}</p>
                            </div>
                        `).join('')}
                    </div>
                `}
                
                <!-- Action Buttons: Previous History replacing Enter Patient History -->
                <div style="margin-top: 2rem; display:flex; gap: 0.5rem; flex-wrap:wrap;">
                    <button class="btn btn-outline" style="flex:1; border:1px solid var(--border-color); min-width: 140px;" onclick="alert('Creating intervention for ${pt.name}')">Create Intervention</button>
                    <button class="btn btn-primary" style="flex:1; min-width: 140px; display:flex; align-items:center; gap:0.5rem;" onclick="window.openPreviousHistoryModal('${pt.id}')">
                        <i class="fa-solid fa-clock-rotate-left"></i> Previous History
                    </button>
                    <button class="btn btn-outline" style="flex:1; border:1px solid var(--border-color); min-width: 140px;">Message Patient</button>
                </div>
            </div>
        </div>
    `;
    
    els.patientModal.classList.add('active');
};

window.openPreviousHistoryModal = (patientId) => {
    const pt = patientService.getPatientById(patientId);
    if (!pt) return;
    
    els.histPatientName.textContent = pt.name;
    els.histPatientMeta.textContent = `${pt.id} • ${pt.age} yrs • ${pt.gender}`;
    
    const renderTimeline = () => {
        const history = historyService.getHistoryForPatient(patientId);
        if (history.length === 0) return `<p class="text-secondary" style="font-size: 0.9rem; padding: 2rem; text-align: center;">No history recorded yet.</p>`;
        
        return history.map(h => {
            const dateStr = new Date(h.createdAt).toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' });
            const timeStr = new Date(h.createdAt).toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' });
            return `
                <div class="history-entry">
                    <div class="history-entry-header">
                        <div>
                            <strong>${dateStr} &bull; ${timeStr}</strong>
                            <p class="history-entry-meta">${h.doctorName}</p>
                        </div>
                    </div>
                    
                    ${h.currentCondition ? `<div class="history-block"><div class="history-block-title">Current Condition</div><p style="font-size:0.9rem;">${h.currentCondition}</p></div>` : ''}
                    ${h.doctorsNotes ? `<div class="history-block"><div class="history-block-title">Doctor's Notes</div><p style="font-size:0.9rem; white-space:pre-wrap;">${h.doctorsNotes}</p></div>` : ''}
                    ${h.recentChanges && h.recentChanges.length > 0 ? `
                        <div class="history-block">
                            <div class="history-block-title">Recent Changes</div>
                            <ul style="padding-left:1.25rem; font-size:0.9rem; display:flex; flex-direction:column; gap:0.25rem;">
                                ${h.recentChanges.map(c => `<li>${c}</li>`).join('')}
                            </ul>
                        </div>
                    ` : ''}
                    ${h.assessment ? `<div class="history-block"><div class="history-block-title">Assessment</div><p style="font-size:0.9rem;">${h.assessment}</p></div>` : ''}
                    ${h.plan ? `<div class="history-block"><div class="history-block-title">Plan / Recommendations</div><p style="font-size:0.9rem;">${h.plan}</p></div>` : ''}
                    ${h.followUpRequired ? `<div class="history-block" style="border-left: 3px solid var(--color-warning);"><div class="history-block-title">Follow-up: ${h.followUpDate || 'Not specified'}</div><p style="font-size:0.9rem;">${h.followUpNotes || ''}</p></div>` : ''}
                </div>
            `;
        }).join('');
    };

    els.previousHistoryContainer.innerHTML = `
        <div class="history-timeline" style="margin-top: 1rem;">
            ${renderTimeline()}
        </div>
    `;
    
    els.historyModal.classList.add('active');
};

document.addEventListener('DOMContentLoaded', init);
