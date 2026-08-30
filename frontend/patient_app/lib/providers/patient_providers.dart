import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/patient_models.dart';
import '../repositories/patient_repository.dart';

// 1. Repository Provider
final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  return PatientRepository();
});

// 2. Auth Provider (Mocking Ramesh Gupta's Login Session)
class AuthState {
  final String? patientId;
  final bool isAuthenticated;

  AuthState({this.patientId, this.isAuthenticated = false});
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState(
    // HARDCODED UUID from our seeded database (Ramesh Gupta)
    patientId: '56974909-8834-4fbd-a738-28266e9f3a62',
    isAuthenticated: true,
  ));

  void logout() {
    state = AuthState(isAuthenticated: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
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
