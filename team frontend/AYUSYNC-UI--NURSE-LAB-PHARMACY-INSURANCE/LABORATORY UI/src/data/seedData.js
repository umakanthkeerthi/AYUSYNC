export const seedRecords = [
    {
        id: 'LAB-2026-008421', patientId: 'PT-1001', patientName: 'Rahul Kumar', patientAge: 45, patientGender: 'Male',
        testName: 'CBC', testCategory: 'Hematology', sampleType: 'Blood',
        collectionDate: new Date(Date.now() + 86400000).toISOString().split('T')[0], collectionTime: '10:00 AM',
        status: 'Scheduled', urgency: 'Priority', riskScore: 75, riskLevel: 'High',
        assignedTechnician: 'Tech. Kumar', result: null, unit: null, referenceRange: null, resultStatus: null,
        notes: '', criticalFlag: false, createdAt: new Date().toISOString(), updatedAt: new Date().toISOString()
    },
    {
        id: 'LAB-2026-008422', patientId: 'PT-1002', patientName: 'Priya Sharma', patientAge: 38, patientGender: 'Female',
        testName: 'Thyroid Profile', testCategory: 'Biochemistry', sampleType: 'Blood',
        collectionDate: new Date().toISOString().split('T')[0], collectionTime: '11:30 AM',
        status: 'Collected', urgency: 'Routine', riskScore: 20, riskLevel: 'Low',
        assignedTechnician: 'Tech. Kumar', result: null, unit: null, referenceRange: null, resultStatus: null,
        notes: '', criticalFlag: false, createdAt: new Date(Date.now() - 3600000).toISOString(), updatedAt: new Date().toISOString()
    },
    {
        id: 'LAB-2026-008423', patientId: 'PT-1003', patientName: 'Arjun Rao', patientAge: 55, patientGender: 'Male',
        testName: 'Lipid Profile', testCategory: 'Biochemistry', sampleType: 'Blood',
        collectionDate: new Date().toISOString().split('T')[0], collectionTime: '12:00 PM',
        status: 'Collected', urgency: 'Routine', riskScore: 45, riskLevel: 'Medium',
        assignedTechnician: 'Tech. Kumar', result: null, unit: null, referenceRange: null, resultStatus: null,
        notes: '', criticalFlag: false, createdAt: new Date(Date.now() - 7200000).toISOString(), updatedAt: new Date().toISOString()
    },
    {
        id: 'LAB-2026-008424', patientId: 'PT-1004', patientName: 'Meera Iyer', patientAge: 29, patientGender: 'Female',
        testName: 'Vitamin D', testCategory: 'Vitamin', sampleType: 'Blood',
        collectionDate: new Date().toISOString().split('T')[0], collectionTime: '1:00 PM',
        status: 'Pending', urgency: 'Routine', riskScore: 10, riskLevel: 'Low',
        assignedTechnician: 'Tech. Kumar', result: null, unit: null, referenceRange: null, resultStatus: null,
        notes: '', criticalFlag: false, createdAt: new Date().toISOString(), updatedAt: new Date().toISOString()
    },
    {
        id: 'LAB-2026-008425', patientId: 'PT-1005', patientName: 'Sohan Das', patientAge: 62, patientGender: 'Male',
        testName: 'CBC', testCategory: 'Hematology', sampleType: 'Blood',
        collectionDate: new Date(Date.now() + 86400000).toISOString().split('T')[0], collectionTime: '10:30 AM',
        status: 'Scheduled', urgency: 'Routine', riskScore: 82, riskLevel: 'High',
        assignedTechnician: 'Tech. Kumar', result: null, unit: null, referenceRange: null, resultStatus: null,
        notes: '', criticalFlag: false, createdAt: new Date().toISOString(), updatedAt: new Date().toISOString()
    },
    {
        id: 'LAB-2026-008426', patientId: 'PT-1006', patientName: 'Vikram Singh', patientAge: 71, patientGender: 'Male',
        testName: 'Kidney Function Test', testCategory: 'Biochemistry', sampleType: 'Blood',
        collectionDate: new Date(Date.now() - 86400000).toISOString().split('T')[0], collectionTime: '09:00 AM',
        status: 'Critical', urgency: 'Urgent', riskScore: 90, riskLevel: 'High',
        assignedTechnician: 'Tech. Kumar', result: 'Creatinine 4.2', unit: 'mg/dL', referenceRange: '0.7 - 1.3 mg/dL', resultStatus: 'Critical',
        notes: 'Creatinine severely elevated. Dialysis team notified.', criticalFlag: true, createdAt: new Date(Date.now() - 86400000).toISOString(), updatedAt: new Date(Date.now() - 7200000).toISOString()
    },
    {
        id: 'LAB-2026-008427', patientId: 'PT-1007', patientName: 'Ananya Patel', patientAge: 41, patientGender: 'Female',
        testName: 'Liver Function Test', testCategory: 'Biochemistry', sampleType: 'Blood',
        collectionDate: new Date(Date.now() - 86400000).toISOString().split('T')[0], collectionTime: '10:00 AM',
        status: 'Completed', urgency: 'Routine', riskScore: 30, riskLevel: 'Low',
        assignedTechnician: 'Tech. Kumar', result: 'AST 25, ALT 30', unit: 'U/L', referenceRange: 'AST 8-48, ALT 7-55', resultStatus: 'Normal',
        notes: 'All liver enzymes within normal limits.', criticalFlag: false, createdAt: new Date(Date.now() - 86400000).toISOString(), updatedAt: new Date(Date.now() - 3600000).toISOString()
    },
    {
        id: 'LAB-2026-008428', patientId: 'PT-1008', patientName: 'Sneha Reddy', patientAge: 53, patientGender: 'Female',
        testName: 'HbA1c', testCategory: 'Biochemistry', sampleType: 'Blood',
        collectionDate: new Date().toISOString().split('T')[0], collectionTime: '08:30 AM',
        status: 'Processing', urgency: 'Priority', riskScore: 65, riskLevel: 'Medium',
        assignedTechnician: 'Tech. Kumar', result: null, unit: null, referenceRange: null, resultStatus: null,
        notes: '', criticalFlag: false, createdAt: new Date(Date.now() - 28800000).toISOString(), updatedAt: new Date().toISOString()
    },
    {
        id: 'LAB-2026-008429', patientId: 'PT-1009', patientName: 'Karan Mehta', patientAge: 25, patientGender: 'Male',
        testName: 'Blood Glucose', testCategory: 'Biochemistry', sampleType: 'Blood',
        collectionDate: new Date().toISOString().split('T')[0], collectionTime: '07:30 AM',
        status: 'Processing', urgency: 'Urgent', riskScore: 88, riskLevel: 'High',
        assignedTechnician: 'Tech. Kumar', result: null, unit: null, referenceRange: null, resultStatus: null,
        notes: 'Patient arrived in ER with suspected DKA.', criticalFlag: false, createdAt: new Date(Date.now() - 36000000).toISOString(), updatedAt: new Date().toISOString()
    },
    {
        id: 'LAB-2026-008430', patientId: 'PT-1010', patientName: 'Neha Kapoor', patientAge: 34, patientGender: 'Female',
        testName: 'Urine Analysis', testCategory: 'Other', sampleType: 'Urine',
        collectionDate: new Date(Date.now() - 86400000).toISOString().split('T')[0], collectionTime: '14:00 PM',
        status: 'Critical', urgency: 'Urgent', riskScore: 50, riskLevel: 'Medium',
        assignedTechnician: 'Tech. Kumar', result: 'WBC >50/hpf, Nitrites Positive', unit: 'N/A', referenceRange: 'WBC <5, Nitrites Negative', resultStatus: 'Critical',
        notes: 'Severe UTI confirmed.', criticalFlag: true, createdAt: new Date(Date.now() - 86400000).toISOString(), updatedAt: new Date(Date.now() - 43200000).toISOString()
    }
];

