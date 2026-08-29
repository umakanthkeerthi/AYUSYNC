/* ==========================================================================
   AYUSYNC CAREGIVER INTERFACE - TYPESCRIPT CORE LOGIC (src/app.ts)
   ========================================================================== */

import { caregiverTranslations, CaregiverTranslationSet } from './i18n.js';

interface PatientProfile {
  id: string;
  name: string;
  avatar: string;
  status: 'Stable' | 'Observation' | 'Critical';
  lastUpdated: string;
  medicationStatus: string;
  bloodTestStatus: string;
  appointmentTime: string;
  transportAlert: string;
}

class AyuSyncCaregiverApp {
  private currentPatientId: string = 'rahul';
  private currentLang: string = localStorage.getItem('ayusync_caregiver_lang') || 'en';

  private patients: Record<string, PatientProfile> = {
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

  // DOM Elements
  private patientSelect: HTMLSelectElement | null;
  private langSelect: HTMLSelectElement | null;
  private patientAvatarImg: HTMLImageElement | null;
  private navTabs: NodeListOf<HTMLButtonElement>;
  private pageViews: NodeListOf<HTMLElement>;

  // Modals
  private transportModal: HTMLElement | null;
  private arrangeTransportBtn: HTMLElement | null;
  private confirmTransportSubmit: HTMLElement | null;

  constructor() {
    this.patientSelect = document.getElementById('patientSelect') as HTMLSelectElement;
    this.langSelect = document.getElementById('langSelect') as HTMLSelectElement;
    this.patientAvatarImg = document.getElementById('patientAvatarImg') as HTMLImageElement;
    this.navTabs = document.querySelectorAll('.nav-tab');
    this.pageViews = document.querySelectorAll('.page-view');

    this.transportModal = document.getElementById('transportModal');
    this.arrangeTransportBtn = document.getElementById('arrangeTransportBtn');
    this.confirmTransportSubmit = document.getElementById('confirmTransportSubmit');

    this.init();
  }

  private init(): void {
    this.setupPatientSelector();
    this.setupLanguage();
    this.setupTabRouter();
    this.setupTransportModal();
    this.renderActivePatient();
  }

  // ==========================================
  // PATIENT PROFILE SWITCHER
  // ==========================================
  private setupPatientSelector(): void {
    if (this.patientSelect) {
      this.patientSelect.addEventListener('change', () => {
        this.currentPatientId = this.patientSelect?.value || 'rahul';
        this.renderActivePatient();
      });
    }
  }

  private renderActivePatient(): void {
    const patient = this.patients[this.currentPatientId];
    if (!patient) return;

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
  private setupLanguage(): void {
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

  private setLanguage(lang: string): void {
    this.currentLang = lang;
    localStorage.setItem('ayusync_caregiver_lang', lang);

    if (lang === 'ar') {
      document.documentElement.setAttribute('dir', 'rtl');
    } else {
      document.documentElement.removeAttribute('dir');
    }

    const dict = caregiverTranslations[lang] || caregiverTranslations['en'];

    document.querySelectorAll<HTMLElement>('[data-i18n]').forEach(el => {
      const key = el.dataset.i18n as keyof CaregiverTranslationSet;
      if (key && dict[key]) {
        el.textContent = dict[key];
      }
    });
  }

  // ==========================================
  // TAB ROUTER
  // ==========================================
  private switchTab(tabId: string): void {
    this.navTabs.forEach(tab => {
      if (tab.dataset.tab === tabId) {
        tab.classList.add('active');
      } else {
        tab.classList.remove('active');
      }
    });

    this.pageViews.forEach(view => {
      if (view.id === `view-${tabId}`) {
        view.classList.add('active');
      } else {
        view.classList.remove('active');
      }
    });

    const mainContent = document.querySelector('.main-content');
    if (mainContent) mainContent.scrollTop = 0;
  }

  private setupTabRouter(): void {
    this.navTabs.forEach(tab => {
      tab.addEventListener('click', () => {
        const target = tab.dataset.tab;
        if (target) this.switchTab(target);
      });
    });
  }

  // ==========================================
  // MODALS
  // ==========================================
  private setupTransportModal(): void {
    if (this.arrangeTransportBtn) {
      this.arrangeTransportBtn.addEventListener('click', () => {
        if (this.transportModal) this.transportModal.classList.add('open');
      });
    }

    if (this.confirmTransportSubmit) {
      this.confirmTransportSubmit.addEventListener('click', () => {
        if (this.transportModal) this.transportModal.classList.remove('open');
        alert(`🚗 Transport confirmed for ${this.patients[this.currentPatientId].name} for tomorrow's 10:00 AM Blood Test! Driver details sent via SMS.`);
      });
    }

    document.querySelectorAll<HTMLButtonElement>('.close-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        const modalId = btn.dataset.modal;
        if (modalId) {
          const el = document.getElementById(modalId);
          if (el) el.classList.remove('open');
        }
      });
    });
  }
}

document.addEventListener('DOMContentLoaded', () => {
  new AyuSyncCaregiverApp();
});
