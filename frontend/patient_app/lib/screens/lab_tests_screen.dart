import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../providers/patient_providers.dart';
import 'lab_report_screen.dart'; 

class LabTestsScreen extends ConsumerWidget {
  const LabTestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labsAsync = ref.watch(labTestsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Lab Tests & Results', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppTheme.textDark)),
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: labsAsync.when(
        data: (labs) {
          if (labs == null || labs.isEmpty) {
            return const Center(child: Text('No lab tests found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24.0),
            itemCount: labs.length,
            itemBuilder: (context, index) {
              final lab = labs[index];
              return _buildLabCard(context, lab);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange)),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildLabCard(BuildContext context, dynamic lab) {
    Color statusColor;
    Color statusBg;
    if (lab['status'] == 'Completed') {
      statusColor = AppTheme.textMuted;
      statusBg = Colors.grey.withOpacity(0.1);
    } else if (lab['status'] == 'Results Ready') {
      statusColor = Colors.teal;
      statusBg = Colors.teal.withOpacity(0.1);
    } else {
      statusColor = AppTheme.primaryOrange;
      statusBg = AppTheme.primaryOrange.withOpacity(0.1);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (lab['status'] == 'Processing') ? AppTheme.primaryOrange.withOpacity(0.1) : Colors.teal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.flaskConical, color: (lab['status'] == 'Processing') ? AppTheme.primaryOrange : Colors.teal),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lab['test_name'],
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(LucideIcons.calendar, size: 12, color: AppTheme.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          lab['scheduled_time'],
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  lab['status'],
                  style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
              if (lab['status'] == 'Results Ready' || lab['status'] == 'Completed')
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LabReportScreen(
                          testName: lab['test_name'],
                          date: lab['scheduled_time'],
                          results: lab['results'],
                        ),
                      ),
                    );
                  },
                  icon: const Icon(LucideIcons.download, size: 16, color: AppTheme.primaryOrange),
                  label: const Text('View Report', style: TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.w600)),
                )
            ],
          ),
        ],
      ),
    );
  }
}
