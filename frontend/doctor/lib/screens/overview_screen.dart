import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../widgets/intervention_card.dart';
import '../providers/auth_provider.dart';
import 'package:responsive_builder/responsive_builder.dart';

class OverviewScreen extends ConsumerStatefulWidget {
  const OverviewScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends ConsumerState<OverviewScreen> {
  List<dynamic> _patients = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    // Use Future.microtask to allow reading provider after init
    Future.microtask(() => _fetchOverviewData());
  }

  Future<void> _fetchOverviewData() async {
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
            _patients = data['roster'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = data['message'] ?? 'Failed to fetch patients';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Server error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error connecting to server: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(child: Text(_error, style: const TextStyle(color: Colors.red, fontSize: 16)));
    }

    int totalPatients = _patients.length;
    int stable = _patients.where((p) => p['status'] == 'Stable').length;
    int monitoring = _patients.where((p) => p['status'] == 'Monitoring').length;
    int needIntervention = _patients.where((p) => p['status'] == 'Need Intervention').length;

    List<dynamic> highRiskPatients = _patients.where((p) => p['isHighRisk'] == true).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Patient Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ResponsiveBuilder(
            builder: (context, sizingInformation) {
              int crossAxisCount = sizingInformation.deviceScreenType == DeviceScreenType.mobile ? 2 : 4;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.5,
                children: [
                  _MetricCard(value: totalPatients.toString(), label: 'Total Patients', valueColor: AppTheme.textDark),
                  _MetricCard(value: stable.toString(), label: 'Stable', valueColor: AppTheme.colorSuccess, labelColor: AppTheme.colorSuccess),
                  _MetricCard(value: monitoring.toString(), label: 'Monitoring', valueColor: AppTheme.colorWarning, labelColor: AppTheme.colorWarning),
                  _MetricCard(value: needIntervention.toString(), label: 'Need Intervention', valueColor: AppTheme.colorDanger, isDangerBadge: true),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          const Text('Needs Your Intervention', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          highRiskPatients.isEmpty
              ? const Center(child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('No patients need immediate intervention.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
                ))
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: highRiskPatients.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final p = highRiskPatients[index];
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

class _MetricCard extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;
  final Color? labelColor;
  final bool isDangerBadge;

  const _MetricCard({
    required this.value,
    required this.label,
    required this.valueColor,
    this.labelColor,
    this.isDangerBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isDangerBadge)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.colorDanger, width: 2),
              ),
              alignment: Alignment.center,
              child: Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: valueColor)),
            )
          else
            Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: valueColor)),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: labelColor ?? AppTheme.textSecondary)),
        ],
      ),
    );
  }
}


