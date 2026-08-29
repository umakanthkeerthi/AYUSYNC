/* ==========================================================================
   CAREOS AMBULANCE DRIVER DASHBOARD - TYPESCRIPT LOGIC (src/app.ts)
   ========================================================================== */

class CareOSDriverApp {
  private currentTab: string = 'trip';
  private isArrived: boolean = false;
  private isSirenOn: boolean = true;

  // DOM Elements
  private navTabs: NodeListOf<HTMLButtonElement>;
  private pageViews: NodeListOf<HTMLElement>;
  private openDrawerBtn: HTMLElement | null;
  private closeDrawerBtn: HTMLElement | null;
  private drawerOverlay: HTMLElement | null;
  private emergencyCallBtn: HTMLElement | null;
  private drawerEmergencyBtn: HTMLElement | null;
  private callModal: HTMLElement | null;
  private cancelCallBtn: HTMLElement | null;
  private closeCallModalBtn: HTMLElement | null;

  private navigateBtn: HTMLElement | null;
  private navModal: HTMLElement | null;
  private closeNavModalBtn: HTMLElement | null;
  private closeNavModalBtn2: HTMLElement | null;
  private markArrivedBtn: HTMLElement | null;
  private recenterMapBtn: HTMLElement | null;
  private toggleSirenBtn: HTMLElement | null;

  // Live Vital Value Elements
  private valHR: HTMLElement | null;
  private valSpO2: HTMLElement | null;
  private valResp: HTMLElement | null;
  private valTemp: HTMLElement | null;
  private ambulanceSprite: HTMLElement | null;

  constructor() {
    this.navTabs = document.querySelectorAll('.nav-tab');
    this.pageViews = document.querySelectorAll('.page-view');
    this.openDrawerBtn = document.getElementById('openDrawerBtn');
    this.closeDrawerBtn = document.getElementById('closeDrawerBtn');
    this.drawerOverlay = document.getElementById('drawerOverlay');

    this.emergencyCallBtn = document.getElementById('emergencyCallBtn');
    this.drawerEmergencyBtn = document.getElementById('drawerEmergencyBtn');
    this.callModal = document.getElementById('callModal');
    this.cancelCallBtn = document.getElementById('cancelCallBtn');
    this.closeCallModalBtn = document.getElementById('closeCallModalBtn');

    this.navigateBtn = document.getElementById('navigateBtn');
    this.navModal = document.getElementById('navModal');
    this.closeNavModalBtn = document.getElementById('closeNavModalBtn');
    this.closeNavModalBtn2 = document.getElementById('closeNavModalBtn2');

    this.markArrivedBtn = document.getElementById('markArrivedBtn');
    this.recenterMapBtn = document.getElementById('recenterMapBtn');
    this.toggleSirenBtn = document.getElementById('toggleSirenBtn');

    this.valHR = document.getElementById('valHR');
    this.valSpO2 = document.getElementById('valSpO2');
    this.valResp = document.getElementById('valResp');
    this.valTemp = document.getElementById('valTemp');
    this.ambulanceSprite = document.getElementById('ambulanceSprite');

    this.init();
  }

  private init(): void {
    this.setupTabRouting();
    this.setupDrawer();
    this.setupModals();
    this.setupActionButtons();
    this.startLiveTelemetrySimulation();
    this.startAmbulanceMapAnimation();
    this.setupSosDispatchListener();
  }

  // TAB ROUTING
  private switchTab(tabId: string): void {
    this.currentTab = tabId;

    this.navTabs.forEach(tab => {
      if (tab.dataset.tab === tabId) tab.classList.add('active');
      else tab.classList.remove('active');
    });

    this.pageViews.forEach(view => {
      if (view.id === `view-${tabId}`) {
        view.style.display = 'block';
      } else {
        view.style.display = 'none';
      }
    });

    if (this.drawerOverlay) this.closeModal(this.drawerOverlay);
  }

  private setupTabRouting(): void {
    this.navTabs.forEach(tab => {
      tab.addEventListener('click', () => {
        const target = tab.dataset.tab;
        if (target) this.switchTab(target);
      });
    });
  }

  // DRAWER MENU (☰)
  private setupDrawer(): void {
    if (this.openDrawerBtn && this.drawerOverlay) {
      this.openDrawerBtn.addEventListener('click', () => {
        this.drawerOverlay?.classList.add('open', 'drawer-open');
      });
    }

    if (this.closeDrawerBtn && this.drawerOverlay) {
      this.closeDrawerBtn.addEventListener('click', () => {
        this.closeModal(this.drawerOverlay);
      });
    }

    if (this.drawerOverlay) {
      this.drawerOverlay.addEventListener('click', (e) => {
        if (e.target === this.drawerOverlay) {
          this.closeModal(this.drawerOverlay);
        }
      });
    }
  }

