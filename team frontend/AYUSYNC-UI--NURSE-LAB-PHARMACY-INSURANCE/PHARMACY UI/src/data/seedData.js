export const seedData = {
    prescriptions: [
        { id: 'RX-2026-001', patientId: 'PT-1001', patientName: 'Rahul Kumar', patientAge: 45, patientGender: 'Male', medications: 'Metformin 500mg, Atorvastatin 20mg, Amlodipine 5mg', prescribedBy: 'Dr. Sarah Chen', urgency: 'Priority', riskScore: 72, riskLevel: 'High', status: 'New', date: new Date().toISOString(), notes: '' },
        { id: 'RX-2026-002', patientId: 'PT-1002', patientName: 'Priya Sharma', patientAge: 38, patientGender: 'Female', medications: 'Levothyroxine 50mcg, Vitamin D 1000IU', prescribedBy: 'Dr. James Wilson', urgency: 'Routine', riskScore: 20, riskLevel: 'Low', status: 'Ready', date: new Date(Date.now()-86400000).toISOString(), notes: '' },
        { id: 'RX-2026-003', patientId: 'PT-1003', patientName: 'Arjun Rao', patientAge: 55, patientGender: 'Male', medications: 'Losartan 50mg, Aspirin 81mg, Furosemide 40mg, Pantoprazole 40mg', prescribedBy: 'Dr. Sarah Chen', urgency: 'Routine', riskScore: 45, riskLevel: 'Medium', status: 'Dispensed', date: new Date(Date.now()-172800000).toISOString(), notes: '' },
        { id: 'RX-2026-004', patientId: 'PT-1004', patientName: 'Meera Iyer', patientAge: 29, patientGender: 'Female', medications: 'Amoxicillin 500mg', prescribedBy: 'Dr. James Wilson', urgency: 'Routine', riskScore: 10, riskLevel: 'Low', status: 'Dispensed', date: new Date(Date.now()-259200000).toISOString(), notes: '' },
        { id: 'RX-2026-005', patientId: 'PT-1005', patientName: 'Sohan Das', patientAge: 62, patientGender: 'Male', medications: 'Insulin Glargine 100 units/mL, Metformin 1000mg', prescribedBy: 'Dr. Sarah Chen', urgency: 'Urgent', riskScore: 82, riskLevel: 'High', status: 'New', date: new Date().toISOString(), notes: 'Patient needs immediate insulin supply.' },
        { id: 'RX-2026-006', patientId: 'PT-1006', patientName: 'Vikram Singh', patientAge: 71, patientGender: 'Male', medications: 'Carvedilol 12.5mg', prescribedBy: 'Dr. Emma Stone', urgency: 'Routine', riskScore: 65, riskLevel: 'Medium', status: 'Verified', date: new Date(Date.now()-3600000).toISOString(), notes: '' },
        { id: 'RX-2026-007', patientId: 'PT-1007', patientName: 'Ananya Patel', patientAge: 41, patientGender: 'Female', medications: 'Sertraline 50mg', prescribedBy: 'Dr. James Wilson', urgency: 'Routine', riskScore: 30, riskLevel: 'Low', status: 'Preparing', date: new Date(Date.now()-7200000).toISOString(), notes: '' }
    ],
    refills: [
        { id: 'RF-2026-001', rxId: 'RX-2025-999', patientId: 'PT-1002', patientName: 'Priya Sharma', medicine: 'Levothyroxine 50mcg', refillCount: 2, date: new Date().toISOString(), status: 'Requested', urgency: 'Routine', riskScore: 20 },
        { id: 'RF-2026-002', rxId: 'RX-2025-998', patientId: 'PT-1008', patientName: 'Sneha Reddy', medicine: 'Atorvastatin 20mg', refillCount: 4, date: new Date(Date.now()-86400000).toISOString(), status: 'Under Review', urgency: 'Priority', riskScore: 65 }
    ],
    deliveries: [
        { id: 'DL-2026-001', rxId: 'RX-2026-003', patientName: 'Arjun Rao', address: '123 Main St, Apt 4B', date: new Date().toISOString(), status: 'Out for Delivery', urgency: 'Routine' },
        { id: 'DL-2026-002', rxId: 'RX-2026-004', patientName: 'Meera Iyer', address: '456 Oak Rd', date: new Date(Date.now()-86400000).toISOString(), status: 'Delivered', urgency: 'Routine' }
    ],
    inventory: [
        { id: 'INV-001', medicine: 'Metformin 500mg', category: 'Tablets', available: 5000, reorderLevel: 1000, status: 'In Stock', expiry: '2028-12-01', supplier: 'PharmaCorp' },
        { id: 'INV-002', medicine: 'Atorvastatin 20mg', category: 'Tablets', available: 150, reorderLevel: 500, status: 'Low Stock', expiry: '2027-05-15', supplier: 'PharmaCorp' },
        { id: 'INV-003', medicine: 'Amlodipine 5mg', category: 'Tablets', available: 2000, reorderLevel: 800, status: 'In Stock', expiry: '2028-08-20', supplier: 'MediSupply' },
        { id: 'INV-004', medicine: 'Amoxicillin 500mg', category: 'Capsules', available: 0, reorderLevel: 400, status: 'Out of Stock', expiry: '2026-10-10', supplier: 'HealthPlus' },
        { id: 'INV-005', medicine: 'Levothyroxine 50mcg', category: 'Tablets', available: 450, reorderLevel: 300, status: 'In Stock', expiry: '2026-09-01', supplier: 'PharmaCorp' }
    ]
};

