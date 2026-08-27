# Ayusync Voice Calling Agent API Documentation

This document describes the API endpoints available for the Ayusync Voice Calling Agent. This API is designed to be consumed by the Doc AI Core System to programmatically trigger dynamic AI outbound voice calls to patients.

## Base URL
**Production Environment:**
`https://ayusync.toplabs.in`

---

## Initiate Outbound Call

Triggers a new outbound voice call via Vobiz. The voice agent will connect to the patient and dynamically adjust its behavior and dialogue based on the injected `agent_instruction`.

### Endpoint
`POST /api/call`

### Headers
- `Content-Type: application/json`
- `Authorization: Bearer <AYUSYNC_API_KEY>` (Required for security)

### Request Body (JSON)

| Parameter | Type | Required | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `phone` | `string` | **Yes** | - | The patient's phone number including the country code (e.g., `+919876543210`). |
| `name` | `string` | **Yes** | - | The patient's full name. The AI uses this to personalize the greeting. |
| `call_reason` | `string` | No | `"general"` | An internal category identifier for the call (e.g., `"medication_reminder"`, `"appointment_followup"`). |
| `agent_instruction` | `string` | No | `"Perform a general health checkup and ask how they are feeling."` | **Critical:** The dynamic instruction injected directly into the LLM's system prompt. This dictates exactly what the AI will discuss with the patient. |

### Example Request

```bash
curl -X POST https://ayusync.toplabs.in/api/call \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ayusync_admin_123" \
  -d '{
    "phone": "+919876543210",
    "name": "Ramesh Kumar",
    "call_reason": "medication_reminder",
    "agent_instruction": "Remind the patient to take their Paracetamol 500mg after dinner tonight. Also ask if their fever has reduced since yesterday."
  }'
```

### Response

**Success (200 OK)**
```json
{
  "status": "success",
  "message": "Calling Ramesh Kumar at +919876543210"
}
```

**Error Responses**
- **500 Internal Server Error:** Returned if Vobiz API credentials are missing, or if the Vobiz network fails to initiate the call.

---

## Telephony Architecture (Internal)
The system utilizes Vobiz (a Plivo wrapper) for telephony.
1. When `/api/call` is triggered, the FastAPI server requests Vobiz to dial the `phone` number.
2. The server passes an `answer_url` webhook (`/webhook/vobiz/inbound`) to Vobiz containing the `name` and `agent_instruction` context parameters.
3. When the patient answers, Vobiz hits the webhook, which returns an XML response instructing Vobiz to open a bidirectional audio stream.
4. Vobiz connects to the `/ws/vobiz` WebSocket endpoint on the FastAPI server, streaming the audio while maintaining the context of the specific patient and instruction.