  // MODALS & ACTIONS
  private openModal(modalEl: HTMLElement | null): void {
    if (modalEl) modalEl.classList.add('open');
  }

  private closeModal(modalEl: HTMLElement | null): void {
    if (modalEl) modalEl.classList.remove('open', 'drawer-open');
  }

  private setupModals(): void {
    // Call Modal
    const triggerCall = () => this.openModal(this.callModal);
    if (this.emergencyCallBtn) this.emergencyCallBtn.addEventListener('click', triggerCall);
    if (this.drawerEmergencyBtn) this.drawerEmergencyBtn.addEventListener('click', triggerCall);

    if (this.cancelCallBtn) this.cancelCallBtn.addEventListener('click', () => this.closeModal(this.callModal));
    if (this.closeCallModalBtn) this.closeCallModalBtn.addEventListener('click', () => this.closeModal(this.callModal));

    // Nav Modal
    if (this.navigateBtn) {
      this.navigateBtn.addEventListener('click', () => {
        this.openModal(this.navModal);
        this.showToast('🧭 Turn-by-Turn GPS Navigation Activated!');
      });
    }

    if (this.closeNavModalBtn) this.closeNavModalBtn.addEventListener('click', () => this.closeModal(this.navModal));
    if (this.closeNavModalBtn2) this.closeNavModalBtn2.addEventListener('click', () => this.closeModal(this.navModal));
  }

  private setupActionButtons(): void {
    // Mark as Arrived Toggle
    if (this.markArrivedBtn) {
      this.markArrivedBtn.addEventListener('click', () => {
        this.isArrived = !this.isArrived;
        if (this.isArrived) {
          this.markArrivedBtn?.classList.add('completed');
          if (this.markArrivedBtn) this.markArrivedBtn.textContent = '✓ Arrived at Apollo Hospital (Handover Complete)';
          this.showToast('✅ Ambulance Arrived at ER Gate! Handover protocol initiated.');
        } else {
          this.markArrivedBtn?.classList.remove('completed');
          if (this.markArrivedBtn) this.markArrivedBtn.textContent = 'Mark as Arrived';
          this.showToast('↩️ Status updated back to Active Transport');
        }
      });
    }

    // Re-center Map Button
    if (this.recenterMapBtn) {
      this.recenterMapBtn.addEventListener('click', () => {
        if (this.ambulanceSprite) {
          this.ambulanceSprite.style.transform = 'scale(1.2)';
          setTimeout(() => {
            if (this.ambulanceSprite) this.ambulanceSprite.style.transform = 'scale(1)';
          }, 300);
        }
        this.showToast('🎯 Map GPS centered on Ambulance Position');
      });
    }

    // Siren Toggle Button
    if (this.toggleSirenBtn) {
      this.toggleSirenBtn.addEventListener('click', () => {
        this.isSirenOn = !this.isSirenOn;
        if (this.toggleSirenBtn) {
          this.toggleSirenBtn.textContent = this.isSirenOn ? 'ON' : 'OFF';
          this.toggleSirenBtn.style.background = this.isSirenOn ? '#DC2626' : '#374151';
        }
        this.showToast(this.isSirenOn ? '🚨 High-Pitch Siren ACTIVATED' : '🔇 Siren SILENCED');
      });
    }
  }

  // LIVE TELEMETRY SIMULATION
  private startLiveTelemetrySimulation(): void {
    setInterval(() => {
      if (this.valHR) {
        const randomHR = 91 + Math.floor(Math.random() * 4);
        this.valHR.textContent = `${randomHR}`;
      }
      if (this.valSpO2) {
        const randomSpO2 = 96 + Math.floor(Math.random() * 2);
        this.valSpO2.textContent = `${randomSpO2}%`;
      }
      if (this.valResp) {
        const randomResp = 19 + Math.floor(Math.random() * 3);
        this.valResp.textContent = `${randomResp}`;
      }
    }, 3500);
  }

  // AMBULANCE MAP MOVEMENT ANIMATION
  private startAmbulanceMapAnimation(): void {
    let step = 0;
    const positions = [
      { left: '130px', top: '100px' },
      { left: '170px', top: '70px' },
      { left: '220px', top: '55px' },
      { left: '270px', top: '50px' }
    ];

    setInterval(() => {
      if (this.ambulanceSprite) {
        step = (step + 1) % positions.length;
        this.ambulanceSprite.style.left = positions[step].left;
        this.ambulanceSprite.style.top = positions[step].top;
      }
    }, 4500);
  }

