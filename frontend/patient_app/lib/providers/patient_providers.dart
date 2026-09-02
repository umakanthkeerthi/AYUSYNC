import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/patient_models.dart';
import '../repositories/patient_repository.dart';

// 1. Repository Provider
final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  return PatientRepository();
});

// Local state for tracking tasks completed in the current session
final completedTaskIdsProvider = StateProvider<Set<String>>((ref) => {});

// 2. Auth Provider (Mocking Ramesh Gupta's Login Session)
class AuthState {
  final String? patientId;
  final bool isAuthenticated;

  AuthState({this.patientId, this.isAuthenticated = false});
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  
  AuthNotifier(this.ref) : super(AuthState(
    patientId: '0dfa2eea-13a6-449b-8ed5-32e68359d7b3', // Hardcoded Swathi Reddy to bypass login
    isAuthenticated: true,
  ));

  Future<void> login(String username, String password) async {
    try {
      final repository = ref.read(patientRepositoryProvider);
      final patientId = await repository.login(username, password);
      state = AuthState(patientId: patientId, isAuthenticated: true);
    } catch (e) {
      throw Exception('Invalid credentials or network error');
    }
  }

  void logout() {
    state = AuthState(isAuthenticated: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

// 3. Data Providers (Dependent on AuthProvider)
final patientProfileProvider = FutureProvider<PatientProfile?>((ref) async {
  final authState = ref.watch(authProvider);
  if (!authState.isAuthenticated || authState.patientId == null) return null;
  
  final repository = ref.watch(patientRepositoryProvider);
  return repository.getProfile(authState.patientId!);
});

final conditionsProvider = FutureProvider<List<Condition>>((ref) async {
  final authState = ref.watch(authProvider);
  if (!authState.isAuthenticated || authState.patientId == null) return [];
  
  final repository = ref.watch(patientRepositoryProvider);
  return repository.getConditions(authState.patientId!);
});

final medicationsProvider = FutureProvider<List<Medication>>((ref) async {
  final authState = ref.watch(authProvider);
  if (!authState.isAuthenticated || authState.patientId == null) return [];
  
  final repository = ref.watch(patientRepositoryProvider);
  return repository.getMedications(authState.patientId!);
});

final vitalsProvider = FutureProvider<List<VitalSign>>((ref) async {
  final authState = ref.watch(authProvider);
  if (!authState.isAuthenticated || authState.patientId == null) return [];
  
  final repository = ref.watch(patientRepositoryProvider);
  return repository.getVitals(authState.patientId!);
});

final recoveryPlanProvider = FutureProvider.family<Map<String, dynamic>?, DateTime>((ref, date) async {
  final authState = ref.watch(authProvider);
  if (authState.patientId == null) return null;
  final repo = ref.watch(patientRepositoryProvider);
  final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  return repo.getRecoveryPlan(authState.patientId!, date: dateStr);
});

final labTestsProvider = FutureProvider<List<dynamic>?>((ref) async {
  final authState = ref.watch(authProvider);
  if (authState.patientId == null) return null;
  
  final repo = ref.watch(patientRepositoryProvider);
  return repo.getLabTests(authState.patientId!);
});

final reportsSummaryProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final authState = ref.watch(authProvider);
  if (authState.patientId == null) return null;
  
  final repo = ref.watch(patientRepositoryProvider);
  return repo.getReportsSummary(authState.patientId!);
});

final dischargeSummariesProvider = FutureProvider<List<dynamic>>((ref) async {
  final authState = ref.watch(authProvider);
  if (authState.patientId == null) return [];
  
  final repo = ref.read(patientRepositoryProvider);
  return repo.getDischargeSummaries(authState.patientId!);
});

final chatSummariesProvider = FutureProvider<List<dynamic>>((ref) async {
  final authState = ref.watch(authProvider);
  if (authState.patientId == null) return [];
  
  final repo = ref.read(patientRepositoryProvider);
  return repo.getChatSummaries(authState.patientId!);
});
