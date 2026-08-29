/* ==========================================================================
   AYUSYNC PATIENT INTERFACE - TYPESCRIPT CORE LOGIC (src/app.ts)
   ========================================================================== */
import { translations } from './i18n.js';
class AyuSyncApp {
    constructor() {
        this.state = {
            currentTab: 'home',
            isTask1Done: true,
            progressPercent: 85,
            isDarkMode: false,
            currentLang: localStorage.getItem('ayusync_lang') || 'en'
        };
        this.activeVoiceCommand = 'open reports';
        // ==========================================
        // ALWAYS-ON LIVE GPS LOCATION PERMISSION (FIRST-TIME SYSTEM PROMPT MATCHING IMAGE 2)
        // ==========================================
        this.watchPositionId = null;
        // 5-SECOND EMERGENCY COUNTDOWN SAFETY TIMER
        this.sosCountdownInterval = null;
        this.sosCountdownSeconds = 5;
        this.activeSosReason = '';
        this.navTabs = document.querySelectorAll('.nav-tab');
        this.pageViews = document.querySelectorAll('.page-view');
        this.quickCards = document.querySelectorAll('.quick-card');
        this.seeAllPlanBtn = document.getElementById('seeAllPlanBtn');
        this.checkBtn1 = document.getElementById('checkBtn1');
        this.homeProgressRing = document.getElementById('homeProgressRing');
        this.homeProgressPercent = document.getElementById('homeProgressPercent');
        this.userAvatarBtn = document.getElementById('userAvatarBtn');
        this.langSelectProfile = document.getElementById('langSelectProfile');
        this.notifModal = document.getElementById('notifModal');
        this.voiceModal = document.getElementById('voiceModal');
        this.testDetailsModal = document.getElementById('testDetailsModal');
        this.reportViewerModal = document.getElementById('reportViewerModal');
        this.timeLockModal = document.getElementById('timeLockModal');
        this.claimDetailsModal = document.getElementById('claimDetailsModal');
        this.aiFactorsModal = document.getElementById('aiFactorsModal');
        this.mobileNavDrawer = document.getElementById('mobileNavDrawer');
        this.chatWindow = document.getElementById('chatWindow');
        this.chatInput = document.getElementById('chatInput');
        this.sendMessageBtn = document.getElementById('sendMessageBtn');
        this.openAyuSyncVoiceBtn = document.getElementById('openAyuSyncVoiceBtn');
        this.voiceMicHeaderBtn = document.getElementById('voiceMicHeaderBtn');
        this.sendVoiceQueryBtn = document.getElementById('sendVoiceQueryBtn');
        this.speechRecognizedText = document.getElementById('speechRecognizedText');
        this.voiceStatusText = document.getElementById('voiceStatusText');
        this.init();
    }
    init() {
        this.setupLanguage();
        this.setupTabRouter();
        this.setupMedicationHoverEffect();
        this.setupPopableMedicationsController();
        this.setupTaskToggle();
        this.setupChatEngine();
        this.setupAlexaVoiceController();
        this.setupModals();
        this.setupExtraTriggers();
        this.setupLiveLocationTracker();
        this.setupEmergencyTriggers();
        this.updateProgressRing(this.state.progressPercent);
    }
    // ==========================================
    // MULTI-LANGUAGE SYSTEM (PROFILE ONLY)
    // ==========================================
    setupLanguage() {
        if (this.langSelectProfile) {
            this.langSelectProfile.value = this.state.currentLang;
            this.langSelectProfile.addEventListener('change', () => {
                if (this.langSelectProfile) {
                    this.setLanguage(this.langSelectProfile.value);
                }
            });
        }
        this.setLanguage(this.state.currentLang);
    }
    setLanguage(lang) {
        this.state.currentLang = lang;
        localStorage.setItem('ayusync_lang', lang);
        if (this.langSelectProfile)
            this.langSelectProfile.value = lang;
        if (lang === 'ar') {
            document.documentElement.setAttribute('dir', 'rtl');
        }
        else {
            document.documentElement.removeAttribute('dir');
        }
        const dict = translations[lang] || translations['en'];
        document.querySelectorAll('[data-i18n]').forEach(el => {
            const key = el.dataset.i18n;
            if (key && dict[key]) {
                el.textContent = dict[key];
            }
        });
    }
    // ==========================================
    // TAB ROUTING
    // ==========================================
    switchTab(tabId) {
        this.state.currentTab = tabId;
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
        // Close mobile navigation drawer if open
        if (this.mobileNavDrawer) {
            this.closeModal(this.mobileNavDrawer);
        }
    }
    setupTabRouter() {
        this.navTabs.forEach(tab => {
            tab.addEventListener('click', () => {
                const target = tab.dataset.tab;
                if (target)
                    this.switchTab(target);
            });
        });
        this.quickCards.forEach(card => {
            card.addEventListener('click', () => {
                const targetTab = card.dataset.targetTab;
                if (targetTab)
                    this.switchTab(targetTab);
            });
        });
        if (this.seeAllPlanBtn) {
            this.seeAllPlanBtn.addEventListener('click', () => this.switchTab('plan'));
        }
        if (this.userAvatarBtn) {
            this.userAvatarBtn.addEventListener('click', () => this.switchTab('profile'));
        }
        const taskTest = document.getElementById('task-test-1');
        const taskAppt = document.getElementById('task-appt-1');
        if (taskTest)
            taskTest.addEventListener('click', () => this.switchTab('tests'));
        if (taskAppt)
            taskAppt.addEventListener('click', () => this.switchTab('appointments'));
    }
    // ==========================================
    // DYNAMIC HOVER & TOUCH PAGE THEME
    // ==========================================
    setupMedicationHoverEffect() {
        const medsCard = document.querySelector('.quick-card.meds');
        const apptsCard = document.querySelector('.quick-card.appts');
        const testsCard = document.querySelector('.quick-card.tests');
        const testTask = document.getElementById('task-test-1');
        const apptTask = document.getElementById('task-appt-1');
        const appContainer = document.querySelector('.app-container');
        const mainContent = document.querySelector('.main-content');
        const activateMintTheme = (el) => {
            if (appContainer)
                appContainer.classList.add('mint-theme');
            if (mainContent)
                mainContent.classList.add('mint-theme');
            if (el)
                el.classList.add('active-theme-border');
        };
        const deactivateMintTheme = (el) => {
            if (appContainer)
                appContainer.classList.remove('mint-theme');
            if (mainContent)
                mainContent.classList.remove('mint-theme');
            if (el)
                el.classList.remove('active-theme-border');
        };
        [medsCard, apptsCard, testsCard, testTask, apptTask].forEach(el => {
            if (!el)
                return;
            el.addEventListener('mouseenter', () => activateMintTheme(el));
            el.addEventListener('mouseleave', () => deactivateMintTheme(el));
            el.addEventListener('touchstart', () => activateMintTheme(el), { passive: true });
            el.addEventListener('touchend', () => {
                setTimeout(() => deactivateMintTheme(el), 600);
            }, { passive: true });
        });
    }
    // ==========================================
    // TIME LOCK CENTER ALERT MODAL
    // ==========================================
    showTimeLockCenterAlert(medName, scheduledTimeDisplay, timeSymbol, timePeriodName, currentAppTimeStr) {
        const timeLockMedName = document.getElementById('timeLockMedName');
        const timeLockMedSchedule = document.getElementById('timeLockMedSchedule');
        const timeLockMessageContent = document.getElementById('timeLockMessageContent');
        const timeLockCurrentTime = document.getElementById('timeLockCurrentTime');
        if (timeLockMedName)
            timeLockMedName.textContent = `${medName} ${timeSymbol}`;
        if (timeLockMedSchedule)
            timeLockMedSchedule.textContent = `Scheduled for ${scheduledTimeDisplay} ${timeSymbol} (${timePeriodName})`;
        if (timeLockMessageContent) {
            timeLockMessageContent.textContent = `Current app time is ${currentAppTimeStr}. Still time is there — you cannot log this medicine early! Please wait until ${scheduledTimeDisplay} to record your dose.`;
        }
        if (timeLockCurrentTime)
            timeLockCurrentTime.textContent = currentAppTimeStr;
        if (this.timeLockModal)
            this.openModal(this.timeLockModal);
    }
    // ==========================================
    // POPDOWN ACCORDION & TIME LOGGING CONTROLLER
    // ==========================================
    setupPopableMedicationsController() {
        const accordion = document.getElementById('todayMedsAccordion');
        const toggleBtn = document.getElementById('todayMedsToggleBtn');
        const todayMedsArrowBtn = document.getElementById('todayMedsArrowBtn');
        const timeAlert = document.getElementById('medsTimeAlert');
        const closeAlertBtn = document.getElementById('closeMedsAlertBtn');
        const alertTitle = document.getElementById('alertTitle');
        const alertMsg = document.getElementById('medsTimeAlertMsg');
        const alertIcon = document.getElementById('alertIcon');
        const simulatedTimeText = document.getElementById('simulatedTimeText');
        const toggleTimeBtn = document.getElementById('toggleSimulatedTimeBtn');
        const logMetoprololBtn = document.getElementById('logMetoprololBtn');
        const metoprololCard = document.getElementById('metoprololCard');
        const metoprololStatusText = document.getElementById('metoprololStatusText');
        const medicineCardArrowBtn = document.getElementById('medicineCardArrowBtn');
        let isMetoprololLogged = false;
        let currentAppHour = 8;
        let currentAppMin = 30;
        const toggleAccordionPanel = () => {
            if (accordion && toggleBtn) {
                const isOpen = accordion.classList.toggle('open');
                toggleBtn.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
            }
        };
        if (toggleBtn) {
            toggleBtn.addEventListener('click', toggleAccordionPanel);
            toggleBtn.addEventListener('keydown', (e) => {
                if (e.key === 'Enter' || e.key === ' ') {
                    e.preventDefault();
                    toggleAccordionPanel();
                }
            });
        }
        const homeAccordion = document.getElementById('homeMedsAccordion');
        const homeTimeAlert = document.getElementById('homeMedsTimeAlert');
        const closeHomeAlertBtn = document.getElementById('closeHomeAlertBtn');
        const homeAlertTitle = document.getElementById('homeAlertTitle');
        const homeAlertMsg = document.getElementById('homeMedsTimeAlertMsg');
        const homeAlertIcon = document.getElementById('homeAlertIcon');
        const taskMedsItem = document.getElementById('task-meds-1');
        const toggleHomeAccordion = () => {
            if (homeAccordion) {
                const isOpen = homeAccordion.classList.toggle('open');
                if (medicineCardArrowBtn)
                    medicineCardArrowBtn.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
                if (taskMedsItem) {
                    if (isOpen)
                        taskMedsItem.classList.add('open-arrow');
                    else
                        taskMedsItem.classList.remove('open-arrow');
                }
            }
        };
        if (medicineCardArrowBtn) {
            medicineCardArrowBtn.addEventListener('click', (e) => {
                e.stopPropagation();
                toggleHomeAccordion();
            });
        }
        if (taskMedsItem) {
            taskMedsItem.addEventListener('click', (e) => {
                if (e.target.closest('#checkBtn1'))
                    return;
                toggleHomeAccordion();
            });
        }
        if (closeHomeAlertBtn && homeTimeAlert) {
            closeHomeAlertBtn.addEventListener('click', () => {
                homeTimeAlert.style.display = 'none';
            });
        }
        const bindCompactMedToggle = (btnId, timeInputId, statusId, rowId, scheduledHour, medName, scheduledTimeDisplay, timeSymbol = '🌅', timePeriodName = 'Morning') => {
            const btn = document.getElementById(btnId);
            const input = document.getElementById(timeInputId);
            const statusEl = document.getElementById(statusId);
            const row = document.getElementById(rowId);
            if (!btn || !input || !statusEl || !row)
                return;
            btn.addEventListener('click', (e) => {
                e.stopPropagation();
                const isLogged = btn.classList.contains('on');
                if (isLogged) {
                    btn.classList.remove('on');
                    btn.setAttribute('aria-checked', 'false');
                    statusEl.innerHTML = `Due ${scheduledTimeDisplay}`;
                    statusEl.className = 'compact-status-tag';
                    if (homeTimeAlert)
                        homeTimeAlert.style.display = 'none';
                    return;
                }
                let recHour = scheduledHour;
                let recMin = 0;
                let formattedTimeStr = scheduledTimeDisplay;
                if (input && input.value) {
                    const parts = input.value.split(':');
                    recHour = parseInt(parts[0], 10);
                    recMin = parseInt(parts[1], 10);
                    const period = recHour >= 12 ? 'PM' : 'AM';
                    const displayHour = recHour % 12 === 0 ? 12 : recHour % 12;
                    const displayMin = recMin < 10 ? `0${recMin}` : `${recMin}`;
                    formattedTimeStr = `${displayHour}:${displayMin} ${period}`;
                }
                const appTimePeriod = currentAppHour >= 12 ? 'PM' : 'AM';
                const appDisplayHour = currentAppHour % 12 === 0 ? 12 : currentAppHour % 12;
                const appDisplayMin = currentAppMin < 10 ? `0${currentAppMin}` : `${currentAppMin}`;
                const currentAppTimeStr = `${appDisplayHour}:${appDisplayMin} ${appTimePeriod}`;
                if (currentAppHour < scheduledHour || recHour < scheduledHour) {
                    row.classList.remove('shake-error');
                    void row.offsetWidth;
                    row.classList.add('shake-error');
                    btn.classList.remove('on');
                    btn.setAttribute('aria-checked', 'false');
                    if (homeTimeAlert && homeAlertTitle && homeAlertMsg && homeAlertIcon) {
                        homeTimeAlert.className = 'time-alert-banner';
                        homeAlertIcon.textContent = '⏰';
                        homeAlertTitle.textContent = 'Still Time Is There! (Not Time Yet)';
                        homeAlertMsg.textContent = `${medName} is scheduled for ${scheduledTimeDisplay} (${timeSymbol} ${timePeriodName}). Current app time is ${currentAppTimeStr}. Still time is there — please take your tablet when it is due!`;
                        homeTimeAlert.style.display = 'flex';
                    }
                    this.showTimeLockCenterAlert(medName, scheduledTimeDisplay, timeSymbol, timePeriodName, currentAppTimeStr);
                    this.showToast(`⏰ Still time is there! ${medName} is scheduled for ${scheduledTimeDisplay}`);
                }
                else {
                    row.classList.remove('shake-error');
                    btn.classList.add('on');
                    btn.setAttribute('aria-checked', 'true');
                    statusEl.innerHTML = `✓ Taken at ${formattedTimeStr}`;
                    statusEl.className = 'compact-status-tag badge-green';
                    if (homeTimeAlert && homeAlertTitle && homeAlertMsg && homeAlertIcon) {
                        homeTimeAlert.className = 'time-alert-banner success';
                        homeAlertIcon.textContent = '✅';
                        homeAlertTitle.textContent = 'Dose & Time Recorded!';
                        homeAlertMsg.textContent = `${medName} recorded at ${formattedTimeStr}.`;
                        homeTimeAlert.style.display = 'flex';
                    }
                    this.showToast(`✅ ${medName} dose recorded successfully!`);
                }
            });
            row.addEventListener('click', (e) => {
                if (e.target.closest('button') || e.target.closest('input'))
                    return;
                btn.click();
            });
        };
        bindCompactMedToggle('tickBtnEcosprin', 'timeInputEcosprin', 'statusEcosprin', 'homeEcosprinRow', 8, 'Ecosprin 75mg', '8:00 AM', '🌅', 'Sunrise (Morning)');
        bindCompactMedToggle('tickBtnAtorvastatin', 'timeInputAtorvastatin', 'statusAtorvastatin', 'homeAtorvastatinRow', 8, 'Atorvastatin 10mg', '8:00 AM', '🌅', 'Sunrise (Morning)');
        bindCompactMedToggle('tickBtnParacetamol', 'timeInputParacetamol', 'statusParacetamol', 'homeParacetamolRow', 12, 'Paracetamol 500mg', '12:00 PM', '☀️', 'Full Sun (Afternoon)');
        bindCompactMedToggle('logHomeMetoprololBtn', 'recordTimeInput', 'homeMetoprololStatusText', 'homeMetoprololCard', 21, 'Metoprolol 25mg', '9:00 PM', '🌙', 'Moon (Night)');
        if (todayMedsArrowBtn) {
            todayMedsArrowBtn.addEventListener('click', (e) => {
                e.stopPropagation();
                toggleAccordionPanel();
            });
        }
        if (closeAlertBtn && timeAlert) {
            closeAlertBtn.addEventListener('click', () => {
                timeAlert.style.display = 'none';
            });
        }
        if (toggleTimeBtn && simulatedTimeText) {
            toggleTimeBtn.addEventListener('click', () => {
                if (currentAppHour === 8) {
                    currentAppHour = 12;
                    currentAppMin = 30;
                    simulatedTimeText.textContent = '12:30 PM (Afternoon ☀️)';
                    toggleTimeBtn.textContent = 'Switch to 9:15 PM (Night 🌙)';
                    this.showToast('🕒 App Time set to 12:30 PM (Afternoon ☀️)');
                }
                else if (currentAppHour === 12) {
                    currentAppHour = 21;
                    currentAppMin = 15;
                    simulatedTimeText.textContent = '9:15 PM (Night 🌙)';
                    toggleTimeBtn.textContent = 'Switch back to 8:30 AM (Morning 🌅)';
                    this.showToast('🕒 App Time set to 9:15 PM (Night 🌙)');
                }
                else {
                    currentAppHour = 8;
                    currentAppMin = 30;
                    simulatedTimeText.textContent = '8:30 AM (Morning 🌅)';
                    toggleTimeBtn.textContent = 'Switch to 12:30 PM (Afternoon ☀️)';
                    this.showToast('🕒 App Time set to 8:30 AM (Morning 🌅)');
                }
            });
        }
        const logParacetamolBtn = document.getElementById('logParacetamolBtn');
        const paracetamolCard = document.getElementById('paracetamolCard');
        const paracetamolStatusText = document.getElementById('paracetamolStatusText');
        if (logParacetamolBtn && paracetamolCard) {
            logParacetamolBtn.addEventListener('click', (e) => {
                e.stopPropagation();
                const scheduledHour = 12;
                if (currentAppHour < scheduledHour) {
                    paracetamolCard.classList.remove('shake-error');
                    void paracetamolCard.offsetWidth;
                    paracetamolCard.classList.add('shake-error');
                    if (timeAlert && alertTitle && alertMsg && alertIcon) {
                        timeAlert.className = 'time-alert-banner';
                        alertIcon.textContent = '⏰';
                        alertTitle.textContent = 'Still Time Is There! (Not Time Yet)';
                        alertMsg.textContent = `Paracetamol 500mg is scheduled for 12:00 PM (☀️ Full Sun • Afternoon). Current app time is ${currentAppHour}:${currentAppMin} AM. Still time is there — please wait until 12:00 PM to take this tablet.`;
                        timeAlert.style.display = 'flex';
                    }
                    this.showTimeLockCenterAlert('Paracetamol 500mg', '12:00 PM', '☀️', 'Afternoon', `${currentAppHour}:${currentAppMin < 10 ? '0' : ''}${currentAppMin} AM`);
                    this.showToast('⏰ Still time is there! Paracetamol 500mg is scheduled for 12:00 PM');
                }
                else {
                    paracetamolCard.classList.remove('shake-error');
                    paracetamolCard.classList.remove('pending');
                    paracetamolCard.classList.add('completed');
                    if (paracetamolStatusText) {
                        paracetamolStatusText.innerHTML = '<span class="badge badge-green">✓ Taken at 12:30 PM</span>';
                    }
                    logParacetamolBtn.style.display = 'none';
                    this.showToast('✅ Paracetamol 500mg dose recorded!');
                }
            });
        }
        if (logMetoprololBtn && metoprololCard) {
            logMetoprololBtn.addEventListener('click', (e) => {
                e.stopPropagation();
                if (isMetoprololLogged)
                    return;
                const scheduledHour = 21;
                if (currentAppHour < scheduledHour) {
                    metoprololCard.classList.remove('shake-error');
                    void metoprololCard.offsetWidth;
                    metoprololCard.classList.add('shake-error');
                    if (timeAlert && alertTitle && alertMsg && alertIcon) {
                        timeAlert.className = 'time-alert-banner';
                        alertIcon.textContent = '⏰';
                        alertTitle.textContent = 'Still Time Is There! (Not Time Yet)';
                        alertMsg.textContent = `Metoprolol 25mg is scheduled for 9:00 PM (🌙 Moon • Night). Current app time is ${currentAppHour}:${currentAppMin === 0 ? '00' : currentAppMin} ${currentAppHour >= 12 ? 'PM' : 'AM'}. Still time is there — please wait until 9:00 PM to take this tablet.`;
                        timeAlert.style.display = 'flex';
                    }
                    this.showTimeLockCenterAlert('Metoprolol 25mg', '9:00 PM', '🌙', 'Night', `${currentAppHour % 12 || 12}:${currentAppMin < 10 ? '0' : ''}${currentAppMin} AM`);
                    this.showToast('⏰ Still time is there! Metoprolol 25mg is scheduled for 9:00 PM');
                }
                else {
                    isMetoprololLogged = true;
                    metoprololCard.classList.remove('shake-error');
                    metoprololCard.classList.remove('pending');
                    metoprololCard.classList.add('completed');
                    if (metoprololStatusText) {
                        metoprololStatusText.innerHTML = '<span class="badge badge-green">✓ Taken at 9:15 PM</span>';
                    }
                    logMetoprololBtn.style.display = 'none';
                    this.showToast('✅ Metoprolol 25mg dose recorded successfully!');
                }
            });
        }
    }
    // ==========================================
    // TODAY'S TASK 1 TOGGLE CONTROLLER
    // ==========================================
    setupTaskToggle() {
        if (this.checkBtn1) {
            this.checkBtn1.addEventListener('click', (e) => {
                e.stopPropagation();
                this.state.isTask1Done = !this.state.isTask1Done;
                if (this.state.isTask1Done) {
                    this.checkBtn1?.classList.add('checked');
                    this.state.progressPercent = 100;
                    this.showToast('✅ All morning medications completed!');
                }
                else {
                    this.checkBtn1?.classList.remove('checked');
                    this.state.progressPercent = 85;
                    this.showToast('↩️ Task marked as incomplete');
                }
                this.updateProgressRing(this.state.progressPercent);
            });
        }
    }
    updateProgressRing(percent) {
        if (this.homeProgressPercent) {
            this.homeProgressPercent.innerHTML = `${percent}<span>%</span>`;
        }
        if (this.homeProgressRing) {
            const radius = 35;
            const circumference = 2 * Math.PI * radius;
            const offset = circumference - (percent / 100) * circumference;
            this.homeProgressRing.style.strokeDasharray = `${circumference} ${circumference}`;
            this.homeProgressRing.style.strokeDashoffset = `${offset}`;
        }
    }
    // ==========================================
    // CHAT & VOICE ENGINE
    // ==========================================
    appendChatMessage(text, sender) {
        if (!this.chatWindow)
            return;
        const bubble = document.createElement('div');
        bubble.className = `msg-bubble ${sender === 'user' ? 'msg-user' : 'msg-ai'}`;
        bubble.textContent = text;
        this.chatWindow.appendChild(bubble);
        this.chatWindow.scrollTop = this.chatWindow.scrollHeight;
    }
    handleAiQuery(queryText) {
        this.appendChatMessage(queryText, 'user');
        setTimeout(() => {
            let response = "I've checked your health profile and recovery protocol. ";
            const q = queryText.toLowerCase();
            if (q.includes('heart rate')) {
                response += "Your latest logged heart rate is 72 bpm, which is perfectly within normal resting parameters after your cardiac procedure.";
            }
            else if (q.includes('pill') || q.includes('medicine')) {
                response += "Your next scheduled dose is Metoprolol (25mg) at 9:00 PM tonight after dinner.";
            }
            else if (q.includes('coffee') || q.includes('drink')) {
                response += "Dr. Mehta advises avoiding caffeine before your 10:00 AM CBC Blood test today. You can have light water.";
            }
            else {
                response += "Your recovery status is currently at 85%. Remember to attend your Cardiology Appointment with Dr. Mehta at 4:00 PM today!";
            }
            this.appendChatMessage(response, 'ai');
        }, 650);
    }
    setupChatEngine() {
        if (this.sendMessageBtn && this.chatInput) {
            this.sendMessageBtn.addEventListener('click', () => {
                const text = this.chatInput?.value.trim();
                if (text) {
                    this.handleAiQuery(text);
                    if (this.chatInput)
                        this.chatInput.value = '';
                }
            });
            this.chatInput.addEventListener('keydown', (e) => {
                if (e.key === 'Enter') {
                    const text = this.chatInput?.value.trim();
                    if (text) {
                        this.handleAiQuery(text);
                        if (this.chatInput)
                            this.chatInput.value = '';
                    }
                }
            });
        }
        const openAiBotChatBtn = document.getElementById('openAiBotChatBtn');
        if (openAiBotChatBtn) {
            openAiBotChatBtn.addEventListener('click', () => {
                this.switchTab('chat');
            });
        }
        document.querySelectorAll('.prompt-chip').forEach(chip => {
            chip.addEventListener('click', () => {
                this.handleAiQuery(chip.textContent || '');
            });
        });
    }
    // ==========================================
    // ALEXA VOICE CONTROLLER
    // ==========================================
    setupAlexaVoiceController() {
        // Single tap on mic symbol does NOT open voice modal.
        document.querySelectorAll('.voice-cmd-chip').forEach(chip => {
            chip.addEventListener('click', () => {
                const cmd = chip.dataset.cmd || 'open reports';
                this.activeVoiceCommand = cmd;
                if (this.speechRecognizedText)
                    this.speechRecognizedText.textContent = `"${cmd}"`;
            });
        });
        if (this.sendVoiceQueryBtn) {
            this.sendVoiceQueryBtn.addEventListener('click', () => {
                const cmd = this.activeVoiceCommand.toLowerCase();
                this.closeModal(this.voiceModal);
                if (cmd.includes('report'))
                    this.switchTab('reports');
                else if (cmd.includes('plan'))
                    this.switchTab('plan');
                else if (cmd.includes('med'))
                    this.switchTab('medications');
                else if (cmd.includes('appt') || cmd.includes('appointment'))
                    this.switchTab('appointments');
                else if (cmd.includes('profile'))
                    this.switchTab('profile');
                else if (cmd.includes('test'))
                    this.switchTab('tests');
                else
                    this.switchTab('home');
                this.showToast(`🎙️ Voice Command executed: "${this.activeVoiceCommand}"`);
            });
        }
    }
    // ==========================================
    // MODALS & NOTIFICATIONS CONTROLLER
    // ==========================================
    openModal(modalEl) {
        if (modalEl) {
            modalEl.style.display = 'flex';
            modalEl.classList.add('open', 'active');
        }
    }
    closeModal(modalEl) {
        if (modalEl) {
            modalEl.style.display = 'none';
            modalEl.classList.remove('open', 'active');
        }
    }
    setupModals() {
        document.querySelectorAll('.close-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                const modalId = btn.dataset.modal;
                if (modalId) {
                    this.closeModal(document.getElementById(modalId));
                }
            });
        });
        document.querySelectorAll('.modal-overlay').forEach(overlay => {
            overlay.addEventListener('click', (e) => {
                if (e.target === overlay) {
                    this.closeModal(overlay);
                }
            });
        });
        const openDrawerBtn = document.getElementById('openDrawerBtn');
        if (openDrawerBtn) {
            openDrawerBtn.addEventListener('click', () => {
                this.openModal(this.mobileNavDrawer);
            });
        }
        const returnTimeLockHeaderBtn = document.getElementById('returnTimeLockHeaderBtn');
        const returnTimeLockFooterBtn = document.getElementById('returnTimeLockFooterBtn');
        if (returnTimeLockHeaderBtn) {
            returnTimeLockHeaderBtn.addEventListener('click', () => this.closeModal(this.timeLockModal));
        }
        if (returnTimeLockFooterBtn) {
            returnTimeLockFooterBtn.addEventListener('click', () => this.closeModal(this.timeLockModal));
        }
        this.setupNotificationCenter();
    }
    setupNotificationCenter() {
        const notifBadgeDot = document.getElementById('notifBadgeDot') || document.querySelector('.notification-badge');
        const returnNotifHeaderBtn = document.getElementById('returnNotifHeaderBtn');
        const returnNotifFooterBtn = document.getElementById('returnNotifFooterBtn');
        const markAllReadBtn = document.getElementById('markAllReadBtn');
        const notifItems = document.querySelectorAll('.notif-card-item');
        const openNotifBtn = document.getElementById('openNotifBtn');
        let unreadCount = 3;
        const clearOrangeBadge = () => {
            unreadCount = 0;
            if (notifBadgeDot) {
                notifBadgeDot.classList.add('hidden');
            }
            notifItems.forEach(item => {
                item.classList.remove('unread');
                const tag = item.querySelector('.notif-status-badge');
                if (tag) {
                    tag.textContent = 'Read';
                    tag.className = 'notif-status-badge read-dot';
                }
            });
        };
        if (openNotifBtn) {
            openNotifBtn.addEventListener('click', () => {
                this.openModal(this.notifModal);
                clearOrangeBadge();
            });
        }
        notifItems.forEach(item => {
            item.addEventListener('click', () => {
                if (item.classList.contains('unread')) {
                    item.classList.remove('unread');
                    const tag = item.querySelector('.notif-status-badge');
                    if (tag) {
                        tag.textContent = 'Read';
                        tag.className = 'notif-status-badge read-dot';
                    }
                    unreadCount = Math.max(0, unreadCount - 1);
                    if (unreadCount === 0 && notifBadgeDot) {
                        notifBadgeDot.classList.add('hidden');
                    }
                }
            });
        });
        if (markAllReadBtn) {
            markAllReadBtn.addEventListener('click', () => {
                clearOrangeBadge();
                this.showToast('✓ All notifications marked as read');
            });
        }
        if (returnNotifHeaderBtn) {
            returnNotifHeaderBtn.addEventListener('click', () => {
                clearOrangeBadge();
                this.closeModal(this.notifModal);
            });
        }
        if (returnNotifFooterBtn) {
            returnNotifFooterBtn.addEventListener('click', () => {
                clearOrangeBadge();
                this.closeModal(this.notifModal);
            });
        }
    }
    setupExtraTriggers() {
        const reportItem1 = document.getElementById('reportItem1');
        if (reportItem1) {
            reportItem1.addEventListener('click', () => this.openModal(this.reportViewerModal));
        }
        const reportItem2 = document.getElementById('reportItem2');
        if (reportItem2) {
            reportItem2.addEventListener('click', () => {
                const title = document.getElementById('reportModalTitle');
                if (title)
                    title.textContent = "12-Lead ECG Resting Scan";
                this.openModal(this.reportViewerModal);
            });
        }
        const emergencySosBtn = document.getElementById('emergencySosBtn');
        if (emergencySosBtn) {
            emergencySosBtn.addEventListener('click', () => {
                alert("🚨 Emergency SOS Activated!\n\nAlerting your designated emergency contact and City Heart Institute Duty Desk with your GPS location & Patient ID #AYU-98421.");
            });
        }
        // Health Insurance Event Handlers
        const whyRecFactorsBtn = document.getElementById('whyRecFactorsBtn');
        const closeAiFactorsBtn = document.getElementById('closeAiFactorsBtn');
        if (whyRecFactorsBtn) {
            whyRecFactorsBtn.addEventListener('click', () => this.openModal(this.aiFactorsModal));
        }
        if (closeAiFactorsBtn) {
            closeAiFactorsBtn.addEventListener('click', () => this.closeModal(this.aiFactorsModal));
        }
        const closeClaimModalBtn = document.getElementById('closeClaimModalBtn');
        if (closeClaimModalBtn) {
            closeClaimModalBtn.addEventListener('click', () => this.closeModal(this.claimDetailsModal));
        }
        document.querySelectorAll('.track-claim-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                const claimId = btn.dataset.claim || 'CLM-90812';
                const title = document.getElementById('claimModalTitle');
                if (title)
                    title.textContent = `Claim #${claimId} Live Tracking`;
                this.openModal(this.claimDetailsModal);
            });
        });
        const viewPolicyDocBtn = document.getElementById('viewPolicyDocBtn');
        if (viewPolicyDocBtn) {
            viewPolicyDocBtn.addEventListener('click', () => this.showToast('📄 Downloading Star Health Policy Document...'));
        }
        const viewCoverageDetailsBtn = document.getElementById('viewCoverageDetailsBtn');
        if (viewCoverageDetailsBtn) {
            viewCoverageDetailsBtn.addEventListener('click', () => this.showToast('🔍 Coverage Details: ₹7.8L Available out of ₹10L Sum Insured'));
        }
        const renewPolicyBtn = document.getElementById('renewPolicyBtn');
        if (renewPolicyBtn) {
            renewPolicyBtn.addEventListener('click', () => this.showToast('🔄 Policy renewal portal opened for 12 March 2027'));
        }
        const upgradePlanBtn = document.getElementById('upgradePlanBtn');
        if (upgradePlanBtn) {
            upgradePlanBtn.addEventListener('click', () => this.showToast('✨ Initiating Upgrade to HDFC ERGO Optima Secure (₹25L Coverage)...'));
        }
        document.querySelectorAll('.compare-plan-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                const plan = btn.dataset.plan || 'Plan';
                this.showToast(`📊 Added ${plan} to Side-by-Side Comparison Matrix below`);
            });
        });
        document.querySelectorAll('.view-plan-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                const plan = btn.dataset.plan || 'Plan';
                this.showToast(`📋 Opening Official Brochure for ${plan}...`);
            });
        });
        const confirmTestCheckinBtn = document.getElementById('confirmTestCheckinBtn');
        if (confirmTestCheckinBtn) {
            confirmTestCheckinBtn.addEventListener('click', () => {
                this.closeModal(this.testDetailsModal);
                this.showToast('🎫 Digital Pass Verified! Show QR Code at City Lab Desk.');
            });
        }
        const downloadPdfBtn = document.getElementById('downloadPdfBtn');
        if (downloadPdfBtn) {
            downloadPdfBtn.addEventListener('click', () => {
                this.showToast('📥 Downloading Verified Digital Report PDF...');
            });
        }
    }
    setupLiveLocationTracker() {
        const openLocationBtn = document.getElementById('openLocationPermissionBtn');
        const locationBadgeDot = document.getElementById('locationBadgeDot');
        const locationModal = document.getElementById('locationPermissionModal');
        const statusModal = document.getElementById('liveLocationStatusModal');
        const allowAllBtn = document.getElementById('permAllowAllBtn');
        const allowInUseBtn = document.getElementById('permAllowInUseBtn');
        const denyBtn = document.getElementById('permDenyBtn');
        const patientLiveAddressText = document.getElementById('patientLiveAddressText');
        const patientLiveCoords = document.getElementById('patientLiveCoords');
        const patientLiveTimestamp = document.getElementById('patientLiveTimestamp');
        const refreshPatientGpsBtn = document.getElementById('refreshPatientGpsBtn');
        const changeLocationSettingsBtn = document.getElementById('changeLocationSettingsBtn');
        if (!locationModal)
            return;
        const savedPerm = localStorage.getItem('ayusync_location_permission');
        const isPrompted = localStorage.getItem('ayusync_location_prompted') === 'true';
        let currentLat = 24.6180;
        let currentLng = 73.9915;
        const updateLiveLocationUI = (lat, lng, placeName) => {
            currentLat = lat;
            currentLng = lng;
            const formattedCoords = `${lat.toFixed(4)}° N, ${lng.toFixed(4)}° E`;
            const timeNow = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' });
            if (patientLiveAddressText)
                patientLiveAddressText.textContent = placeName || `Current Location Fix: ${formattedCoords}`;
            if (patientLiveCoords)
                patientLiveCoords.textContent = formattedCoords;
            if (patientLiveTimestamp)
                patientLiveTimestamp.textContent = `${timeNow} (Live Sync)`;
        };
        const mapContainer = document.getElementById('liveLocationMapContainer');
        if (mapContainer) {
            mapContainer.addEventListener('click', () => {
                const googleMapsUrl = `https://www.google.com/maps?q=${currentLat},${currentLng}`;
                window.open(googleMapsUrl, '_blank');
                this.showToast('🗺️ Opening patient live position in Google Maps...');
            });
        }
        const fetchAccurateLocation = () => {
            if ('geolocation' in navigator) {
                navigator.geolocation.getCurrentPosition(async (pos) => {
                    const lat = pos.coords.latitude;
                    const lng = pos.coords.longitude;
                    const formattedCoords = `${lat.toFixed(4)}° N, ${lng.toFixed(4)}° E`;
                    try {
                        const res = await fetch(`https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lng}`);
                        const data = await res.json();
                        const fullAddr = data.display_name || data.address?.suburb || data.address?.city || `GPS Fix (${formattedCoords})`;
                        updateLiveLocationUI(lat, lng, fullAddr);
                    }
                    catch {
                        updateLiveLocationUI(lat, lng, `Current GPS Fix (${formattedCoords})`);
                    }
                }, (err) => {
                    console.warn('Geolocation accuracy fallback:', err);
                    updateLiveLocationUI(24.6180, 73.9915, 'Current GPS Location (24.6180° N, 73.9915° E)');
                }, { enableHighAccuracy: true, timeout: 8000, maximumAge: 0 });
            }
        };
        const startTracking = (mode) => {
            localStorage.setItem('ayusync_location_permission', mode);
            if (locationBadgeDot)
                locationBadgeDot.classList.remove('hidden');
            fetchAccurateLocation();
            if ('geolocation' in navigator) {
                if (this.watchPositionId !== null)
                    navigator.geolocation.clearWatch(this.watchPositionId);
                this.watchPositionId = navigator.geolocation.watchPosition((pos) => {
                    const lat = pos.coords.latitude;
                    const lng = pos.coords.longitude;
                    updateLiveLocationUI(lat, lng, `Live GPS Position (${lat.toFixed(4)}°, ${lng.toFixed(4)}°)`);
                }, (err) => {
                    console.warn('Geolocation fallback telemetry active:', err);
                }, { enableHighAccuracy: true, maximumAge: 3000, timeout: 10000 });
            }
        };
        const stopTracking = () => {
            localStorage.setItem('ayusync_location_permission', 'denied');
            if (locationBadgeDot)
                locationBadgeDot.classList.add('hidden');
            if (this.watchPositionId !== null && 'geolocation' in navigator) {
                navigator.geolocation.clearWatch(this.watchPositionId);
                this.watchPositionId = null;
            }
        };
        // If previously granted, activate tracking & show green dot badge on top header 📍 pin icon
        if (savedPerm === 'allowed_all' || savedPerm === 'allowed_in_use') {
            startTracking(savedPerm);
        }
        // CLICKING TOP HEADER LOCATION PIN SYMBOL (📍):
        // - If allowed before: Shows patient's accurate live location fix!
        // - If denied / not allowed: Asks permission modal (matching photo)
        if (openLocationBtn) {
            openLocationBtn.addEventListener('click', () => {
                const currentPerm = localStorage.getItem('ayusync_location_permission');
                if (currentPerm === 'allowed_all' || currentPerm === 'allowed_in_use') {
                    fetchAccurateLocation();
                    this.openModal(statusModal);
                }
                else {
                    this.openModal(locationModal);
                }
            });
        }
        if (allowAllBtn) {
            allowAllBtn.addEventListener('click', () => {
                startTracking('allowed_all');
                this.closeModal(locationModal);
                this.showToast('📍 Location Permission Granted! Always-on location enabled.');
            });
        }
        if (allowInUseBtn) {
            allowInUseBtn.addEventListener('click', () => {
                startTracking('allowed_in_use');
                this.closeModal(locationModal);
                this.showToast('📍 Location Permission Granted while app is in use.');
            });
        }
        if (denyBtn) {
            denyBtn.addEventListener('click', () => {
                stopTracking();
                this.closeModal(locationModal);
                this.showToast('⚪ Location Access Denied');
            });
        }
        if (refreshPatientGpsBtn) {
            refreshPatientGpsBtn.addEventListener('click', () => {
                fetchAccurateLocation();
                this.showToast('📡 Patient Accurate Live Location Synchronized!');
            });
        }
        if (changeLocationSettingsBtn) {
            changeLocationSettingsBtn.addEventListener('click', () => {
                this.closeModal(statusModal);
                this.openModal(locationModal);
            });
        }
        const returnLocationHeaderBtn = document.getElementById('returnLocationHeaderBtn');
        if (returnLocationHeaderBtn && statusModal) {
            returnLocationHeaderBtn.addEventListener('click', () => this.closeModal(statusModal));
        }
    }
    // ==========================================
    // REAL-TIME EMERGENCY AMBULANCE DISPATCH CONTROLLER
    // (Long Press Screen OR 3x Rapid Mic Click Trigger)
    // ==========================================
    setupEmergencyTriggers() {
        let longPressTimer = null;
        let isPressing = false;
        const startLongPress = (e) => {
            // Ignore if clicking interactive buttons or form controls directly
            const target = e.target;
            if (target.closest('button, input, select, a, textarea'))
                return;
            isPressing = true;
            longPressTimer = setTimeout(() => {
                if (isPressing) {
                    isPressing = false;
                    this.start5SecondSosCountdown('Screen Long Press Emergency Signal');
                }
            }, 950);
        };
        const cancelLongPress = () => {
            isPressing = false;
            if (longPressTimer) {
                clearTimeout(longPressTimer);
                longPressTimer = null;
            }
        };
        const viewHome = document.getElementById('view-home');
        if (viewHome) {
            viewHome.addEventListener('touchstart', startLongPress);
            viewHome.addEventListener('touchend', cancelLongPress);
            viewHome.addEventListener('touchmove', cancelLongPress);
            viewHome.addEventListener('mousedown', startLongPress);
            viewHome.addEventListener('mouseup', cancelLongPress);
            viewHome.addEventListener('mouseleave', cancelLongPress);
        }
        // 3 OR MORE RAPID MIC SYMBOL CLICKS TRIGGER
        let micClickCounter = 0;
        let micResetTimer = null;
        const handleMicClick = (e) => {
            // Prevent duplicate requests if already active
            if (localStorage.getItem('ayusync_emergency_sos')) {
                const payloadStr = localStorage.getItem('ayusync_emergency_sos');
                if (payloadStr) {
                    try {
                        const payload = JSON.parse(payloadStr);
                        if (payload && payload.active) {
                            const sosModal = document.getElementById('emergencySosModal');
                            if (sosModal)
                                this.openModal(sosModal);
                            return;
                        }
                    }
                    catch (e) { }
                }
            }
            micClickCounter++;
            if (micResetTimer)
                clearTimeout(micResetTimer);
            const pageMicBtn = document.getElementById('voiceMicBtnMain');
            if (pageMicBtn) {
                pageMicBtn.classList.remove('mic-tap-1', 'mic-tap-2');
                void pageMicBtn.offsetWidth; // force reflow
                if (micClickCounter === 1)
                    pageMicBtn.classList.add('mic-tap-1');
                else if (micClickCounter === 2)
                    pageMicBtn.classList.add('mic-tap-2');
            }
            micResetTimer = setTimeout(() => {
                micClickCounter = 0;
                if (pageMicBtn)
                    pageMicBtn.classList.remove('mic-tap-1', 'mic-tap-2');
            }, 1500);
            if (micClickCounter >= 3) {
                micClickCounter = 0;
                e.preventDefault();
                e.stopPropagation();
                if (pageMicBtn) {
                    pageMicBtn.classList.remove('mic-tap-1', 'mic-tap-2');
                    pageMicBtn.classList.add('mic-emergency-active');
                }
                this.triggerEmergencySos('3x Rapid Mic Voice Emergency Signal');
            }
        };
        // ONLY BIND TO THE PAGE MIC SYMBOL (voiceMicBtnMain inside Talk to AyuSync card)
        const pageMicBtn = document.getElementById('voiceMicBtnMain');
        if (pageMicBtn)
            pageMicBtn.addEventListener('click', handleMicClick);
        // BIND NEW DEDICATED EMERGENCY SOS BUTTON
        const homeSosBtn = document.getElementById('emergencySosHomeBtn');
        if (homeSosBtn) {
            homeSosBtn.addEventListener('click', (e) => {
                e.preventDefault();
                e.stopPropagation();
                // Prevent duplicate requests if already active
                if (localStorage.getItem('ayusync_emergency_sos')) {
                    const payloadStr = localStorage.getItem('ayusync_emergency_sos');
                    if (payloadStr) {
                        try {
                            const payload = JSON.parse(payloadStr);
                            if (payload && payload.active) {
                                const sosModal = document.getElementById('emergencySosModal');
                                if (sosModal)
                                    this.openModal(sosModal);
                                return;
                            }
                        }
                        catch (err) { }
                    }
                }
                this.start5SecondSosCountdown('Manual SOS Button Trigger');
            });
        }
        const cancelSosBtn = document.getElementById('cancelSosCountdownBtn');
        if (cancelSosBtn) {
            cancelSosBtn.addEventListener('click', () => {
                this.cancelSosCountdown();
            });
        }
        const forceSendSosBtn = document.getElementById('forceSendSosNowBtn');
        if (forceSendSosBtn) {
            forceSendSosBtn.addEventListener('click', () => {
                if (this.sosCountdownInterval) {
                    clearInterval(this.sosCountdownInterval);
                    this.sosCountdownInterval = null;
                }
                const countdownModal = document.getElementById('sosCountdownModal');
                if (countdownModal)
                    this.closeModal(countdownModal);
                this.triggerEmergencySos(this.activeSosReason || 'Direct Emergency SOS Trigger');
            });
        }
        const closeSosBtn = document.getElementById('closeEmergencySosBtn');
        const emergencySosModal = document.getElementById('emergencySosModal');
        if (closeSosBtn && emergencySosModal) {
            closeSosBtn.addEventListener('click', () => this.closeModal(emergencySosModal));
        }
    }
    start5SecondSosCountdown(reasonText) {
        // 1. Force switch to Homepage view
        this.switchTab('home');
        // 2. Force close and hide any location status or permission modals
        const locModal = document.getElementById('liveLocationStatusModal');
        const permModal = document.getElementById('locationPermissionModal');
        if (locModal) {
            this.closeModal(locModal);
            locModal.style.display = 'none';
        }
        if (permModal) {
            this.closeModal(permModal);
            permModal.style.display = 'none';
        }
        this.activeSosReason = reasonText;
        this.sosCountdownSeconds = 5;
        const countdownModal = document.getElementById('sosCountdownModal');
        const secondsNum = document.getElementById('sosCountdownSecondsNumber');
        const secondsText = document.getElementById('sosTimerCountdownText');
        const subReason = document.getElementById('sosCountdownSubReason');
        const countdownCircle = document.getElementById('sosCountdownCircle');
        if (subReason)
            subReason.textContent = `${reasonText} • Tap Cancel within 5 seconds if this was an accidental tap.`;
        if (secondsNum)
            secondsNum.textContent = '5';
        if (secondsText)
            secondsText.textContent = '5';
        if (countdownCircle) {
            countdownCircle.style.strokeDashoffset = '0';
        }
        if (countdownModal)
            this.openModal(countdownModal);
        if (this.sosCountdownInterval)
            clearInterval(this.sosCountdownInterval);
        this.sosCountdownInterval = setInterval(() => {
            this.sosCountdownSeconds--;
            if (secondsNum)
                secondsNum.textContent = `${this.sosCountdownSeconds}`;
            if (secondsText)
                secondsText.textContent = `${this.sosCountdownSeconds}`;
            if (countdownCircle) {
                const circumference = 264;
                const offset = circumference - (this.sosCountdownSeconds / 5) * circumference;
                countdownCircle.style.strokeDashoffset = `${offset}`;
            }
            if (this.sosCountdownSeconds <= 0) {
                clearInterval(this.sosCountdownInterval);
                this.sosCountdownInterval = null;
                if (countdownModal)
                    this.closeModal(countdownModal);
                // 8 seconds expired without clicking cancel -> DISPATCH LOCATION TO DRIVER!
                this.triggerEmergencySos(this.activeSosReason);
            }
        }, 1000);
    }
    cancelSosCountdown() {
        if (this.sosCountdownInterval) {
            clearInterval(this.sosCountdownInterval);
            this.sosCountdownInterval = null;
        }
        const countdownModal = document.getElementById('sosCountdownModal');
        if (countdownModal)
            this.closeModal(countdownModal);
        this.showToast('⚪ Emergency Request Cancelled (False Alarm Saved)');
    }
    triggerEmergencySos(reasonText) {
        // 1. Force switch to Homepage view
        this.switchTab('home');
        // 2. Force close all background modals so Emergency SOS shows strictly over Homepage
        const countdownModal = document.getElementById('sosCountdownModal');
        const locModal = document.getElementById('liveLocationStatusModal');
        const permModal = document.getElementById('locationPermissionModal');
        if (countdownModal) {
            this.closeModal(countdownModal);
            countdownModal.style.display = 'none';
        }
        if (locModal) {
            this.closeModal(locModal);
            locModal.style.display = 'none';
        }
        if (permModal) {
            this.closeModal(permModal);
            permModal.style.display = 'none';
        }
        const sosModal = document.getElementById('emergencySosModal');
        const sosReason = document.getElementById('sosTriggerReasonText');
        const sosAddress = document.getElementById('sosPatientAddressText');
        if (sosReason)
            sosReason.textContent = `${reasonText} • Transmitting live location fix to CareOS Ambulance Driver.`;
        const broadcastSosPayload = (addr, lat, lng) => {
            if (sosAddress)
                sosAddress.textContent = addr;
            const payload = {
                patientId: '10482',
                patientName: 'Rahul Kumar',
                status: 'CRITICAL',
                pickupAddress: addr,
                lat: lat,
                lng: lng,
                timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' }),
                reason: reasonText,
                active: true,
                timeKey: Date.now()
            };
            localStorage.setItem('ayusync_emergency_sos', JSON.stringify(payload));
            try {
                const channel = new BroadcastChannel('ayusync_sos_channel');
                channel.postMessage(payload);
            }
            catch (e) { }
        };
        // 1. Instantly dispatch with best available static/generic location to guarantee speed
        broadcastSosPayload('Detecting your location...', 24.6180, 73.9915);
        if (sosModal)
            this.openModal(sosModal);
        this.showToast('🚨 AMBULANCE DISPATCHED! Obtaining exact GPS fix...');
        // 2. Fetch exact GPS in the background and update
        if ('geolocation' in navigator) {
            navigator.geolocation.getCurrentPosition(async (pos) => {
                const lat = pos.coords.latitude;
                const lng = pos.coords.longitude;
                const formattedCoords = `${lat.toFixed(4)}° N, ${lng.toFixed(4)}° E`;
                try {
                    const res = await fetch(`https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lng}`);
                    const data = await res.json();
                    const fullAddr = data.display_name || data.address?.suburb || data.address?.city || `GPS Fix (${formattedCoords})`;
                    broadcastSosPayload(fullAddr, lat, lng);
                }
                catch {
                    broadcastSosPayload(`GPS Fix (${formattedCoords})`, lat, lng);
                }
            }, () => {
                broadcastSosPayload('Patient Live Location (24.6180° N, 73.9915° E)', 24.6180, 73.9915);
            }, { enableHighAccuracy: true, timeout: 6000 });
        }
        else {
            broadcastSosPayload('Patient Live Location (24.6180° N, 73.9915° E)', 24.6180, 73.9915);
        }
    }
    // ==========================================
    // TOAST NOTIFICATIONS
    // ==========================================
    showToast(msg) {
        const existing = document.querySelector('.ayu-toast');
        if (existing)
            existing.remove();
        const toast = document.createElement('div');
        toast.className = 'ayu-toast';
        toast.textContent = msg;
        Object.assign(toast.style, {
            position: 'fixed',
            bottom: '80px',
            left: '50%',
            transform: 'translateX(-50%) translateY(20px)',
            background: 'rgba(15, 23, 42, 0.9)',
            color: '#FFFFFF',
            padding: '12px 20px',
            borderRadius: '14px',
            fontSize: '0.82rem',
            fontWeight: '600',
            boxShadow: '0 10px 30px rgba(0, 0, 0, 0.25)',
            zIndex: '1000',
            opacity: '0',
            transition: 'all 0.3s cubic-bezier(0.16, 1, 0.3, 1)',
            pointerEvents: 'none',
            textAlign: 'center',
            maxWidth: '90vw'
        });
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
    new AyuSyncApp();
});
