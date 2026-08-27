# Risk Prediction Agent

## Core Functionality
Evaluates the clinical deterioration risk of a patient. It generates a numerical risk score (0-100) and a perfectly grounded, hallucination-free explanation of why that score was generated, so a human doctor can trust the alert.

## How It Works
1. **Data Gathering**: Triggered by the Monitoring Agent, it pulls the patient's full history, current vitals, and latest lab reports.
2. **Scoring**: It runs this data through a trained Machine Learning model to calculate the `RiskScore`.
3. **Mathematical Explanation (The Loophole Fix)**: To prevent LLM hallucinations, it extracts "Feature Importance Scores" (SHAP values) from the ML model. These mathematical values (e.g., +30 points due to high blood pressure) are injected into a strict text template. The human doctor reads this mathematically grounded explanation, ensuring 100% accuracy.

## Architecture
* **Machine Learning**: XGBoost or Scikit-learn model, deployed on Amazon SageMaker.
* **Logic Handler**: A Python microservice that queries SageMaker, extracts SHAP values, renders the deterministic explanation template, and publishes the payload back to Amazon EventBridge.
