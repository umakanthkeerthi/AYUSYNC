import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/patient_models.dart';

class PatientRepository {
  // Use 10.0.2.2 ONLY for Android Emulator. Use 127.0.0.1 for everything else (Web, Windows, iOS Simulator).
  final Dio _dio = Dio(BaseOptions(
      baseUrl: (defaultTargetPlatform == TargetPlatform.android)
          ? 'http://10.0.2.2:8000/api/v1/patients'
          : 'http://127.0.0.1:8000/api/v1/patients'));

  Future<String> login(String username, String password) async {
    final response = await _dio.post('/login', data: {
      'username': username,
      'password': password,
    });
    return response.data['patient_id'];
  }

  Future<PatientProfile> getProfile(String patientId) async {
    final response = await _dio.get('/$patientId/profile');
    return PatientProfile.fromJson(response.data);
  }

  Future<List<Condition>> getConditions(String patientId) async {
    final response = await _dio.get('/$patientId/conditions');
    return (response.data as List).map((c) => Condition.fromJson(c)).toList();
  }

  Future<List<Medication>> getMedications(String patientId) async {
    final response = await _dio.get('/$patientId/medications');
    return (response.data as List).map((m) => Medication.fromJson(m)).toList();
  }

  Future<List<VitalSign>> getVitals(String patientId) async {
    final response = await _dio.get('/$patientId/vitals');
    return (response.data as List).map((v) => VitalSign.fromJson(v)).toList();
  }

  Future<Map<String, dynamic>> getRecoveryPlan(String patientId, {String? date}) async {
    final response = await _dio.get(
      '/$patientId/plan',
      queryParameters: date != null ? {'date': date} : null,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getLabTests(String patientId) async {
    final response = await _dio.get('/$patientId/labs');
    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> getReportsSummary(String patientId) async {
    final response = await _dio.get('/$patientId/reports-summary');
    return response.data as Map<String, dynamic>;
  }
}
