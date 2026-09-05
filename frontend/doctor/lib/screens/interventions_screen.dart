import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/app_theme.dart';
import '../widgets/intervention_card.dart';
import '../providers/auth_provider.dart';

class InterventionsScreen extends ConsumerStatefulWidget {
  const InterventionsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<InterventionsScreen> createState() => _InterventionsScreenState();
}

class _InterventionsScreenState extends ConsumerState<InterventionsScreen> {
  List<dynamic> _interventions = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchInterventions());
  }

  Future<void> _fetchInterventions() async {
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
        Uri.parse('http://16.171.226.51/api/v1/doctor/roster?doctor_id=$doctorId'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _interventions = (data['roster'] as List)
                .where((p) => p['status'] == 'Need Intervention' || p['isHighRisk'] == true)
                .toList();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading interventions';
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
          const Text('All Pending Interventions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _interventions.isEmpty
              ? const Center(child: Text('No pending interventions', style: TextStyle(color: AppTheme.textSecondary)))
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _interventions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final p = _interventions[index];
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
