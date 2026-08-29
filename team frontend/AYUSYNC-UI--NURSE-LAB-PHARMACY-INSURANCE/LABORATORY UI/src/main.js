import { labService } from './services/labService.js';
import { storageService } from './services/storageService.js';
import { riskUtils } from './utils/riskUtils.js';
import { filterUtils } from './utils/filterUtils.js';

const els = {
    // Navigation
    sidebar: document.getElementById('sidebar'),
    sidebarOverlay: document.getElementById('sidebar-overlay'),
    mobileMenuToggle: document.getElementById('mobile-menu-toggle'),
    closeSidebarBtn: document.getElementById('close-sidebar'),
    navItems: document.querySelectorAll('.nav-item'),
    pageTitle: document.getElementById('page-title'),

    // Views
    dashboardView: document.getElementById('dashboard-view'),
    samplesView: document.getElementById('samples-view'),
    resultsView: document.getElementById('results-view'),
    reportsView: document.getElementById('reports-view'),
    analyticsView: document.getElementById('analytics-view'),
    settingsView: document.getElementById('settings-view'),

    // Dropdowns
    profileBtn: document.getElementById('profile-btn'),
    profileDropdown: document.getElementById('profile-dropdown'),
    notifBtn: document.getElementById('notif-btn'),

    // Filters
    globalSearch: document.getElementById('global-search'),
    btnFilterToggle: document.getElementById('btn-filter-toggle'),
    filterPanel: document.getElementById('filter-panel'),
    filterStatus: document.getElementById('filter-status'),
    filterUrgency: document.getElementById('filter-urgency'),
    filterMinRisk: document.getElementById('filter-min-risk'),
    filterMaxRisk: document.getElementById('filter-max-risk'),
    riskValDisplay: document.getElementById('risk-val-display'),
    filterSort: document.getElementById('filter-sort'),
    btnApplyFilters: document.getElementById('btn-apply-filters'),
    btnClearFilters: document.getElementById('btn-clear-filters'),
    filterCount: document.getElementById('filter-count'),

    // Tables
    workQueueTbody: document.getElementById('work-queue-tbody'),
    mobileQueueContainer: document.getElementById('mobile-queue-container'),
    samplesTbody: document.getElementById('samples-tbody'),
    resultsTbody: document.getElementById('results-tbody'),

    // Stats
    statPending: document.getElementById('stat-pending'),
    statCollected: document.getElementById('stat-collected'),
    statProcessing: document.getElementById('stat-processing'),
    statCritical: document.getElementById('stat-critical'),
    criticalBanner: document.getElementById('critical-banner'),
    criticalBannerText: document.getElementById('critical-banner-text'),

    // Modals
    collectModal: document.getElementById('collect-modal'),
    resultsModal: document.getElementById('results-modal'),
    timelineModal: document.getElementById('timeline-modal'),
    toastContainer: document.getElementById('toast-container')
};

let activeFilters = {
    search: '',
    status: 'All',
    urgency: 'All',
    minRisk: 0,
    maxRisk: 100,
    sort: 'Latest Collection'
};

function init() {
    labService.init();
    setupNavigation();
    setupDropdowns();
    setupFilters();
    setupModals();
    renderAll();
}

function showToast(message, isError = false) {
    const toast = document.createElement('div');
    toast.className = 'toast';
    if(isError) toast.style.borderLeftColor = 'var(--color-danger)';
    toast.innerHTML = `
        <i class="fa-solid ${isError ? 'fa-circle-xmark text-danger' : 'fa-circle-check toast-icon'}"></i>
        <div class="toast-content">
            <h4 style="font-size:0.95rem; margin-bottom:0.25rem;">${isError ? 'Error' : 'Success'}</h4>
            <p style="font-size:0.85rem; color:var(--text-secondary);">${message}</p>
        </div>
    `;
    els.toastContainer.appendChild(toast);
    setTimeout(() => toast.classList.add('show'), 10);
    setTimeout(() => {
        toast.classList.remove('show');
        setTimeout(() => toast.remove(), 300);
    }, 3000);
}

