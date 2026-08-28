import requests
import json

def test_api(name, url, method="GET", headers=None, payload=None):
    print(f"\n--- Testing: {name} ---")
    print(f"{method} {url}")
    try:
        if method == "GET":
            response = requests.get(url, headers=headers, timeout=5)
        else:
            response = requests.post(url, headers=headers, json=payload, timeout=5)
            
        print(f"Status Code: {response.status_code}")
        if response.status_code == 200:
            print("✅ Success!")
            print("Response:", json.dumps(response.json(), indent=2)[:500] + "...")
        else:
            print("❌ Failed!")
            print("Error:", response.text[:500])
    except Exception as e:
        print(f"❌ Error connecting: {str(e)}")

print("🚀 Starting API Verification Script...")

# 1. Mock EHR API
test_api(
    name="Mock EHR API (List Patients)",
    url="http://13.60.9.54/api/patients/"
)

# 2. Vobiz Calling Agent API
test_api(
    name="Voice Calling Agent API",
    url="https://ayusync.toplabs.in/api/call",
    method="POST",
    headers={"Authorization": "Bearer ayusync_admin_123"},
    payload={
        "phone": "+919876543210",
        "name": "Ramesh Kumar",
        "call_reason": "test",
        "agent_instruction": "Say hello."
    }
)

# 3. Lab Reports: Sugar
test_api(
    name="Lab Predictor API (Sugar)",
    url="https://ayusync.labpred.toplabs.in/api/predict/sugar",
    method="POST",
    headers={"X-API-Key": "medipredict_live_7a3d9b4f2e1c8d5a6b7c8d9e0f1a2b3c"},
    payload={
        "age": 45, "bmi": 28.5, "glucose": 110.0, "HbA1c_level": 5.8,
        "cholesterol": 180.0, "triglycerides": 140.0, "hdl": 50.0, "ldl": 100.0
    }
)

# 4. Lab Reports: Thyroid
test_api(
    name="Lab Predictor API (Thyroid)",
    url="https://ayusync.labpred.toplabs.in/api/predict/thyroid",
    method="POST",
    headers={"X-API-Key": "medipredict_live_7a3d9b4f2e1c8d5a6b7c8d9e0f1a2b3c"},
    payload={
        "Age": 32, "TSH": 2.5, "T3": 1.2, "TT4": 105.0, "T4U": 1.1, "FTI": 100.0
    }
)

# 5. Vitals Predictor
test_api(
    name="Vitals Predictor API",
    url="https://ayusync.vitalsriskpred.toplabs.in/api/predict",
    method="POST",
    headers={"X-API-Key": "Ayusync-Secret-Key-1234"}, 
    payload={
        "respiratory_rate": 18.0,
        "oxygen_saturation": 96.0,
        "o2_scale": 1,
        "systolic_bp": 115.0,
        "heart_rate": 78.0,
        "temperature": 37.1,
        "consciousness": "A",
        "on_oxygen": 0
    }
)
