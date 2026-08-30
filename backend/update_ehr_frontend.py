import os

path = r'C:\Users\keert\Desktop\demo ehr\frontend\app.js'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

target = 'statusMessage.textContent = `Success! Discharge Summary generated for Patient #${selectedPatientId}. Webhook fired to Post-Discharge Solution.`;'
replacement = """
            // Fetch AYUSYNC Credentials dynamically for the simulation pitch
            try {
                const ayusyncRes = await fetch(`http://127.0.0.1:8000/api/v1/patients/simulate-discharge/${selectedPatientId}`, { method: 'POST' });
                if (ayusyncRes.ok) {
                    const creds = await ayusyncRes.json();
                    statusMessage.innerHTML = `Success! Discharge Summary generated for Patient #${selectedPatientId}. Webhook fired to AyuSync.<br><br><b>✅ Patient Registered to AyuSync. Provide these credentials to the patient:</b><br>Username: <strong>${creds.username}</strong><br>Password: <strong>${creds.password}</strong>`;
                } else {
                    statusMessage.textContent = `Success! Discharge Summary generated for Patient #${selectedPatientId}. Webhook fired to Post-Discharge Solution.`;
                }
            } catch (e) {
                console.error("AyuSync fetch failed:", e);
                statusMessage.textContent = `Success! Discharge Summary generated for Patient #${selectedPatientId}. Webhook fired to Post-Discharge Solution.`;
            }
"""

if target in content:
    content = content.replace(target, replacement)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
    print("app.js updated successfully!")
else:
    print("Could not find the target string in app.js!")
