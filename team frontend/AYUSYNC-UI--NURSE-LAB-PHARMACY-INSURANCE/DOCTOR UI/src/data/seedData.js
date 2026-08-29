export const initialPatients = [
    {
        id: 'PT-1001',
        name: 'Rahul Kumar',
        age: 45,
        gender: 'Male',
        diagnosis: 'Hypertension',
        condition: 'Cardiology',
        riskScore: 72,
        urgency: 'Urgent',
        postDischargeDays: 5,
        recentChanges: ['BP increasing (150/95)', 'Medication adherence low', 'Patient reported dizziness'],
        medications: [
            { name: 'Amlodipine', dose: '5mg', frequency: 'Once daily', adherence: 'Low' }
        ],
        labStatus: 'Pending',
        appointmentStatus: 'Scheduled',
        interventionStatus: 'Pending',
        lastUpdated: '2023-11-20T08:30:00Z'
    },
    {
        id: 'PT-1002',
        name: 'Priya Sharma',
        age: 32,
        gender: 'Female',
        diagnosis: 'Type 1 Diabetes',
        condition: 'Diabetes',
        riskScore: 65,
        urgency: 'Follow-up',
        postDischargeDays: 3,
        recentChanges: ['HbA1c slightly elevated', 'Reported morning fatigue'],
        medications: [
            { name: 'Insulin Glargine', dose: '20 units', frequency: 'Nightly', adherence: 'High' }
        ],
        labStatus: 'Abnormal',
        appointmentStatus: 'Missed',
        interventionStatus: 'None',
        lastUpdated: '2023-11-21T09:15:00Z'
    },
    {
        id: 'PT-1003',
        name: 'Arjun Rao',
        age: 60,
        gender: 'Male',
        diagnosis: 'Post-CABG',
        condition: 'Post-operative',
        riskScore: 42,
        urgency: 'Routine',
        postDischargeDays: 12,
        recentChanges: ['Incision site healing well', 'Walking 1km daily'],
        medications: [
            { name: 'Aspirin', dose: '75mg', frequency: 'Once daily', adherence: 'High' },
            { name: 'Atorvastatin', dose: '40mg', frequency: 'Nightly', adherence: 'High' }
        ],
        labStatus: 'Normal',
        appointmentStatus: 'Pending',
        interventionStatus: 'None',
        lastUpdated: '2023-11-22T10:00:00Z'
    },
    {
        id: 'PT-1004',
        name: 'Sunita Desai',
        age: 55,
        gender: 'Female',
        diagnosis: 'Asthma',
        condition: 'Respiratory',
        riskScore: 25,
        urgency: 'Routine',
        postDischargeDays: 20,
        recentChanges: ['No nocturnal symptoms', 'Inhaler use decreased'],
        medications: [
            { name: 'Budesonide', dose: '200mcg', frequency: 'Twice daily', adherence: 'High' }
        ],
        labStatus: 'Normal',
        appointmentStatus: 'Scheduled',
        interventionStatus: 'Completed',
        lastUpdated: '2023-11-19T14:20:00Z'
    },
    {
        id: 'PT-1005',
        name: 'Vikram Singh',
        age: 68,
        gender: 'Male',
        diagnosis: 'Heart Failure',
        condition: 'Cardiology',
        riskScore: 85,
        urgency: 'Urgent',
        postDischargeDays: 2,
        recentChanges: ['Weight increased by 2kg in 24h', 'Shortness of breath at rest'],
        medications: [
            { name: 'Furosemide', dose: '40mg', frequency: 'Twice daily', adherence: 'Medium' }
        ],
        labStatus: 'Pending',
        appointmentStatus: 'None',
        interventionStatus: 'Required',
        lastUpdated: '2023-11-23T07:45:00Z'
    },
    {
        id: 'PT-1006',
        name: 'Neha Gupta',
        age: 41,
        gender: 'Female',
        diagnosis: 'Gestational Diabetes',
        condition: 'Diabetes',
        riskScore: 48,
        urgency: 'Follow-up',
        postDischargeDays: 0,
        recentChanges: ['Fasting sugar slightly high'],
        medications: [],
        labStatus: 'Normal',
        appointmentStatus: 'Scheduled',
        interventionStatus: 'None',
        lastUpdated: '2023-11-22T16:30:00Z'
    },
    {
        id: 'PT-1007',
        name: 'Suresh Patel',
        age: 72,
        gender: 'Male',
        diagnosis: 'COPD',
        condition: 'Respiratory',
        riskScore: 68,
        urgency: 'Urgent',
        postDischargeDays: 8,
        recentChanges: ['Increased sputum production', 'SpO2 91% on room air'],
        medications: [
            { name: 'Tiotropium', dose: '18mcg', frequency: 'Once daily', adherence: 'High' }
        ],
        labStatus: 'Abnormal',
        appointmentStatus: 'Pending',
        interventionStatus: 'Required',
        lastUpdated: '2023-11-23T09:10:00Z'
    },
    {
        id: 'PT-1008',
        name: 'Anjali Verma',
        age: 29,
        gender: 'Female',
        diagnosis: 'Migraine',
        condition: 'General',
        riskScore: 15,
        urgency: 'Routine',
        postDischargeDays: 15,
        recentChanges: ['Frequency of attacks reduced'],
        medications: [
            { name: 'Propranolol', dose: '40mg', frequency: 'Twice daily', adherence: 'High' }
        ],
        labStatus: 'Normal',
        appointmentStatus: 'Scheduled',
        interventionStatus: 'None',
        lastUpdated: '2023-11-18T11:00:00Z'
    },
    {
        id: 'PT-1009',
        name: 'Rajesh Kumar',
        age: 52,
        gender: 'Male',
        diagnosis: 'Essential Hypertension',
        condition: 'Hypertension',
        riskScore: 55,
        urgency: 'Follow-up',
        postDischargeDays: 6,
        recentChanges: ['BP stabilized at 135/85'],
        medications: [
            { name: 'Telmisartan', dose: '40mg', frequency: 'Once daily', adherence: 'Medium' }
        ],
        labStatus: 'Normal',
        appointmentStatus: 'Missed',
        interventionStatus: 'Pending',
        lastUpdated: '2023-11-21T15:20:00Z'
    },
    {
        id: 'PT-1010',
        name: 'Meera Reddy',
        age: 63,
        gender: 'Female',
        diagnosis: 'Osteoarthritis (Knee Replacement)',
        condition: 'Post-operative',
        riskScore: 35,
        urgency: 'Routine',
        postDischargeDays: 14,
        recentChanges: ['Physiotherapy progressing well', 'Pain manageable'],
        medications: [
            { name: 'Paracetamol', dose: '500mg', frequency: 'As needed', adherence: 'High' }
        ],
        labStatus: 'Normal',
        appointmentStatus: 'Scheduled',
        interventionStatus: 'None',
        lastUpdated: '2023-11-20T10:30:00Z'
    },
    {
        id: 'PT-1011',
        name: 'Karan Malhotra',
        age: 38,
        gender: 'Male',
        diagnosis: 'Type 2 Diabetes',
        condition: 'Diabetes',
        riskScore: 78,
        urgency: 'Urgent',
        postDischargeDays: 4,
        recentChanges: ['Hypoglycemic episode reported', 'Skipped meals'],
        medications: [
            { name: 'Metformin', dose: '1000mg', frequency: 'Twice daily', adherence: 'Low' }
        ],
        labStatus: 'Pending',
        appointmentStatus: 'None',
        interventionStatus: 'Required',
        lastUpdated: '2023-11-23T06:15:00Z'
    },
    {
        id: 'PT-1012',
        name: 'Pooja Iyer',
        age: 47,
        gender: 'Female',
        diagnosis: 'Atrial Fibrillation',
        condition: 'Cardiology',
        riskScore: 62,
        urgency: 'Follow-up',
        postDischargeDays: 10,
        recentChanges: ['Mild palpitations noted occasionally'],
        medications: [
            { name: 'Rivaroxaban', dose: '20mg', frequency: 'Once daily', adherence: 'High' }
        ],
        labStatus: 'Abnormal',
        appointmentStatus: 'Scheduled',
        interventionStatus: 'Pending',
        lastUpdated: '2023-11-22T13:40:00Z'
    },
    {
        id: 'PT-1013',
        name: 'Amit Shah',
        age: 59,
        gender: 'Male',
        diagnosis: 'Chronic Kidney Disease Stg 3',
        condition: 'General',
        riskScore: 75,
        urgency: 'Urgent',
        postDischargeDays: 7,
        recentChanges: ['Creatinine increased', 'Edema in lower limbs'],
        medications: [
            { name: 'Torsemide', dose: '10mg', frequency: 'Once daily', adherence: 'High' }
        ],
        labStatus: 'Abnormal',
        appointmentStatus: 'Pending',
        interventionStatus: 'Required',
        lastUpdated: '2023-11-23T10:05:00Z'
    },
    {
        id: 'PT-1014',
        name: 'Deepa Nair',
        age: 33,
        gender: 'Female',
        diagnosis: 'Anemia',
        condition: 'General',
        riskScore: 22,
        urgency: 'Routine',
        postDischargeDays: 25,
        recentChanges: ['Energy levels improved'],
        medications: [
            { name: 'Ferrous Ascorbate', dose: '100mg', frequency: 'Once daily', adherence: 'High' }
        ],
        labStatus: 'Normal',
        appointmentStatus: 'Scheduled',
        interventionStatus: 'None',
        lastUpdated: '2023-11-15T09:20:00Z'
    },
    {
        id: 'PT-1015',
        name: 'Rohan Gupta',
        age: 51,
        gender: 'Male',
        diagnosis: 'Hypertensive Crisis (Resolved)',
        condition: 'Hypertension',
        riskScore: 45,
        urgency: 'Follow-up',
        postDischargeDays: 9,
        recentChanges: ['BP stable 130/80', 'Headaches resolved'],
        medications: [
            { name: 'Losartan', dose: '50mg', frequency: 'Once daily', adherence: 'High' }
        ],
        labStatus: 'Normal',
        appointmentStatus: 'Scheduled',
        interventionStatus: 'None',
        lastUpdated: '2023-11-21T16:00:00Z'
    },
    {
        id: 'PT-1016',
        name: 'Sneha Joshi',
        age: 44,
        gender: 'Female',
        diagnosis: 'Cholecystectomy',
        condition: 'Post-operative',
        riskScore: 18,
        urgency: 'Routine',
        postDischargeDays: 6,
        recentChanges: ['Tolerating normal diet', 'Wound clean'],
        medications: [],
        labStatus: 'Normal',
        appointmentStatus: 'Scheduled',
        interventionStatus: 'None',
        lastUpdated: '2023-11-22T11:15:00Z'
    },
    {
        id: 'PT-1017',
        name: 'Vijay Singh',
        age: 76,
        gender: 'Male',
        diagnosis: 'Pneumonia',
        condition: 'Respiratory',
        riskScore: 82,
        urgency: 'Urgent',
        postDischargeDays: 3,
        recentChanges: ['Fever returned (38.5C)', 'Cough worsening'],
        medications: [
            { name: 'Amoxicillin-Clavulanate', dose: '625mg', frequency: 'Twice daily', adherence: 'High' }
        ],
        labStatus: 'Pending',
        appointmentStatus: 'None',
        interventionStatus: 'Required',
        lastUpdated: '2023-11-23T08:50:00Z'
    },
    {
        id: 'PT-1018',
        name: 'Ritu Agarwal',
        age: 39,
        gender: 'Female',
        diagnosis: 'Hyperthyroidism',
        condition: 'General',
        riskScore: 38,
        urgency: 'Routine',
        postDischargeDays: 18,
        recentChanges: ['Heart rate normalized', 'Gaining weight slightly'],
        medications: [
            { name: 'Carbimazole', dose: '10mg', frequency: 'Once daily', adherence: 'Medium' }
        ],
        labStatus: 'Normal',
        appointmentStatus: 'Scheduled',
        interventionStatus: 'None',
        lastUpdated: '2023-11-19T10:45:00Z'
    },
    {
        id: 'PT-1019',
        name: 'Manoj Tiwari',
        age: 57,
        gender: 'Male',
        diagnosis: 'Coronary Artery Disease',
        condition: 'Cardiology',
        riskScore: 66,
        urgency: 'Follow-up',
        postDischargeDays: 11,
        recentChanges: ['Occasional angina on exertion'],
        medications: [
            { name: 'Metoprolol', dose: '25mg', frequency: 'Once daily', adherence: 'High' },
            { name: 'Nitroglycerin', dose: '0.4mg', frequency: 'PRN', adherence: 'High' }
        ],
        labStatus: 'Normal',
        appointmentStatus: 'Pending',
        interventionStatus: 'None',
        lastUpdated: '2023-11-22T14:30:00Z'
    },
    {
        id: 'PT-1020',
        name: 'Kavita Das',
        age: 26,
        gender: 'Female',
        diagnosis: 'Appendectomy',
        condition: 'Post-operative',
        riskScore: 12,
        urgency: 'Routine',
        postDischargeDays: 5,
        recentChanges: ['Fully active', 'No pain'],
        medications: [],
        labStatus: 'Normal',
        appointmentStatus: 'Completed',
        interventionStatus: 'None',
        lastUpdated: '2023-11-20T12:00:00Z'
    }
];
