# MediPredict REST API Documentation

Welcome to the detailed documentation for the MediPredict Lab Report Prediction API. This API allows the Post-Discharge Care Solution to submit clinical and laboratory parameters and receive Machine Learning-driven abnormality risk scores.

## Authentication

All endpoints require API Key authentication to prevent unauthorized usage. 
You must include your secret key in the HTTP Headers using the `X-API-Key` field.

> [!IMPORTANT]  
> **Base URL:** `https://ayusync.labpred.toplabs.in/api/predict`
> **Header:** `X-API-Key: medipredict_live_7a3d9b4f2e1c8d5a6b7c8d9e0f1a2b3c`

---

## 1. Sugar & Metabolic Prediction (`/sugar`)

**URL**: `POST /sugar`

Predicts the risk of abnormal blood sugar levels and metabolic issues based on lifestyle and clinical factors.

### Request Body Schema (JSON)
| Field | Type | Description | Required | Default |
|-------|------|-------------|----------|---------|
| `age` | Float | Age in years | **Yes** | - |
| `bmi` | Float | Body Mass Index (kg/m²) | **Yes** | - |
| `glucose` | Float | Fasting / random glucose (mg/dL) | **Yes** | - |
| `HbA1c_level` | Float | HbA1c level (%) | **Yes** | - |
| `cholesterol` | Float | Total cholesterol (mg/dL) | **Yes** | - |
| `triglycerides` | Float | Triglycerides (mg/dL) | **Yes** | - |
| `hdl` | Float | HDL Cholesterol (mg/dL) | **Yes** | - |
| `ldl` | Float | LDL Cholesterol (mg/dL) | **Yes** | - |
| `hypertension` | Integer | Hypertension flag (0=No, 1=Yes) | No | `0` |
| `heart_disease` | Integer | Heart disease flag (0=No, 1=Yes) | No | `0` |
| `sleep_hours` | Float | Average sleep hours | No | `7.0` |
| `crp_level` | Float | C-Reactive Protein level (mg/L) | No | `1.5` |
| `systolic_bp` | Float | Systolic Blood Pressure (mmHg) | No | `120.0` |
| `diastolic_bp` | Float | Diastolic Blood Pressure (mmHg) | No | `80.0` |
| `gender` | String | Gender (`Female` or `Male`) | No | `"Female"` |
| `smoking` | String | Smoking status (`Never`, `Former`, `Current`) | No | `"Never"` |
| `physical_activity` | String | Physical activity (`Low`, `Moderate`, `High`) | No | `"Moderate"` |
| `family_history` | String | Family history of diabetes (`Yes` or `No`) | No | `"No"` |
| `stress_level` | String | Stress level (`Low`, `Medium`, `High`) | No | `"Low"` |

### Example cURL
```bash
curl -X POST "https://ayusync.labpred.toplabs.in/api/predict/sugar" \
     -H "Content-Type: application/json" \
     -H "X-API-Key: medipredict_live_7a3d9b4f2e1c8d5a6b7c8d9e0f1a2b3c" \
     -d '{
           "age": 45, "bmi": 28.5, "glucose": 110.0, "HbA1c_level": 5.8,
           "cholesterol": 180.0, "triglycerides": 140.0, "hdl": 50.0, "ldl": 100.0
         }'
```

---

## 2. Thyroid Prediction (`/thyroid`)

**URL**: `POST /thyroid`

Analyzes thyroid hormone levels to predict hypothyroidism or hyperthyroidism risk.

### Request Body Schema (JSON)
| Field | Type | Description | Required | Default |
|-------|------|-------------|----------|---------|
| `Age` | Float | Age in years | **Yes** | - |
| `TSH` | Float | Thyroid Stimulating Hormone (µIU/mL) | **Yes** | - |
| `T3` | Float | Triiodothyronine T3 (ng/mL) | **Yes** | - |
| `TT4` | Float | Total T4 (µg/dL) | **Yes** | - |
| `T4U` | Float | T4 Uptake ratio | **Yes** | - |
| `FTI` | Float | Free Thyroxine Index | **Yes** | - |
| `Sex` | String | Sex (`Female`, `Male`) | No | `"Female"` |
| `On_thyroxine` | Integer | On thyroxine therapy (0 or 1) | No | `0` |
| `Sick` | Integer | Sick flag (0 or 1) | No | `0` |
| `Pregnant` | Integer | Pregnant flag (0 or 1) | No | `0` |
| `Thyroid_surgery` | Integer | History of thyroid surgery (0 or 1) | No | `0` |
| `Tumor` | Integer | Thyroid tumor present (0 or 1) | No | `0` |

