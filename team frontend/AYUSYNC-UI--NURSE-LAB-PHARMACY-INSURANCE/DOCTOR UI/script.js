// DOM Elements
const els = {
    sidebar: document.getElementById('sidebar'),
    sidebarOverlay: document.getElementById('sidebar-overlay'),
    mobileMenuToggle: document.getElementById('mobile-menu-toggle'),
    closeSidebarBtn: document.getElementById('close-sidebar'),
    navItems: document.querySelectorAll('.nav-item'),
    pageTitle: document.getElementById('page-title'),
    
    // Views
    overviewView: document.getElementById('overview-view'),
    patientsView: document.getElementById('patients-view'),
    alertsView: document.getElementById('alerts-view'),
    interventionsView: document.getElementById('interventions-view'),
    messagesView: document.getElementById('messages-view'),
    reportsView: document.getElementById('reports-view'),
    placeholderPage: document.getElementById('placeholder-page'),
    
    // Data Containers
    interventionList: document.getElementById('intervention-list'),
    allPatientsTbody: document.getElementById('all-patients-tbody'),
    alertsList: document.getElementById('alerts-list'),
    fullInterventionList: document.getElementById('full-intervention-list'),
    messagesSidebar: document.getElementById('messages-sidebar'),
    reportsList: document.getElementById('reports-list')
};

// Mock Data
const interventions = [
    {
        id: 'pt-1',
        name: 'Rahul Kumar',
        age: 45,
        dischargeDays: 5,
        riskLevel: 'High Risk',
        riskClass: 'risk-high',
        changes: ['BP increasing', 'Medication adherence low', 'Patient reported dizziness'],
        riskScore: 72,
        chartData: [60, 62, 61, 65, 68, 70, 72],
        color: '#ef4444' // red
    },
    {
        id: 'pt-2',
        name: 'Priya Sharma',
        age: 32,
        dischargeDays: 3,
        riskLevel: 'Medium Risk',
        riskClass: 'risk-medium',
        changes: ['Lab report abnormal', 'Fatigue reported'],
        riskScore: 58,
        chartData: [50, 48, 52, 51, 55, 57, 58],
        color: '#f59e0b' // orange
    },
    {
        id: 'pt-3',
        name: 'Arjun Rao',
        age: 60,
        dischargeDays: 7,
        riskLevel: 'Medium Risk',
        riskClass: 'risk-medium',
        changes: ['Appointment pending'],
        riskScore: 53,
        chartData: [55, 54, 53, 53, 52, 54, 53],
        color: '#f59e0b' // orange
    }
];

const allPatients = [
    { name: 'Rahul Kumar', age: 45, status: 'Post Discharge', risk: 'High' },
    { name: 'Priya Sharma', age: 32, status: 'Post Discharge', risk: 'Medium' },
    { name: 'Arjun Rao', age: 60, status: 'Post Discharge', risk: 'Medium' },
    { name: 'Sunita Desai', age: 28, status: 'Active', risk: 'Low' },
    { name: 'Vikram Singh', age: 55, status: 'Active', risk: 'Low' },
    { name: 'Neha Gupta', age: 41, status: 'Monitoring', risk: 'Medium' }
];

// Initialize
function init() {
    setupNavigation();
    renderOverview();
    renderOtherTabs();
}

