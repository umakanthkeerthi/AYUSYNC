/* ==========================================================================
   AYUSYNC CAREGIVER INTERFACE - TYPESCRIPT CORE LOGIC (src/app.ts)
   ========================================================================== */
import { caregiverTranslations } from './i18n.js';
class AyuSyncCaregiverApp {
    constructor() {
        this.currentPatientId = 'rahul';
        this.currentLang = localStorage.getItem('ayusync_caregiver_lang') || 'en';
        this.patients = {
            rahul: {
                id: 'rahul',
                name: 'Rahul Kumar',
                avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80',
                status: 'Stable',
                lastUpdated: '10 min ago',
                medicationStatus: 'Completed',
                bloodTestStatus: 'Tomorrow',
                appointmentTime: '4:00 PM',
                transportAlert: "Patient hasn't confirmed tomorrow's transport for blood test."
            },
            priya: {
                id: 'priya',
                name: 'Priya Sharma',
                avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80',
                status: 'Observation',
                lastUpdated: '2 min ago',
                medicationStatus: '1 Pending',
                bloodTestStatus: 'Today 11:30 AM',
                appointmentTime: 'Tomorrow',
                transportAlert: 'BP reading requested by doctor at 2:00 PM.'
            },
            amit: {
                id: 'amit',
                name: 'Amit Patel',
                avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80',
                status: 'Stable',
                lastUpdated: '25 min ago',
                medicationStatus: 'Completed',
                bloodTestStatus: 'Aug 24',
                appointmentTime: 'Aug 22 10:00 AM',
                transportAlert: 'Prescription refill requested for Metoprolol.'
            }
        };
        this.patientSelect = document.getElementById('patientSelect');
        this.langSelect = document.getElementById('langSelect');
        this.patientAvatarImg = document.getElementById('patientAvatarImg');
        this.navTabs = document.querySelectorAll('.nav-tab');
        this.pageViews = document.querySelectorAll('.page-view');
        this.transportModal = document.getElementById('transportModal');
        this.arrangeTransportBtn = document.getElementById('arrangeTransportBtn');
        this.confirmTransportSubmit = document.getElementById('confirmTransportSubmit');
        this.init();
    }
    init() {
        this.setupPatientSelector();
        this.setupLanguage();
        this.setupTabRouter();
        this.setupTransportModal();
        this.renderActivePatient();
    }
    // ==========================================
    // PATIENT PROFILE SWITCHER
    // ==========================================
    setupPatientSelector() {
        if (this.patientSelect) {
            this.patientSelect.addEventListener('change', () => {
                this.currentPatientId = this.patientSelect?.value || 'rahul';
                this.renderActivePatient();
            });
        }
    }
    renderActivePatient() {
        const patient = this.patients[this.currentPatientId];
        if (!patient)
            return;
        if (this.patientAvatarImg) {
            this.patientAvatarImg.src = patient.avatar;
        }
        const alertText = document.getElementById('transportAlertText');
        if (alertText) {
            alertText.textContent = patient.transportAlert;
        }
    }
    // ==========================================
    // MULTI-LANGUAGE SYSTEM
    // ==========================================
    setupLanguage() {
        if (this.langSelect) {
            this.langSelect.value = this.currentLang;
            this.langSelect.addEventListener('change', () => {
                if (this.langSelect) {
                    this.setLanguage(this.langSelect.value);
                }
            });
        }
        this.setLanguage(this.currentLang);
    }
    setLanguage(lang) {
        this.currentLang = lang;
        localStorage.setItem('ayusync_caregiver_lang', lang);
        if (lang === 'ar') {
            document.documentElement.setAttribute('dir', 'rtl');
        }
        else {
            document.documentElement.removeAttribute('dir');
        }
        const dict = caregiverTranslations[lang] || caregiverTranslations['en'];
        document.querySelectorAll('[data-i18n]').forEach(el => {
            const key = el.dataset.i18n;
            if (key && dict[key]) {
                el.textContent = dict[key];
            }
        });
    }
    // ==========================================
    // TAB ROUTER
    // ==========================================
    switchTab(tabId) {
        this.navTabs.forEach(tab => {
            if (tab.dataset.tab === tabId) {
                tab.classList.add('active');
            }
            else {
                tab.classList.remove('active');
            }
        });
        this.pageViews.forEach(view => {
            if (view.id === `view-${tabId}`) {
                view.classList.add('active');
            }
            else {
                view.classList.remove('active');
            }
        });
        const mainContent = document.querySelector('.main-content');
        if (mainContent)
            mainContent.scrollTop = 0;
    }
    setupTabRouter() {
        this.navTabs.forEach(tab => {
            tab.addEventListener('click', () => {
                const target = tab.dataset.tab;
                if (target)
                    this.switchTab(target);
            });
        });
    }
    // ==========================================
    // MODALS
    // ==========================================
    setupTransportModal() {
        if (this.arrangeTransportBtn) {
            this.arrangeTransportBtn.addEventListener('click', () => {
                if (this.transportModal)
                    this.transportModal.classList.add('open');
            });
        }
        if (this.confirmTransportSubmit) {
            this.confirmTransportSubmit.addEventListener('click', () => {
                if (this.transportModal)
                    this.transportModal.classList.remove('open');
                alert(`🚗 Transport confirmed for ${this.patients[this.currentPatientId].name} for tomorrow's 10:00 AM Blood Test! Driver details sent via SMS.`);
            });
        }
        document.querySelectorAll('.close-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                const modalId = btn.dataset.modal;
                if (modalId) {
                    const el = document.getElementById(modalId);
                    if (el)
                        el.classList.remove('open');
                }
            });
        });
    }
}
document.addEventListener('DOMContentLoaded', () => {
    new AyuSyncCaregiverApp();
});