function renderAll() {
    renderStats();
    renderWorkQueue();
    renderSamples();
    renderResults();
    renderAnalytics();
}

function renderStats() {
    const stats = labService.getDashboardStats();
    els.statPending.textContent = stats.pending;
    els.statCollected.textContent = stats.collected;
    els.statProcessing.textContent = stats.processing;
    els.statCritical.textContent = stats.critical;

    if (stats.critical > 0) {
        els.criticalBanner.classList.remove('hidden');
        els.criticalBannerText.textContent = `${stats.critical} results require immediate review`;
    } else {
        els.criticalBanner.classList.add('hidden');
    }
}

function getActionHtml(record) {
    switch (record.status) {
        case 'Scheduled':
            return `<button class="action-btn blue" onclick="window.confirmRecord('${record.id}')">Confirm</button>`;
        case 'Pending':
            return `<button class="action-btn blue" onclick="window.openCollectModal('${record.id}')">Collect</button>`;
        case 'Collected':
            return `<button class="action-btn gray" onclick="window.startProcessing('${record.id}')">Start Processing</button>`;
        case 'Processing':
            return `<button class="action-btn blue" onclick="window.openResultsModal('${record.id}')">Enter Result</button>`;
        case 'Completed':
        case 'Critical':
            return `<button class="action-btn gray" onclick="window.openTimelineModal('${record.id}')">View Result</button>`;
        default:
            return `<button class="action-btn gray" onclick="window.openTimelineModal('${record.id}')">View</button>`;
    }
}

function renderWorkQueue() {
    const allRecords = labService.getAllRecords();
    let filtered = filterUtils.applyFilters(allRecords, activeFilters);
    filtered = filterUtils.sortRecords(filtered, activeFilters.sort);
    
    // Default dashboard only shows active queue items if no specific status filter is applied
    if (activeFilters.status === 'All' && !activeFilters.search) {
        filtered = filtered.filter(r => ['Scheduled', 'Pending', 'Collected', 'Processing'].includes(r.status));
    }

    els.filterCount.textContent = `Showing ${filtered.length} records`;

    // Render Desktop Table
    els.workQueueTbody.innerHTML = filtered.map(r => `
        <tr>
            <td class="patient-name">
                ${r.patientName}<br>
                <span class="text-secondary" style="font-size:0.75rem;">${r.patientId} • ${r.id}</span>
            </td>
            <td>${r.testName} <br><span class="text-secondary" style="font-size:0.75rem;">${r.testCategory}</span></td>
            <td>${r.collectionTime} <br><span class="text-secondary" style="font-size:0.75rem;">${r.collectionDate}</span></td>
            <td><span class="badge ${riskUtils.getUrgencyBadgeClass(r.urgency)}">${r.urgency}</span></td>
            <td><span class="badge ${riskUtils.getRiskBadgeClass(r.riskScore)}">${r.riskScore} • ${r.riskLevel}</span></td>
            <td><span class="status-badge ${riskUtils.getStatusBadgeClass(r.status).replace('badge-', '')}">${r.status}</span></td>
            <td>${getActionHtml(r)}</td>
        </tr>
    `).join('');

    // Render Mobile Cards
    els.mobileQueueContainer.innerHTML = filtered.map(r => `
        <div class="card p-4" style="padding: 1rem;">
            <div style="display:flex; justify-content:space-between; margin-bottom:0.5rem;">
                <strong>${r.patientName}</strong>
                <span class="badge ${riskUtils.getUrgencyBadgeClass(r.urgency)}">${r.urgency}</span>
            </div>
            <div style="font-size:0.85rem; color:var(--text-secondary); margin-bottom:1rem;">
                ${r.testName} • ${r.id}<br>
                ${r.collectionDate} ${r.collectionTime}
            </div>
            <div style="display:flex; justify-content:space-between; align-items:center;">
                <span class="status-badge ${riskUtils.getStatusBadgeClass(r.status).replace('badge-', '')}">${r.status}</span>
                ${getActionHtml(r)}
            </div>
        </div>
    `).join('');
}