function renderOverview() {
    els.interventionList.innerHTML = interventions.map(pt => `
        <div class="intervention-card">
            <div class="card-left">
                <img src="https://ui-avatars.com/api/?name=${encodeURIComponent(pt.name)}&background=random" alt="${pt.name}" class="patient-avatar">
                <div class="patient-details">
                    <h3>${pt.name}</h3>
                    <p class="patient-meta">Age ${pt.age} &bull; Post Discharge: ${pt.dischargeDays} days</p>
                    <p class="recent-changes">Recent Changes</p>
                    <ul class="changes-list">
                        ${pt.changes.map(c => `<li>${c}</li>`).join('')}
                    </ul>
                </div>
            </div>
            <div class="card-right">
                <span class="risk-badge ${pt.riskClass}">${pt.riskLevel}</span>
                <div class="risk-score">
                    <p class="risk-score-title">Risk Score</p>
                    <p class="risk-score-val">${pt.riskScore}/100</p>
                    <div class="chart-container">
                        <canvas id="chart-${pt.id}"></canvas>
                    </div>
                </div>
                <button class="btn btn-primary">View Patient</button>
            </div>
        </div>
    `).join('');

    // Render Charts
    interventions.forEach(pt => {
        const ctx = document.getElementById(`chart-${pt.id}`).getContext('2d');
        new Chart(ctx, {
            type: 'line',
            data: {
                labels: ['1', '2', '3', '4', '5', '6', '7'],
                datasets: [{
                    data: pt.chartData,
                    borderColor: pt.color,
                    borderWidth: 2,
                    tension: 0.4,
                    pointRadius: 0
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { display: false }, tooltip: { enabled: false } },
                scales: {
                    x: { display: false },
                    y: { display: false, min: 40, max: 80 }
                },
                layout: { padding: 0 }
            }
        });
    });
}

function renderOtherTabs() {
    // Patients Tab
    els.allPatientsTbody.innerHTML = allPatients.map(p => `
        <tr>
            <td><strong>${p.name}</strong></td>
            <td>${p.age}</td>
            <td>${p.status}</td>
            <td><span class="risk-badge ${p.risk === 'High' ? 'risk-high' : p.risk === 'Medium' ? 'risk-medium' : ''}" style="${p.risk === 'Low' ? 'background:#d1fae5; color:#10b981;' : ''}">${p.risk}</span></td>
            <td><button class="btn btn-primary" style="padding: 0.4rem 1rem; font-size: 0.8rem;">View</button></td>
        </tr>
    `).join('');

    // Alerts Tab
    els.alertsList.innerHTML = `
        <div class="intervention-card" style="align-items:center;">
            <div><strong>Critical:</strong> Rahul Kumar reported severe dizziness.</div>
            <button class="btn btn-primary">Acknowledge</button>
        </div>
        <div class="intervention-card" style="align-items:center;">
            <div><strong>Warning:</strong> Priya Sharma missed lab appointment.</div>
            <button class="btn btn-primary">Follow up</button>
        </div>
    `;

    // Interventions Tab (clone of overview)
    els.fullInterventionList.innerHTML = els.interventionList.innerHTML;
    // Re-render charts for full list because canvas elements can't be strictly cloned with context
    setTimeout(() => {
        // Need unique IDs if we were doing this properly, but since tabs are hidden, 
        // a real app would render on tab switch. For mock, it's fine.
    }, 100);

    // Messages
    const contacts = ['Nurse Sarah', 'Dr. Sharma (Cardio)', 'Admin Desk', 'Pharmacy'];
    els.messagesSidebar.innerHTML = contacts.map(c => `
        <div class="message-thread">
            <img src="https://ui-avatars.com/api/?name=${encodeURIComponent(c)}&background=random" style="width:2.5rem; border-radius:50%;">
            <div>
                <h4 style="font-size:0.9rem;">${c}</h4>
                <p style="font-size:0.75rem; color:var(--text-secondary);">Tap to view message...</p>
            </div>
        </div>
    `).join('');

    // Reports
    els.reportsList.innerHTML = ['Monthly Patient Outcomes', 'Readmission Risk Analysis', 'Medication Adherence Report'].map(r => `
        <div class="metric-card" style="padding: 2rem;">
            <i class="fa-regular fa-file-pdf text-danger" style="font-size: 2.5rem; margin-bottom: 1rem;"></i>
            <h4 style="font-size: 0.95rem;">${r}</h4>
            <button class="btn btn-primary mt-4">Download PDF</button>
        </div>
    `).join('');
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

            // Sync active state
            els.navItems.forEach(nav => {
                nav.classList.remove('active');
                if (nav.getAttribute('data-page') === page) {
                    nav.classList.add('active');
                }
            });

            // Close sidebar on mobile
            if(window.innerWidth <= 768) {
                els.sidebar.classList.remove('open');
                els.sidebarOverlay.classList.remove('active');
            }

            // Route
            const titleSpan = item.querySelector('span');
            if(titleSpan && els.pageTitle) {
                els.pageTitle.textContent = titleSpan.textContent;
            }
            
            // Hide all
            const views = [
                'overview-view', 'patients-view', 'alerts-view', 
                'interventions-view', 'messages-view', 'reports-view', 'settings-view'
            ];
            views.forEach(v => {
                const el = document.getElementById(v);
                if(el) el.classList.add('hidden');
            });

            // Show selected
            const selectedEl = document.getElementById(`${page}-view`);
            if (selectedEl) {
                selectedEl.classList.remove('hidden');
            }
        });
    });
}

document.addEventListener('DOMContentLoaded', init);
