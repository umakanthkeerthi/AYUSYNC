import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/patient_models.dart';

class PatientRepository {
  // Pointing to your machine's local IP so your physical phone can connect to the backend
  final Dio _dio;

  PatientRepository()
      : _dio = Dio(BaseOptions(
      baseUrl: 'http://16.171.226.51/api/v1/patients',
      connectTimeout: const Duration(seconds: 3),
      receiveTimeout: const Duration(seconds: 10),
  ));

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

  Future<List<dynamic>> getDischargeSummaries(String patientId) async {
    final response = await _dio.get('/$patientId/discharge-summaries');
    return response.data as List<dynamic>;
  }

  Future<List<dynamic>> getChatSummaries(String patientId) async {
    final response = await _dio.get('/$patientId/chat-summaries');
    return response.data as List<dynamic>;
  }

  Future<String> sendChatMessage(String patientId, String message) async {
    final response = await _dio.post(
      '/$patientId/chat',
      data: {'text': message},
    );
    return response.data['response'];
  }

  Future<void> summarizeChat(String patientId) async {
    await _dio.post('/$patientId/chat/summarize');
  }

  Future<void> submitVitals(String patientId, Map<String, dynamic> vitals) async {
    await _dio.post('/$patientId/vitals', data: vitals);
  }
}
