// Mock Data matching the design
const patients = [
    {
        id: 1,
        name: "Rahul Kumar",
        condition: "Medication adherence low",
        meta: "Age 45 • Post Discharge: 5 days",
        priority: "High Priority",
        priorityClass: "badge-high",
        image: "https://ui-avatars.com/api/?name=Rahul+Kumar&background=random"
    },
    {
        id: 2,
        name: "Priya Sharma",
        condition: "Lab report pending",
        meta: "Age 32 • Post Discharge: 3 days",
        priority: "Medium Priority",
        priorityClass: "badge-medium",
        image: "https://ui-avatars.com/api/?name=Priya+Sharma&background=random"
    },
    {
        id: 3,
        name: "Arjun Rao",
        condition: "Appointment not confirmed",
        meta: "Age 60 • Post Discharge: 7 days",
        priority: "Medium Priority",
        priorityClass: "badge-medium",
        image: "https://ui-avatars.com/api/?name=Arjun+Rao&background=random"
    },
    {
        id: 4,
        name: "Meera Iyer",
        condition: "On track",
        meta: "Age 28 • Post Discharge: 4 days",
        priority: "Low Priority",
        priorityClass: "badge-low",
        image: "https://ui-avatars.com/api/?name=Meera+Iyer&background=random"
    }
];

// Populate Patient Queue
function renderPatients() {
    const patientList = document.getElementById('patient-list');
    patientList.innerHTML = '';

    patients.forEach(patient => {
        const patientHTML = `
            <div class="patient-row">
                <div class="patient-info-col">
                    <img src="${patient.image}" alt="${patient.name}" class="avatar">
                    <div class="patient-details">
                        <h3>${patient.name}</h3>
                        <p>${patient.condition}</p>
                        <span class="patient-meta">${patient.meta}</span>
                    </div>
                </div>
                <div class="patient-actions-col">
                    <span class="priority-badge ${patient.priorityClass}">${patient.priority}</span>
                    <button class="btn btn-outline view-btn" data-id="${patient.id}">View</button>
                </div>
            </div>
        `;
        patientList.insertAdjacentHTML('beforeend', patientHTML);
    });

    // Attach event listeners to new buttons
    attachModalEvents();
}

// Interactivity - Sidebar
function setupSidebar() {
    const navItems = document.querySelectorAll('.sidebar-nav .nav-item');
    navItems.forEach(item => {
        item.addEventListener('click', function(e) {
            e.preventDefault();
            navItems.forEach(nav => nav.classList.remove('active'));
            this.classList.add('active');
        });
    });
}

// Interactivity - Modal
const modalOverlay = document.getElementById('patient-modal');
const modalTitle = document.getElementById('modal-title');
const modalBody = document.getElementById('modal-body');
const closeModalBtn = document.getElementById('close-modal');

function openModal(patientId) {
    const patient = patients.find(p => p.id === parseInt(patientId));
    if (patient) {
        modalTitle.textContent = `Patient: ${patient.name}`;
        modalBody.innerHTML = `
            <p><strong>Condition:</strong> ${patient.condition}</p>
            <p><strong>Details:</strong> ${patient.meta}</p>
            <p><strong>Status:</strong> <span style="font-weight: 600;" class="${
                patient.priority === 'High Priority' ? 'text-danger' : 
                patient.priority === 'Medium Priority' ? 'text-warning' : 'text-success'
            }">${patient.priority}</span></p>
            <hr style="margin: 1rem 0; border: none; border-top: 1px solid var(--border-dark);">
            <p>Full chart details and historical records would load here in the production application. The nurse can take actions such as updating vitals, adjusting medication schedules, or messaging the assigned doctor directly from this view.</p>
        `;
        modalOverlay.classList.add('active');
    }
}

function attachModalEvents() {
    const viewButtons = document.querySelectorAll('.view-btn');
    viewButtons.forEach(btn => {
        btn.addEventListener('click', (e) => {
            const patientId = e.currentTarget.getAttribute('data-id');
            openModal(patientId);
        });
    });
}

closeModalBtn.addEventListener('click', () => {
    modalOverlay.classList.remove('active');
});

modalOverlay.addEventListener('click', (e) => {
    if (e.target === modalOverlay) {
        modalOverlay.classList.remove('active');
    }
});

// Initialize on Load
document.addEventListener('DOMContentLoaded', () => {
    renderPatients();
    setupSidebar();
});