function renderSamples() {
    const allRecords = filterUtils.sortRecords(labService.getAllRecords(), 'Latest Collection');
    els.samplesTbody.innerHTML = allRecords.map(r => `
        <tr>
            <td><a href="#" onclick="window.openTimelineModal('${r.id}'); return false;">${r.id}</a></td>
            <td>${r.patientName}</td>
            <td>${r.testName}</td>
            <td>${r.sampleType}</td>
            <td><span class="status-badge ${riskUtils.getStatusBadgeClass(r.status).replace('badge-', '')}">${r.status}</span></td>
            <td>${getActionHtml(r)}</td>
        </tr>
    `).join('');
}

function renderResults() {
    const results = filterUtils.sortRecords(
        labService.getAllRecords().filter(r => ['Completed', 'Critical'].includes(r.status)),
        'Latest Collection'
    );
    els.resultsTbody.innerHTML = results.map(r => `
        <tr>
            <td><a href="#" onclick="window.openTimelineModal('${r.id}'); return false;">${r.id}</a></td>
            <td>${r.patientName}</td>
            <td>${r.testName}</td>
            <td><strong>${r.result}</strong> ${r.unit !== 'N/A' ? r.unit : ''}</td>
            <td><span class="badge ${r.resultStatus === 'Critical' ? 'badge-danger' : r.resultStatus === 'Abnormal' ? 'badge-warning' : 'badge-success'}">${r.resultStatus}</span></td>
            <td><button class="action-btn gray" onclick="window.openTimelineModal('${r.id}')">View</button></td>
        </tr>
    `).join('');
}

function renderAnalytics() {
    const stats = labService.getDashboardStats();
    const all = labService.getAllRecords();
    const grid = document.getElementById('analytics-grid');
    if(!grid) return;
    
    grid.innerHTML = `
        <div class="metric-card">
            <h4 style="font-size:0.95rem; margin-bottom:1rem;">Test Volume</h4>
            <div style="font-size:2.5rem; font-weight:700;">${all.length}</div>
            <p class="text-secondary" style="font-size:0.8rem;">Total records in system</p>
        </div>
        <div class="metric-card">
            <h4 style="font-size:0.95rem; margin-bottom:1rem;">Completion Rate</h4>
            <div style="font-size:2.5rem; font-weight:700; color:var(--color-success);">${Math.round((stats.completed / all.length) * 100) || 0}%</div>
            <p class="text-secondary" style="font-size:0.8rem;">Tests finished processing</p>
        </div>
        <div class="metric-card">
            <h4 style="font-size:0.95rem; margin-bottom:1rem;">Critical Rate</h4>
            <div style="font-size:2.5rem; font-weight:700; color:var(--color-danger);">${Math.round((stats.critical / all.length) * 100) || 0}%</div>
            <p class="text-secondary" style="font-size:0.8rem;">Results requiring immediate review</p>
        </div>
    `;
}

// ---------------------------
// Setup Event Listeners
// ---------------------------
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

            els.navItems.forEach(nav => nav.classList.remove('active'));
            item.classList.add('active');

            if(window.innerWidth <= 1024) toggleSidebar();

            const titleSpan = item.querySelector('span');
            if(titleSpan) els.pageTitle.textContent = 'Lab ' + titleSpan.textContent;
            
            const views = ['dashboard', 'samples', 'results', 'reports', 'analytics', 'settings'];
            views.forEach(v => {
                const el = document.getElementById(`${v}-view`);
                if(el) el.classList.add('hidden');
            });

            const selectedEl = document.getElementById(`${page}-view`);
            if (selectedEl) selectedEl.classList.remove('hidden');
        });
    });
}

