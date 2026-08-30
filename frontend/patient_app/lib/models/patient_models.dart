class PatientProfile {
  final String id;
  final String name;
  final String phone;
  final DateTime dob;
  final String? bloodType;

  PatientProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.dob,
    this.bloodType,
  });

  factory PatientProfile.fromJson(Map<String, dynamic> json) {
    return PatientProfile(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      dob: DateTime.parse(json['dob']),
      bloodType: json['blood_type'],
    );
  }
}

class Condition {
  final String id;
  final String name;
  final String status;

  Condition({
    required this.id,
    required this.name,
    required this.status,
  });

  factory Condition.fromJson(Map<String, dynamic> json) {
    return Condition(
      id: json['id'],
      name: json['name'],
      status: json['status'],
    );
  }
}

class Medication {
  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final bool isActive;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.isActive,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      name: json['name'],
      dosage: json['dosage'],
      frequency: json['frequency'],
      isActive: json['is_active'] ?? true,
    );
  }
}

class VitalSign {
  final String id;
  final DateTime timestamp;
  final int? heartRate;
  final int? bpSystolic;
  final int? bpDiastolic;
  final int? spo2;

  VitalSign({
    required this.id,
    required this.timestamp,
    this.heartRate,
    this.bpSystolic,
    this.bpDiastolic,
    this.spo2,
  });

  factory VitalSign.fromJson(Map<String, dynamic> json) {
    return VitalSign(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      heartRate: json['heart_rate'],
      bpSystolic: json['bp_systolic'],
      bpDiastolic: json['bp_diastolic'],
      spo2: json['spo2'],
    );
  }
}
