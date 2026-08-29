document.addEventListener('DOMContentLoaded', () => {
    const sidebar = document.getElementById('sidebar');
    const overlay = document.getElementById('sidebar-overlay');
    const menuToggle = document.getElementById('mobile-menu-toggle');
    const closeSidebarBtn = document.getElementById('close-sidebar');

    // Navigation Active States
    const navItems = document.querySelectorAll('.nav-item');
    navItems.forEach(item => {
        item.addEventListener('click', (e) => {
            e.preventDefault();
            navItems.forEach(nav => nav.classList.remove('active'));
            item.classList.add('active');
            if (window.innerWidth <= 768) {
                closeMobileSidebar();
            }
        });
    });

    // Mobile Sidebar Toggle
    function openMobileSidebar() {
        sidebar.classList.add('open');
        overlay.classList.add('active');
    }

    function closeMobileSidebar() {
        sidebar.classList.remove('open');
        overlay.classList.remove('active');
    }

    menuToggle.addEventListener('click', openMobileSidebar);
    closeSidebarBtn.addEventListener('click', closeMobileSidebar);
    overlay.addEventListener('click', closeMobileSidebar);

    // Initial Data
    const rowData = [
        { patient: 'Rahul Kumar', meds: '3 medications', status: 'New Prescription', action: 'Dispense' },
        { patient: 'Priya Sharma', meds: '2 medications', status: 'Ready to Dispense', action: 'Dispense' },
        { patient: 'Arjun Rao', meds: '4 medications', status: 'Out for Delivery', action: 'Track' },
        { patient: 'Meera Iyer', meds: '1 medication', status: 'Delivered', action: 'View' },
        { patient: 'Sohan Das', meds: '2 medications', status: 'New Prescription', action: 'Dispense' }
    ];

    // Build Mobile Cards
    const mobileContainer = document.getElementById('mobile-cards-container');
    function renderMobileCards(data) {
        mobileContainer.innerHTML = '';
        if (data.length === 0) {
            mobileContainer.innerHTML = '<p class="text-secondary" style="padding: 1rem; text-align: center;">No prescriptions found.</p>';
            return;
        }

        data.forEach(row => {
            let badgeClass = 'orange';
            if (row.status === 'Ready to Dispense' || row.status === 'Delivered') badgeClass = 'green';
            if (row.status === 'Out for Delivery') badgeClass = 'blue';

            const card = document.createElement('div');
            card.className = 'card-item';
            card.innerHTML = `
                <div style="display: flex; justify-content: space-between; align-items: flex-start;">
                    <div>
                        <div style="font-weight: 600; color: var(--text-dark); margin-bottom: 0.25rem;">${row.patient}</div>
                        <div style="font-size: 0.85rem; color: var(--text-secondary);">${row.meds}</div>
                    </div>
                    <span class="status-badge ${badgeClass}">${row.status}</span>
                </div>
                <div style="display: flex; justify-content: flex-end;">
                    <button class="action-btn" style="width: 100%; text-align: center;">${row.action}</button>
                </div>
            `;
            mobileContainer.appendChild(card);
        });
    }

    // Desktop Table Rendering
    const tbody = document.getElementById('queue-tbody');
    function renderDesktopTable(data) {
        tbody.innerHTML = '';
        if (data.length === 0) {
            tbody.innerHTML = '<tr><td colspan="4" style="text-align: center; color: var(--text-secondary);">No prescriptions found.</td></tr>';
            return;
        }

        data.forEach(row => {
            let badgeClass = 'orange';
            if (row.status === 'Ready to Dispense' || row.status === 'Delivered') badgeClass = 'green';
            if (row.status === 'Out for Delivery') badgeClass = 'blue';

            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td class="patient-name">${row.patient}</td>
                <td>${row.meds}</td>
                <td><span class="status-badge ${badgeClass}">${row.status}</span></td>
                <td><button class="action-btn">${row.action}</button></td>
            `;
            tbody.appendChild(tr);
        });
    }

    // Initial render
    renderMobileCards(rowData);
    renderDesktopTable(rowData);

    // Filtering logic
    const searchInput = document.getElementById('search-input');
    const statusFilter = document.getElementById('status-filter');
    const statCards = document.querySelectorAll('.stat-card');

    function filterData() {
        const term = searchInput.value.toLowerCase();
        const status = statusFilter.value;

        const filtered = rowData.filter(row => {
            const matchSearch = row.patient.toLowerCase().includes(term);
            const matchStatus = status === 'All Status' || row.status === status || (status === 'Refill' && row.status === 'New Prescription'); // Mocking Refill behavior for demo
            return matchSearch && matchStatus;
        });

        renderMobileCards(filtered);
        renderDesktopTable(filtered);
    }

    searchInput.addEventListener('input', filterData);
    statusFilter.addEventListener('change', filterData);

    // Clickable stat cards to filter
    statCards.forEach(card => {
        card.addEventListener('click', () => {
            const filterVal = card.getAttribute('data-filter');
            if (filterVal) {
                // If it doesn't match an exact option, fallback to a sensible one for demo
                const options = Array.from(statusFilter.options).map(o => o.value);
                if (options.includes(filterVal)) {
                    statusFilter.value = filterVal;
                } else {
                    statusFilter.value = 'All Status';
                }
                filterData();
            }
        });
    });
});