function setupDropdowns() {
    els.profileBtn.addEventListener('click', (e) => {
        e.stopPropagation();
        els.profileDropdown.classList.toggle('hidden');
    });
    document.addEventListener('click', () => els.profileDropdown.classList.add('hidden'));
    
    // Make stat cards clickable
    const statMapping = {
        'card-pending': 'Pending',
        'card-collected': 'Collected',
        'card-processing': 'Processing',
        'card-critical': 'Critical'
    };
    for (let id in statMapping) {
        document.getElementById(id).addEventListener('click', () => {
            els.navItems[0].click(); // Go to dashboard
            els.filterStatus.value = statMapping[id];
            els.btnApplyFilters.click();
        });
    }
}

function setupFilters() {
    els.btnFilterToggle.addEventListener('click', () => els.filterPanel.classList.toggle('hidden'));
    
    const updateRiskDisplay = () => {
        let min = parseInt(els.filterMinRisk.value);
        let max = parseInt(els.filterMaxRisk.value);
        if (min > max) { let temp = min; min = max; max = temp; }
        els.riskValDisplay.textContent = `${min} - ${max}`;
    };
    els.filterMinRisk.addEventListener('input', updateRiskDisplay);
    els.filterMaxRisk.addEventListener('input', updateRiskDisplay);

    els.btnApplyFilters.addEventListener('click', () => {
        let min = parseInt(els.filterMinRisk.value) || 0;
        let max = parseInt(els.filterMaxRisk.value) || 100;
        if (min > max) { let temp = min; min = max; max = temp; }
        
        activeFilters = {
            search: els.globalSearch.value,
            status: els.filterStatus.value,
            urgency: els.filterUrgency.value,
            minRisk: min,
            maxRisk: max,
            sort: els.filterSort.value
        };
        renderWorkQueue();
    });

    els.btnClearFilters.addEventListener('click', () => {
        els.globalSearch.value = '';
        els.filterStatus.value = 'All';
        els.filterUrgency.value = 'All';
        els.filterMinRisk.value = 0;
        els.filterMaxRisk.value = 100;
        els.filterSort.value = 'Latest Collection';
        updateRiskDisplay();
        els.btnApplyFilters.click();
    });

    els.globalSearch.addEventListener('keyup', (e) => {
        activeFilters.search = e.target.value;
        renderWorkQueue();
    });
}

function setupModals() {
    const closeModals = () => {
        document.querySelectorAll('.modal-overlay').forEach(m => {
            if(m.id !== 'sidebar-overlay') m.classList.remove('active');
        });
    };
    
    document.getElementById('close-collect-modal').addEventListener('click', closeModals);
    document.getElementById('cancel-collect-btn').addEventListener('click', closeModals);
    
    document.getElementById('close-results-modal').addEventListener('click', closeModals);
    document.getElementById('cancel-results-btn').addEventListener('click', closeModals);
    
    document.getElementById('close-timeline-modal').addEventListener('click', closeModals);
    document.getElementById('done-timeline-btn').addEventListener('click', closeModals);

    // Save Collect Action
    document.getElementById('save-collect-btn').addEventListener('click', () => {
        const id = document.getElementById('col-record-id').value;
        labService.updateStatus(id, 'Collected');
        showToast('Sample collection confirmed.');
        closeModals();
        renderAll();
    });

    // Save Results Action
    document.getElementById('save-results-btn').addEventListener('click', () => {
        const id = document.getElementById('res-order-id-hidden').value;
        const val = document.getElementById('res-value').value.trim();
        if(!val) {
            document.getElementById('res-error').classList.remove('hidden');
            return;
        }
        
        const rStatus = document.getElementById('res-status').value;
        const resultData = {
            result: val,
            unit: document.getElementById('res-unit').value.trim(),
            referenceRange: document.getElementById('res-range').value.trim(),
            resultStatus: rStatus,
            notes: document.getElementById('res-notes').value.trim()
        };
        
        labService.addResult(id, resultData);
        showToast(rStatus === 'Critical' ? 'Critical result logged and alerted!' : 'Result saved successfully.', rStatus === 'Critical');
        closeModals();
        renderAll();
    });
}

// ---------------------------
// Global Workflow Functions
// ---------------------------
window.confirmRecord = (id) => {
    labService.updateStatus(id, 'Pending');
    showToast(`Order ${id} confirmed. Added to Pending queue.`);
    renderAll();
};