### Example cURL
```bash
curl -X POST "https://ayusync.labpred.toplabs.in/api/predict/thyroid" \
     -H "Content-Type: application/json" \
     -H "X-API-Key: medipredict_live_7a3d9b4f2e1c8d5a6b7c8d9e0f1a2b3c" \
     -d '{
           "Age": 32, "TSH": 2.5, "T3": 1.2, "TT4": 105.0, "T4U": 1.1, "FTI": 100.0
         }'
```

---

## 3. CBC (Complete Blood Count) Prediction (`/cbc`)

**URL**: `POST /cbc`

Evaluates hematological parameters (red blood cells, hemoglobin, indices) to detect anomalies.

### Request Body Schema (JSON)
| Field | Type | Description | Required | Default |
|-------|------|-------------|----------|---------|
| `trbc` | Float | Total Red Blood Cell count (x10^6 /µL) | **Yes** | - |
| `hb_g_dl` | Float | Hemoglobin (g/dL) | **Yes** | - |
| `pcv_pct` | Float | Packed Cell Volume (%) | **Yes** | - |
| `mcv_fl` | Float | Mean Corpuscular Volume (fL) | **Yes** | - |
| `mch_pg` | Float | Mean Corpuscular Hemoglobin (pg) | **Yes** | - |
| `mchc_g_dl` | Float | Mean Corpuscular Hb Concentration (g/dL)| **Yes** | - |
| `rdw_pct` | Float | Red Cell Distribution Width (%) | No | `13.0` |
| `total_bilirubin`| Float | Total Bilirubin (mg/dL) | No | `0.7` |
| `creatinine` | Float | Serum Creatinine (mg/dL) | No | `0.8` |
| `dietary_habits` | String | `Vegetarian` or `Non-Vegetarian` | No | `"Non-Vegetarian"`|

---

## 4. Urinalysis Prediction (`/urinalysis`)

**URL**: `POST /urinalysis`

Assesses urine composition metrics for renal or systemic issues.

### Request Body Schema (JSON)
| Field | Type | Description | Required | Default |
|-------|------|-------------|----------|---------|
| `specific_gravity`| Float | Specific Gravity (1.002 - 1.035) | No | `1.015` |
| `urine_albumin` | Float | Urine Albumin / Protein (0.0 - 4.0) | No | `0.0` |
| `urine_sugar` | Float | Urine Sugar / Glucose (0.0 - 4.0) | No | `0.0` |
| `test_name_Red_Blood_Cells`| Int/String | RBCs present? (`0` or `1`) | No | `0` |
| `bacteria_Present`| Int/String | Bacteria present? (`0` or `1`) | No | `0` |
| `pus_cell_clumps_Present`| Int/String| Pus cell clumps? (`0` or `1`) | No | `0` |

---

## 5. LDL Prediction (`/ldl`)

**URL**: `POST /ldl`

A streamlined endpoint for isolated Low-Density Lipoprotein evaluations.

### Request Body Schema (JSON)
| Field | Type | Description | Required | Default |
|-------|------|-------------|----------|---------|
| `lab_ldl` | Float | Serum LDL Level (mg/dL) | **Yes** | - |

---

## Standard Response Format

All successful predictions return a standardized JSON payload structure:

```json
{
  "test_name": "Sugar Test",
  "prediction": "Normal", 
  "prediction_class": 1,
  "abnormality_probability": 13.4,
  "raw_probabilities": [0.134, 0.866]
}
```
- **`prediction`**: A string indicating `"Normal"` or `"Abnormal"`.
- **`abnormality_probability`**: A percentage out of 100 representing the risk score.
- **`raw_probabilities`**: The raw output array from the ML model class probabilities `[Prob(Abnormal), Prob(Normal)]`.

## Error Responses

**HTTP 401 Unauthorized**
Returned if the `X-API-Key` header is omitted or incorrect.
```json
{
  "detail": "Invalid or missing API Key"
}
```

**HTTP 422 Unprocessable Entity**
Returned if a `Required` field is omitted or provided with an invalid data type.
```json
{
  "detail": [
    {
      "loc": ["body", "glucose"],
      "msg": "field required",
      "type": "value_error.missing"
    }
  ]
}
```