// Auto-generate remaining data to meet the 30+ requirement
const names = ['Karan Mehta', 'Neha Kapoor', 'Aditya Rao', 'Amit Patel', 'Sonia Gandhi', 'Rajesh Kumar'];
const meds = ['Pantoprazole 40mg', 'Aspirin 81mg', 'Losartan 50mg', 'Vitamin D 1000IU', 'Insulin Glargine', 'Furosemide 40mg', 'Sertraline 50mg'];

for(let i=0; i<30; i++) {
    const rxStatus = ['New', 'Verified', 'Preparing', 'Ready', 'Dispensed'][Math.floor(Math.random()*5)];
    seedData.prescriptions.push({
        id: `RX-2026-1${i<10?'0'+i:i}`,
        patientId: `PT-10${10 + (i%6)}`,
        patientName: names[i%6],
        patientAge: 30 + (i%40),
        patientGender: i%2===0 ? 'Male' : 'Female',
        medications: meds[i%meds.length],
        prescribedBy: i%2===0 ? 'Dr. Sarah Chen' : 'Dr. James Wilson',
        urgency: i%5===0 ? 'Urgent' : (i%3===0 ? 'Priority' : 'Routine'),
        riskScore: Math.floor(Math.random() * 100),
        riskLevel: 'Medium', // Gets updated by utils anyway
        status: rxStatus,
        date: new Date(Date.now() - (Math.random() * 86400000 * 5)).toISOString(),
        notes: ''
    });
}

for(let i=0; i<15; i++) {
    seedData.refills.push({
        id: `RF-2026-1${i<10?'0'+i:i}`,
        rxId: `RX-2025-${800+i}`,
        patientId: `PT-10${10 + (i%6)}`,
        patientName: names[i%6],
        medicine: meds[i%meds.length],
        refillCount: Math.floor(Math.random()*5)+1,
        date: new Date(Date.now() - (Math.random() * 86400000 * 5)).toISOString(),
        status: ['Requested', 'Under Review', 'Approved', 'Dispensed'][Math.floor(Math.random()*4)],
        urgency: i%4===0 ? 'Priority' : 'Routine',
        riskScore: Math.floor(Math.random() * 100)
    });
}

for(let i=0; i<15; i++) {
    seedData.deliveries.push({
        id: `DL-2026-1${i<10?'0'+i:i}`,
        rxId: `RX-2026-${100+i}`,
        patientName: names[i%6],
        address: `${100+i} Random Street, City`,
        date: new Date(Date.now() - (Math.random() * 86400000 * 3)).toISOString(),
        status: ['Pending', 'Preparing', 'Out for Delivery', 'Delivered'][Math.floor(Math.random()*4)],
        urgency: 'Routine'
    });
}

for(let i=0; i<30; i++) {
    const qty = Math.floor(Math.random() * 5000);
    let status = 'In Stock';
    if(qty === 0) status = 'Out of Stock';
    else if(qty < 500) status = 'Low Stock';

    seedData.inventory.push({
        id: `INV-1${i<10?'0'+i:i}`,
        medicine: `Generic Med ${i}`,
        category: ['Tablets', 'Syrup', 'Injection', 'Topical'][i%4],
        available: qty,
        reorderLevel: 500,
        status: status,
        expiry: new Date(Date.now() + (Math.random() * 86400000 * 365 * 2)).toISOString().split('T')[0],
        supplier: i%2===0 ? 'PharmaCorp' : 'MediSupply'
    });
}
