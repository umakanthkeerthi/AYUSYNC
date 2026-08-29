# Caregiver Agent Collaboration Rules

**ATTENTION FELLOW ANTIGRAVITY AGENT:** 
You have been summoned to build the **Caregiver Interface** for the AyuSync platform. To ensure zero Git merge conflicts with the team building the Patient Interface, you MUST strictly adhere to the following architecture rules.

## 1. Directory Isolation (CRITICAL)
- The Patient Interface team is working exclusively inside the `frontend/patient_app/` directory. 
- **DO NOT** modify, edit, or delete any files inside `frontend/patient_app/`.
- You must build the Caregiver Interface entirely within a separate directory: **`frontend/caregiver_app/`**.

## 2. Initialization
If the `frontend/caregiver_app/` directory does not exist yet, your first step must be to initialize the Flutter project by running:
```bash
C:\tools\flutter\bin\flutter create caregiver_app
```
(Run this from inside the `frontend/` directory).

## 3. Design Aesthetics
The Patient Interface was built with a highly premium, glassmorphism aesthetic using the AyuSync brand colors (`#F87E25` orange gradient theme). You should aim to match this premium, fluid, micro-animated design quality in the Caregiver Interface.
- Feel free to reference the UI mockups in `team frontend/caregiver ui/` for the *features* needed.
- Do not copy their raw HTML design; upgrade it to premium Flutter code.

## 4. Git Workflow
When you are ready to commit your code:
1. Ensure you are only staging files inside `frontend/caregiver_app/`.
2. Do not accidentally stage changes from the patient app.
3. Use a clear commit message indicating Caregiver UI progress.

*Good luck building the Caregiver app! By staying in your designated directory, we guarantee a conflict-free collaboration!*
