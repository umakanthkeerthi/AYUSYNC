# AyuSync Risk Predictor API Documentation

This document provides instructions on how to connect to and use the AyuSync Clinical Risk Predictor API for the post-discharge care application.

## Base URL
All API requests should be routed to your secure domain:
```
https://ayusync.vitalsriskpred.toplabs.in
```

## Authentication
The prediction endpoint is secured to prevent unauthorized access. You must include the API key in the headers of your HTTP request.

- **Header Name**: `X-API-Key`
- **Current Key**: `Ayusync-Secret-Key-1234`

---

## Endpoints

### 1. Health Check
Used to verify if the API server and Machine Learning models are online and loaded.

- **URL**: `/api/health`
- **Method**: `GET`
- **Authentication Required**: No

**Example Response:**
```json
{
  "status": "online",
  "model": "RandomForest_NEWS2_Risk_Classifier",
  "features": [
    "Respiratory_Rate",
    "Oxygen_Saturation",
    "O2_Scale",
    "Systolic_BP",
    "Heart_Rate",
    "Temperature",
    "Consciousness",
    "On_Oxygen"
  ]
}
```

### 2. Predict Clinical Risk
Evaluates patient vitals using the Random Forest ML model and returns a risk level, confidence probabilities, and an AI Clinical Reasoning assessment.

- **URL**: `/api/predict`
- **Method**: `POST`
- **Authentication Required**: Yes (`X-API-Key`)
- **Content-Type**: `application/json`

**Request Body Parameters:**
| Parameter | Type | Range / Allowed Values | Description |
|-----------|------|-------------------------|-------------|
| `respiratory_rate` | Float | 5 - 60 | Breaths per minute |
| `oxygen_saturation`| Float | 50 - 100 | SpO2 percentage |
| `o2_scale` | Integer | 1 or 2 | 1 = Standard, 2 = Hypercapnic/COPD scale |
| `systolic_bp` | Float | 50 - 250 | Systolic Blood Pressure in mmHg |
| `heart_rate` | Float | 30 - 220 | Heart rate in beats per minute |
| `temperature` | Float | 32.0 - 44.0 | Body temperature in Celsius |
| `consciousness` | String | A, V, P, U | AVPU Scale (Alert, Voice, Pain, Unresponsive) |
| `on_oxygen` | Integer | 0 or 1 | 0 = Room Air, 1 = On Supplemental Oxygen |

**Example Request Body:**
```json
{
  "respiratory_rate": 18.0,
  "oxygen_saturation": 96.0,
  "o2_scale": 1,
  "systolic_bp": 115.0,
  "heart_rate": 78.0,
  "temperature": 37.1,
  "consciousness": "A",
  "on_oxygen": 0
}
```

**Example Response:**
```json
{
  "status": "success",
  "risk_level": "Low",
  "predicted_index": 1,
  "probabilities": {
    "Normal": 15.5,
    "Low": 75.0,
    "Medium": 8.0,
    "High": 1.5
  },
  "agent_assessment": {
    "findings": [
      "All monitored vital signs within baseline ranges"
    ],
    "patient_guidance": "ℹ️ Mild Alert: Minor vital variation detected. Continue resting, stay well hydrated, and keep wearing your monitoring device.",
    "doctor_sbar_note": "SBAR ASSESSMENT: Low Risk (75.0% confidence). Patient is largely stable with slight deviation. Routine 4-6h remote monitoring recommended.",
    "badge_color": "#eab308"
  }
}
```

---

## Integration Examples (Post-Discharge App)

### Example 1: cURL (Terminal)
```bash
curl -X POST "https://ayusync.vitalsriskpred.toplabs.in/api/predict" \
     -H "Content-Type: application/json" \
     -H "X-API-Key: Ayusync-Secret-Key-1234" \
     -d '{
           "respiratory_rate": 26.0,
           "oxygen_saturation": 91.0,
           "o2_scale": 1,
           "systolic_bp": 95.0,
           "heart_rate": 110.0,
           "temperature": 38.5,
           "consciousness": "A",
           "on_oxygen": 0
         }'
```

### Example 2: Python (`requests` library)
```python
import requests

url = "https://ayusync.vitalsriskpred.toplabs.in/api/predict"
headers = {
    "X-API-Key": "Ayusync-Secret-Key-1234",
    "Content-Type": "application/json"
}

payload = {
    "respiratory_rate": 20.0,
    "oxygen_saturation": 95.0,
    "o2_scale": 1,
    "systolic_bp": 120.0,
    "heart_rate": 80.0,
    "temperature": 37.0,
    "consciousness": "A",
    "on_oxygen": 0
}

try:
    response = requests.post(url, json=payload, headers=headers)
    response.raise_for_status() # Check for HTTP errors
    
    data = response.json()
    print(f"Risk Level: {data['risk_level']}")
    print(f"Patient Advice: {data['agent_assessment']['patient_guidance']}")
    
except requests.exceptions.HTTPError as e:
    print(f"Auth Error or Server Error: {e}")
```

### Example 3: JavaScript / Frontend (Fetch API)
```javascript
async function predictRisk(patientVitals) {
    const url = "https://ayusync.vitalsriskpred.toplabs.in/api/predict";
    const apiKey = "Ayusync-Secret-Key-1234";

    try {
        const response = await fetch(url, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "X-API-Key": apiKey
            },
            body: JSON.stringify(patientVitals)
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();
        console.log("Prediction Result:", data);
        return data;

    } catch (error) {
        console.error("Error connecting to Risk Predictor API:", error);
    }
}

// Usage
predictRisk({
    respiratory_rate: 16.0,
    oxygen_saturation: 98.0,
    o2_scale: 1,
    systolic_bp: 125.0,
    heart_rate: 72.0,
    temperature: 36.6,
    consciousness: "A",
    on_oxygen: 0
});
```