  // REAL-TIME PATIENT EMERGENCY SOS LISTENER
  private currentSosLat = 24.6180;
  private currentSosLng = 73.9915;

  private setupSosDispatchListener(): void {
    const driverSosModal = document.getElementById('driverSosModal');
    const driverPatientName = document.getElementById('driverSosPatientName');
    const driverPickupAddress = document.getElementById('driverSosPickupAddress');
    const driverTimestamp = document.getElementById('driverSosTimestamp');
    const driverTriggerSource = document.getElementById('driverSosTriggerSource');

    const closeDriverSosBtn = document.getElementById('closeDriverSosBtn');
    const dismissSosBtn = document.getElementById('dismissSosBtn');
    const acceptSosNavigateBtn = document.getElementById('acceptSosNavigateBtn');

    const handleSosDispatch = (payload: any) => {
      if (!payload || !payload.active) return;
      if (payload.lat) this.currentSosLat = payload.lat;
      if (payload.lng) this.currentSosLng = payload.lng;

      if (driverPatientName) driverPatientName.textContent = `${payload.patientName} (ID #${payload.patientId})`;
      if (driverPickupAddress) driverPickupAddress.textContent = payload.pickupAddress || `GPS Fix (${payload.lat}, ${payload.lng})`;
      if (driverTimestamp) driverTimestamp.textContent = payload.timestamp || 'Just now';
      if (driverTriggerSource) driverTriggerSource.textContent = `Triggered via ${payload.reason || 'Patient Emergency SOS Signal'}`;

      if (driverSosModal) {
        driverSosModal.style.display = 'flex';
        driverSosModal.classList.add('active');
      }

      this.showToast(`🚨 CRITICAL SOS RECEIVED: ${payload.patientName} requested Ambulance!`);
    };

    if (closeDriverSosBtn && driverSosModal) {
      closeDriverSosBtn.addEventListener('click', () => {
        driverSosModal.style.display = 'none';
        driverSosModal.classList.remove('active');
      });
    }

    if (dismissSosBtn && driverSosModal) {
      dismissSosBtn.addEventListener('click', () => {
        driverSosModal.style.display = 'none';
        driverSosModal.classList.remove('active');
      });
    }

    if (acceptSosNavigateBtn) {
      acceptSosNavigateBtn.addEventListener('click', () => {
        if (driverSosModal) {
          driverSosModal.style.display = 'none';
          driverSosModal.classList.remove('active');
        }
        const googleMapsUrl = `https://www.google.com/maps?q=${this.currentSosLat},${this.currentSosLng}`;
        window.open(googleMapsUrl, '_blank');
        if (this.navModal) {
          this.navModal.style.display = 'flex';
          this.navModal.classList.add('active');
        }
        this.showToast('🧭 Navigation Active: Directing Driver to Patient Live Location!');
      });
    }

    window.addEventListener('storage', (e) => {
      if (e.key === 'ayusync_emergency_sos' && e.newValue) {
        try {
          const payload = JSON.parse(e.newValue);
          handleSosDispatch(payload);
        } catch (err) {}
      }
    });

    try {
      const channel = new BroadcastChannel('ayusync_sos_channel');
      channel.onmessage = (ev) => {
        handleSosDispatch(ev.data);
      };
    } catch (e) {}

    // Check on startup if SOS was triggered
    const existingSos = localStorage.getItem('ayusync_emergency_sos');
    if (existingSos) {
      try {
        const payload = JSON.parse(existingSos);
        if (payload && payload.active) {
          handleSosDispatch(payload);
        }
      } catch(err) {}
    }
  }

  // TOAST NOTIFICATIONS
  private showToast(msg: string): void {
    const existing = document.querySelector('.careos-toast');
    if (existing) existing.remove();

    const toast = document.createElement('div');
    toast.className = 'careos-toast';
    toast.textContent = msg;

    document.body.appendChild(toast);

    requestAnimationFrame(() => {
      toast.style.opacity = '1';
      toast.style.transform = 'translateX(-50%) translateY(0)';
    });

    setTimeout(() => {
      toast.style.opacity = '0';
      toast.style.transform = 'translateX(-50%) translateY(20px)';
      setTimeout(() => toast.remove(), 300);
    }, 2800);
  }
}

document.addEventListener('DOMContentLoaded', () => {
  new CareOSDriverApp();
});