// Add 20 more random processing/pending/completed to reach 30 records
const testNames = ['Electrolytes', 'Troponin', 'PT/INR', 'D-Dimer', 'CRP', 'ESR', 'Serum Calcium', 'Amylase'];
const names = ['Aditya Rao', 'Sara Khan', 'Rohit Sharma', 'Pooja Bhatt', 'Anil Kumar'];
for (let i = 0; i < 20; i++) {
    const statusRand = Math.random();
    let status = 'Pending';
    if (statusRand > 0.8) status = 'Completed';
    else if (statusRand > 0.6) status = 'Processing';
    else if (statusRand > 0.4) status = 'Collected';

    seedRecords.push({
        id: `LAB-2026-0084${31 + i}`,
        patientId: `PT-10${11 + (i % 5)}`,
        patientName: names[i % 5],
        patientAge: 30 + (i * 2),
        patientGender: i % 2 === 0 ? 'Male' : 'Female',
        testName: testNames[i % testNames.length],
        testCategory: 'Other',
        sampleType: 'Blood',
        collectionDate: new Date().toISOString().split('T')[0],
        collectionTime: '09:00 AM',
        status: status,
        urgency: i % 4 === 0 ? 'Urgent' : 'Routine',
        riskScore: Math.floor(Math.random() * 100),
        riskLevel: 'Medium', // Re-calculated in init anyway
        assignedTechnician: 'Tech. Kumar',
        result: status === 'Completed' ? 'Normal Value' : null,
        unit: 'N/A',
        referenceRange: 'N/A',
        resultStatus: status === 'Completed' ? 'Normal' : null,
        notes: '',
        criticalFlag: false,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
    });
}
