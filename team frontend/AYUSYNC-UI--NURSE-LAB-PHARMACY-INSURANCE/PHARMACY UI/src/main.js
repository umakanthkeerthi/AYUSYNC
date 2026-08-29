import { pharmacyService } from './services/pharmacyService.js';
import { inventoryService } from './services/inventoryService.js';
import { riskUtils } from './utils/riskUtils.js';
import { filterUtils } from './utils/filterUtils.js';

document.addEventListener('DOMContentLoaded', () => {
    pharmacyService.init();

    const views = {
        prescriptions: document.getElementById('prescriptions-view'),
        refills: document.getElementById('refills-view'),
        deliveries: document.getElementById('deliveries-view'),
        inventory: document.getElementById('inventory-view'),
        reports: document.getElementById('reports-view'),
        settings: document.getElementById('settings-view')
    };
    
    // --- ROUTING (SPA) ---
    const navigateTo = (page, pushState = true) => {
        if(!views[page]) page = 'prescriptions'; // Default
        
        if(pushState) window.history.pushState({}, '', `/${page}`);
        
        const navItems = document.querySelectorAll('.nav-item');
        navItems.forEach(nav => nav.classList.remove('active'));
        const activeNav = document.querySelector(`.nav-item[data-page="${page}"]`);
        if(activeNav) {
            activeNav.classList.add('active');
            document.getElementById('page-title').innerText = activeNav.querySelector('span').innerText;
        }
        
        Object.values(views).forEach(v => v.classList.add('hidden'));
        if(views[page]) views[page].classList.remove('hidden');
        
        if (window.innerWidth <= 768) {
            document.getElementById('sidebar').classList.remove('open');
            document.getElementById('sidebar-overlay').classList.remove('active');
        }
        
        renderCurrentView(page);
    };

    document.querySelectorAll('.nav-item').forEach(item => {
        item.addEventListener('click', (e) => {
            e.preventDefault();
            navigateTo(item.getAttribute('data-page'));
        });
    });
    
    window.addEventListener('popstate', () => {
        navigateTo(window.location.pathname.replace('/', '') || 'prescriptions', false);
    });

    // Sidebar Mobile
    document.getElementById('mobile-menu-toggle').addEventListener('click', () => {
        document.getElementById('sidebar').classList.add('open');
        document.getElementById('sidebar-overlay').classList.add('active');
    });
    const closeSidebar = () => {
        document.getElementById('sidebar').classList.remove('open');
        document.getElementById('sidebar-overlay').classList.remove('active');
    };
    document.getElementById('close-sidebar').addEventListener('click', closeSidebar);
    document.getElementById('sidebar-overlay').addEventListener('click', closeSidebar);

    // Dropdowns & Filter Panel
    const toggleDropdown = (btnId, dropId) => {
        const btn = document.getElementById(btnId);
        const drop = document.getElementById(dropId);
        btn.addEventListener('click', (e) => { e.stopPropagation(); drop.classList.toggle('hidden'); });
        document.addEventListener('click', (e) => { if(!drop.contains(e.target)) drop.classList.add('hidden'); });
    };
    toggleDropdown('profile-btn', 'profile-dropdown');
    toggleDropdown('notif-btn', 'notif-dropdown');
    document.getElementById('btn-filter-toggle').addEventListener('click', () => document.getElementById('filter-panel').classList.toggle('hidden'));

    let currentFilters = { search: '', status: 'All', urgency: 'All', minRisk: 0, maxRisk: 100, sortBy: 'Newest' };

    // --- RENDER LOGIC ---
    function renderCurrentView(page) {
        if(!page) {
            const activeNav = document.querySelector('.nav-item.active');
            page = activeNav ? activeNav.getAttribute('data-page') : 'prescriptions';
        }
        
        updateTopStats();
        updateNotifications();
        const data = pharmacyService.getData();
        
        if(page === 'prescriptions') {
            const filtered = filterUtils.sortRecords(filterUtils.applyFilters(data.prescriptions, currentFilters), currentFilters.sortBy);
            if(document.getElementById('filter-count')) document.getElementById('filter-count').innerText = `${filtered.length} records`;
            renderPrescriptions(filtered);
        } else if(page === 'refills') {
            renderRefills(data.refills);
        } else if(page === 'deliveries') {
            renderDeliveries(data.deliveries);
        } else if(page === 'inventory') {
            renderInventory(data.inventory);
        } else if(page === 'reports') {
            renderReports(data);
        } else if(page === 'settings') {
            loadSettings();
        }
    }

    function updateTopStats() {
        const stats = pharmacyService.getDashboardStats();
        if(document.getElementById('stat-new')) {
            document.getElementById('stat-new').innerText = stats.newPrescriptions;
            document.getElementById('stat-refills').innerText = stats.refills;
            document.getElementById('stat-delivery').innerText = stats.deliveryPending;
            document.getElementById('stat-urgent').innerText = stats.urgent;
        }
    }

    function updateNotifications() {
        const alerts = inventoryService.checkAlerts();
        const list = document.getElementById('notif-list');
        list.innerHTML = alerts.length ? alerts.map(a => `<div style="padding:0.75rem; border-bottom:1px solid var(--border-color); font-size:0.85rem;"><span class="badge badge-warning" style="margin-bottom:0.25rem; display:inline-block;">Inventory</span><br>${a}</div>`).join('') : '<div style="padding:1rem; text-align:center; color:var(--text-secondary); font-size:0.85rem;">No new notifications</div>';
        document.getElementById('notif-count').innerText = alerts.length;
    }

    // --- RENDER VIEWS ---
    function renderPrescriptions(records) {
        const tbody = document.getElementById('queue-tbody');
        const mobile = document.getElementById('mobile-queue-container');
        if(!tbody || !mobile) return;
        
        tbody.innerHTML = records.length ? records.map(r => `
            <tr>
                <td><div class="patient-name">${r.patientName}</div><div style="font-size:0.8rem; color:var(--text-secondary);">${r.patientId}</div></td>
                <td><div style="font-weight:500;">${r.medications}</div><div style="font-size:0.8rem; color:var(--text-secondary);">By ${r.prescribedBy}</div></td>
                <td><span class="badge ${riskUtils.getUrgencyBadgeClass(r.urgency)}">${r.urgency}</span> <span class="badge ${riskUtils.getRiskBadgeClass(r.riskScore)}">${r.riskScore}/100</span></td>
                <td><span class="status-badge ${riskUtils.getPrescriptionStatusBadge(r.status)}">${r.status}</span></td>
                <td><button class="action-btn wf-btn" data-id="${r.id}">Process</button></td>
            </tr>`).join('') : `<tr><td colspan="5" style="text-align:center;">No records found.</td></tr>`;
            
        mobile.innerHTML = records.map(r => `
            <div class="card p-4">
                <div style="display:flex; justify-content:space-between; margin-bottom:0.5rem;"><div><span style="font-weight:600;">${r.patientName}</span> <span style="color:var(--text-secondary); font-size:0.85rem;">${r.patientId}</span></div><span class="status-badge ${riskUtils.getPrescriptionStatusBadge(r.status)}">${r.status}</span></div>
                <div style="font-size:0.9rem; margin-bottom:1rem;">${r.medications}</div>
                <div style="display:flex; justify-content:space-between; align-items:center;"><div><span class="badge ${riskUtils.getUrgencyBadgeClass(r.urgency)}">${r.urgency}</span> <span class="badge ${riskUtils.getRiskBadgeClass(r.riskScore)}">${r.riskScore}/100</span></div><button class="action-btn wf-btn" data-id="${r.id}">Process</button></div>
            </div>`).join('');
            
        document.querySelectorAll('.wf-btn').forEach(btn => btn.addEventListener('click', openWorkflowModal));
    }

    function renderRefills(records) {
        const tbody = document.getElementById('refills-tbody');
        if(!tbody) return;
        tbody.innerHTML = records.map(r => {
            let actions = '';
            if(r.status === 'Requested' || r.status === 'Under Review') {
                actions = `<button class="action-btn rfl-btn" data-id="${r.id}" data-action="Approved" style="color:var(--stat-green); border-color:var(--badge-green-bg);">Approve</button> 
                           <button class="action-btn rfl-btn" data-id="${r.id}" data-action="Rejected" style="color:var(--stat-red); border-color:var(--badge-red-bg);">Reject</button>`;
            } else if(r.status === 'Approved') {
                actions = `<button class="action-btn rfl-btn" data-id="${r.id}" data-action="Dispensed">Dispense</button>`;
            }
            return `<tr>
                <td class="patient-name">${r.patientName}</td>
                <td>${r.medicine}</td>
                <td>${r.refillCount}</td>
                <td>${new Date(r.date).toLocaleDateString()}</td>
                <td><span class="badge ${r.status==='Approved'?'badge-success':(r.status==='Requested'?'badge-orange':(r.status==='Rejected'?'badge-danger':(r.status==='Dispensed'?'badge-info':'badge-gray')))}">${r.status}</span></td>
                <td>${actions}</td>
            </tr>`;
        }).join('');
        
        document.querySelectorAll('.rfl-btn').forEach(btn => btn.addEventListener('click', (e) => {
            const id = e.target.getAttribute('data-id');
            const action = e.target.getAttribute('data-action');
            pharmacyService.updateRefillStatus(id, action);
            showToast(`Refill ${action}!`);
            renderCurrentView();
        }));
    }

    function renderDeliveries(records) {
        const tbody = document.getElementById('deliveries-tbody');
        if(!tbody) return;
        tbody.innerHTML = records.map(r => {
            let nextAction = '';
            let nextStatus = '';
            if(r.status === 'Pending') { nextAction = 'Prepare'; nextStatus = 'Preparing'; }
            else if(r.status === 'Preparing') { nextAction = 'Dispatch'; nextStatus = 'Out for Delivery'; }
            else if(r.status === 'Out for Delivery') { nextAction = 'Mark Delivered'; nextStatus = 'Delivered'; }
            
            const actBtn = nextAction ? `<button class="action-btn dlv-act-btn" data-id="${r.id}" data-next="${nextStatus}">${nextAction}</button>` : '';
            return `<tr>
                <td>${r.id}</td>
                <td class="patient-name">${r.patientName}</td>
                <td>${r.address}</td>
                <td>${new Date(r.date).toLocaleDateString()}</td>
                <td><span class="status-badge ${riskUtils.getDeliveryStatusBadge(r.status)}">${r.status}</span></td>
                <td><button class="action-btn dlv-trk-btn" data-id="${r.id}" style="margin-right:0.5rem;">Track</button>${actBtn}</td>
            </tr>`;
        }).join('');

        document.querySelectorAll('.dlv-act-btn').forEach(btn => btn.addEventListener('click', (e) => {
            pharmacyService.updateDeliveryStatus(e.target.getAttribute('data-id'), e.target.getAttribute('data-next'));
            showToast(`Delivery updated to ${e.target.getAttribute('data-next')}`);
            renderCurrentView();
        }));

        document.querySelectorAll('.dlv-trk-btn').forEach(btn => btn.addEventListener('click', (e) => {
            const r = records.find(x => x.id === e.target.getAttribute('data-id'));
            const steps = ['Pending', 'Preparing', 'Out for Delivery', 'Delivered'];
            let currentIdx = steps.indexOf(r.status);
            if(currentIdx === -1) currentIdx = steps.length;
            
            const html = steps.map((s, i) => `
                <div class="timeline-item">
                    <div class="timeline-item-title" style="${i <= currentIdx ? 'color:var(--text-dark);' : 'color:var(--text-secondary);'}">${s}</div>
                    <div class="timeline-item-meta">${i <= currentIdx ? 'Completed' : 'Pending'}</div>
                </div>
            `).join('');
            document.getElementById('timeline-content').innerHTML = `<div class="timeline">${html}</div>`;
            openModal('timeline-modal');
        }));
    }

    function renderInventory(records) {
        const tbody = document.getElementById('inventory-tbody');
        if(!tbody) return;
        tbody.innerHTML = records.map(r => `
            <tr>
                <td class="patient-name">${r.medicine}</td>
                <td>${r.category}</td>
                <td>${r.available} <span style="font-size:0.8rem; color:var(--text-secondary);">(Min: ${r.reorderLevel})</span></td>
                <td>${r.expiry}</td>
                <td><span class="status-badge ${riskUtils.getInventoryStatusBadge(r.status)}">${r.status}</span></td>
                <td><button class="action-btn inv-upd-btn" data-id="${r.id}" data-name="${r.medicine}" data-curr="${r.available}">Update Stock</button></td>
            </tr>
        `).join('');

        document.querySelectorAll('.inv-upd-btn').forEach(btn => btn.addEventListener('click', (e) => {
            document.getElementById('stock-id').value = e.target.getAttribute('data-id');
            document.getElementById('stock-med-name').innerText = e.target.getAttribute('data-name');
            document.getElementById('stock-current').innerText = e.target.getAttribute('data-curr');
            document.getElementById('stock-change').value = '0';
            openModal('stock-modal');
        }));
    }

    function renderReports(data) {
        // Prescriptions
        document.getElementById('rep-rx-total').innerText = data.prescriptions.length;
        document.getElementById('rep-rx-new').innerText = data.prescriptions.filter(p=>p.status==='New').length;
        document.getElementById('rep-rx-dispensed').innerText = data.prescriptions.filter(p=>p.status==='Dispensed').length;
        document.getElementById('rep-rx-urgent').innerText = data.prescriptions.filter(p=>p.urgency==='Urgent').length;
        
        // Refills & Deliveries
        document.getElementById('rep-rf-req').innerText = data.refills.filter(r=>r.status==='Requested' || r.status==='Under Review').length;
        document.getElementById('rep-rf-app').innerText = data.refills.filter(r=>r.status==='Approved').length;
        document.getElementById('rep-dl-pend').innerText = data.deliveries.filter(d=>d.status!=='Delivered' && d.status!=='Failed').length;
        document.getElementById('rep-dl-del').innerText = data.deliveries.filter(d=>d.status==='Delivered').length;

        // Inventory
        document.getElementById('rep-inv-total').innerText = data.inventory.length;
        document.getElementById('rep-inv-low').innerText = data.inventory.filter(i=>i.status==='Low Stock').length;
        document.getElementById('rep-inv-out').innerText = data.inventory.filter(i=>i.status==='Out of Stock').length;
        document.getElementById('rep-inv-exp').innerText = data.inventory.filter(i=>i.status==='Expiring Soon').length;
    }

    // --- MODALS & WORKFLOWS ---
    const openModal = (id) => document.getElementById(id).classList.add('active');
    document.querySelectorAll('.close-modal').forEach(btn => btn.addEventListener('click', (e) => { e.preventDefault(); e.target.closest('.modal-overlay').classList.remove('active'); }));
    const showToast = (msg) => {
        const toast = document.createElement('div'); toast.className = 'toast show';
        toast.innerHTML = `<i class="fa-solid fa-circle-check" style="color:var(--stat-green);"></i> <span>${msg}</span>`;
        document.getElementById('toast-container').appendChild(toast);
        setTimeout(() => toast.remove(), 3000);
    };

    // Prescription Modal
    if(document.getElementById('btn-new-rx')) document.getElementById('btn-new-rx').addEventListener('click', () => openModal('new-rx-modal'));
    if(document.getElementById('save-rx-btn')) document.getElementById('save-rx-btn').addEventListener('click', (e) => {
        e.preventDefault();
        const pt = document.getElementById('rx-patient').value, dr = document.getElementById('rx-doctor').value, meds = document.getElementById('rx-meds').value;
        if(!pt || !dr || !meds) return alert('Please fill required fields');
        pharmacyService.addPrescription({ patientName: pt, patientId: `PT-${Math.floor(1000+Math.random()*9000)}`, prescribedBy: dr, medications: meds, urgency: document.getElementById('rx-urgency').value, riskScore: parseInt(document.getElementById('rx-risk').value) });
        document.getElementById('new-rx-form').reset();
        document.getElementById('new-rx-modal').classList.remove('active');
        showToast('Prescription created successfully!');
        renderCurrentView();
    });

    // Workflow Dispense
    function openWorkflowModal(e) {
        const id = e.target.getAttribute('data-id');
        const rx = pharmacyService.getData().prescriptions.find(r => r.id === id);
        document.getElementById('wf-id').value = id;
        document.getElementById('wf-patient').innerText = rx.patientName;
        document.getElementById('wf-meds').innerText = rx.medications;
        document.getElementById('wf-urgency').innerHTML = `<span class="badge ${riskUtils.getUrgencyBadgeClass(rx.urgency)}">${rx.urgency}</span>`;
        document.getElementById('wf-status').innerHTML = `<span class="status-badge ${riskUtils.getPrescriptionStatusBadge(rx.status)}">${rx.status}</span>`;
        
        let nxt = '', pmt = '', btn = 'Confirm';
        if(rx.status === 'New') { nxt = 'Verified'; pmt = 'Verify this prescription to proceed.'; btn = 'Verify'; }
        else if(rx.status === 'Verified') { nxt = 'Preparing'; pmt = 'Begin preparing medications?'; btn = 'Start Prep'; }
        else if(rx.status === 'Preparing') { nxt = 'Ready'; pmt = 'Mark medication as ready for pickup?'; btn = 'Mark Ready'; }
        else if(rx.status === 'Ready') { nxt = 'Dispensed'; pmt = 'Dispense to patient and update inventory?'; btn = 'Dispense'; }
        else { nxt = rx.status; pmt = 'No further actions available.'; btn = 'Close'; }
        
        document.getElementById('wf-next-status').value = nxt;
        document.getElementById('wf-prompt').innerText = pmt;
        document.getElementById('confirm-wf-btn').innerText = btn;
        openModal('workflow-modal');
    }
    if(document.getElementById('confirm-wf-btn')) document.getElementById('confirm-wf-btn').addEventListener('click', () => {
        const id = document.getElementById('wf-id').value, nxt = document.getElementById('wf-next-status').value;
        const rx = pharmacyService.getData().prescriptions.find(r => r.id === id);
        if (rx.status !== nxt) {
            pharmacyService.updatePrescriptionStatus(id, nxt);
            if(nxt === 'Dispensed') showToast(`Dispensed to ${rx.patientName}! Inventory updated.`);
            else showToast(`Status updated to ${nxt}`);
        }
        document.getElementById('workflow-modal').classList.remove('active');
        renderCurrentView();
    });

    // Stock Modal
    if(document.getElementById('save-stock-btn')) document.getElementById('save-stock-btn').addEventListener('click', () => {
        const id = document.getElementById('stock-id').value;
        const change = parseInt(document.getElementById('stock-change').value);
        if(isNaN(change)) return alert('Enter a valid number');
        inventoryService.updateQuantity(id, change);
        showToast('Inventory updated!');
        document.getElementById('stock-modal').classList.remove('active');
        renderCurrentView();
    });

    // Settings
    function loadSettings() {
        const s = JSON.parse(localStorage.getItem('ayusync_pharmacy_settings') || '{"urgent":true,"stock":true,"email":false}');
        document.getElementById('set-notif-urgent').checked = s.urgent;
        document.getElementById('set-notif-stock').checked = s.stock;
        document.getElementById('set-notif-email').checked = s.email;
    }
    if(document.getElementById('save-settings-btn')) document.getElementById('save-settings-btn').addEventListener('click', () => {
        localStorage.setItem('ayusync_pharmacy_settings', JSON.stringify({
            urgent: document.getElementById('set-notif-urgent').checked,
            stock: document.getElementById('set-notif-stock').checked,
            email: document.getElementById('set-notif-email').checked
        }));
        showToast('Settings saved successfully!');
    });

    // Filtering
    const applyFilters = () => {
        currentFilters = {
            search: document.getElementById('global-search').value,
            status: document.getElementById('filter-status').value,
            urgency: document.getElementById('filter-urgency').value,
            minRisk: parseInt(document.getElementById('filter-min-risk').value),
            maxRisk: parseInt(document.getElementById('filter-max-risk').value),
            sortBy: document.getElementById('filter-sort').value
        };
        renderCurrentView();
    };
    if(document.getElementById('global-search')) document.getElementById('global-search').addEventListener('input', applyFilters);
    if(document.getElementById('btn-apply-filters')) document.getElementById('btn-apply-filters').addEventListener('click', () => { applyFilters(); document.getElementById('filter-panel').classList.add('hidden'); });
    if(document.getElementById('btn-clear-filters')) document.getElementById('btn-clear-filters').addEventListener('click', () => {
        ['filter-status', 'filter-urgency'].forEach(id => document.getElementById(id).value = 'All');
        document.getElementById('filter-min-risk').value = '0'; document.getElementById('filter-max-risk').value = '100'; document.getElementById('filter-sort').value = 'Newest';
        applyFilters();
    });
    ['filter-min-risk', 'filter-max-risk'].forEach(id => {
        if(document.getElementById(id)) document.getElementById(id).addEventListener('input', () => {
            document.getElementById('risk-val-display').innerText = `${document.getElementById('filter-min-risk').value} - ${document.getElementById('filter-max-risk').value}`;
        });
    });
    const resetCards = () => document.querySelectorAll('.stat-card').forEach(c => c.classList.remove('active-filter'));
    if(document.getElementById('card-new')) document.getElementById('card-new').addEventListener('click', () => { resetCards(); document.getElementById('card-new').classList.add('active-filter'); document.getElementById('filter-status').value = 'New'; applyFilters(); });
    if(document.getElementById('card-urgent')) document.getElementById('card-urgent').addEventListener('click', () => { resetCards(); document.getElementById('card-urgent').classList.add('active-filter'); document.getElementById('filter-urgency').value = 'Urgent'; applyFilters(); });

    // Initial Start
    const initialPath = window.location.pathname.replace('/', '') || 'prescriptions';
    navigateTo(initialPath, false);
});