window.openCollectModal = (id) => {
    const r = labService.getRecordById(id);
    if(!r) return;
    document.getElementById('col-patient').textContent = `${r.patientName} (${r.patientId})`;
    document.getElementById('col-test').textContent = r.testName;
    document.getElementById('col-type').textContent = r.sampleType;
    document.getElementById('col-time').textContent = `${r.collectionDate} @ ${r.collectionTime}`;
    document.getElementById('col-record-id').value = r.id;
    els.collectModal.classList.add('active');
};

window.startProcessing = (id) => {
    labService.updateStatus(id, 'Processing');
    showToast(`Order ${id} is now processing.`);
    renderAll();
};

window.openResultsModal = (id) => {
    const r = labService.getRecordById(id);
    if(!r) return;
    document.getElementById('res-patient-name').textContent = `${r.patientName} (${r.patientId})`;
    document.getElementById('res-order-id').textContent = r.id;
    document.getElementById('res-panel').textContent = r.testName;
    document.getElementById('res-order-id-hidden').value = r.id;
    
    document.getElementById('res-value').value = '';
    document.getElementById('res-unit').value = '';
    document.getElementById('res-range').value = '';
    document.getElementById('res-status').value = 'Normal';
    document.getElementById('res-notes').value = '';
    document.getElementById('res-error').classList.add('hidden');
    
    els.resultsModal.classList.add('active');
};

window.openTimelineModal = (id) => {
    const r = labService.getRecordById(id);
    if(!r) return;
    
    const content = document.getElementById('timeline-content');
    content.innerHTML = `
        <div style="background:var(--brand-bg); padding:1rem; border-radius:var(--radius-sm); margin-bottom:1.5rem;">
            <p style="font-size:1.1rem; font-weight:600; margin-bottom:0.5rem;">${r.testName}</p>
            <p class="text-secondary" style="font-size:0.9rem;">${r.patientName} (${r.patientId}) • ${r.id}</p>
            <p style="margin-top:0.5rem;"><span class="badge ${riskUtils.getUrgencyBadgeClass(r.urgency)}">${r.urgency}</span> <span class="status-badge ${riskUtils.getStatusBadgeClass(r.status).replace('badge-', '')}">${r.status}</span></p>
        </div>
        
        <h4 style="font-size:0.95rem; margin-bottom:1rem;">Workflow Timeline</h4>
        <div class="timeline">
            <div class="timeline-item">
                <div class="timeline-item-title">Order Created</div>
                <div class="timeline-item-meta">${new Date(r.createdAt).toLocaleString()}</div>
            </div>
            ${r.status === 'Completed' || r.status === 'Critical' ? `
            <div class="timeline-item">
                <div class="timeline-item-title">Processing Complete</div>
                <div class="timeline-item-meta">${new Date(r.updatedAt).toLocaleString()}</div>
            </div>
            ` : ''}
        </div>
        
        ${(r.status === 'Completed' || r.status === 'Critical') ? `
            <h4 style="font-size:0.95rem; margin-top:2rem; margin-bottom:1rem;">Lab Result</h4>
            <div class="card p-4" style="padding:1.5rem;">
                <p style="font-size:1.5rem; font-weight:700; color:${r.resultStatus === 'Critical' ? 'var(--color-danger)' : r.resultStatus === 'Abnormal' ? 'var(--color-warning)' : 'var(--text-dark)'}">${r.result} <span style="font-size:1rem; font-weight:500;">${r.unit !== 'N/A' ? r.unit : ''}</span></p>
                <p class="text-secondary" style="font-size:0.85rem; margin-top:0.25rem;">Reference: ${r.referenceRange || 'N/A'}</p>
                ${r.notes ? `<p style="font-size:0.9rem; margin-top:1rem; padding-top:1rem; border-top:1px solid var(--border-color);"><strong>Notes:</strong> ${r.notes}</p>` : ''}
            </div>
        ` : ''}
    `;
    
    els.timelineModal.classList.add('active');
};

document.addEventListener('DOMContentLoaded', init);
