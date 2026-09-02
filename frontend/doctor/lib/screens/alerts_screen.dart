import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/app_theme.dart';
import '../widgets/intervention_card.dart';
import '../providers/auth_provider.dart';

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  List<dynamic> _alerts = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchAlerts());
  }

  Future<void> _fetchAlerts() async {
    final doctorId = ref.read(authProvider).doctorId;
    if (doctorId == null) {
      setState(() {
        _error = 'Not authenticated';
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/v1/doctor/roster?doctor_id=$doctorId'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _alerts = (data['roster'] as List)
                .where((p) => p['status'] == 'Need Intervention' || p['isHighRisk'] == true)
                .toList();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading alerts';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error.isNotEmpty) return Center(child: Text(_error));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Alerts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _alerts.isEmpty
              ? const Center(child: Text('No active alerts', style: TextStyle(color: AppTheme.textSecondary)))
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _alerts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final p = _alerts[index];
                    return InterventionCard(
                      name: p['name'] ?? 'Unknown',
                      age: p['age']?.toString() ?? 'Unknown',
                      riskScore: p['risk_score']?.toString() ?? '0',
                      isHighRisk: p['isHighRisk'] ?? false,
                      onReviewCase: () => context.push('/case-review/${p['patient_id']}'),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
