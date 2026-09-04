import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../providers/patient_providers.dart';
import '../models/patient_models.dart';
import '../theme/app_theme.dart';
import 'prescription_report_screen.dart';

class PrescriptionsListScreen extends ConsumerWidget {
  const PrescriptionsListScreen({super.key});

  // Orange shades from the brand palette
  static const List<Color> _cardColors = [
    AppTheme.primaryOrange,
    AppTheme.primaryOrangeDark,
    AppTheme.primaryOrangeLight,
    AppTheme.primaryOrange,
    AppTheme.primaryOrangeDark,
    AppTheme.primaryOrangeLight,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicationsAsync = ref.watch(medicationsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Prescriptions',
          style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.textDark),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // View all as one document
          TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const PrescriptionReportScreen(),
                transitionsBuilder: (_, anim, __, child) =>
                    FadeTransition(opacity: anim, child: child),
                transitionDuration: const Duration(milliseconds: 400),
              ),
            ),
            icon: Icon(LucideIcons.fileText, size: 16, color: AppTheme.primaryOrange),
            label: const Text(
              'Full Report',
              style: TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: medicationsAsync.when(
        data: (meds) {
          if (meds.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.fileX, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'No prescriptions found.',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 16),
                  ),
                ],
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            children: [
              // Summary banner
              _buildSummaryBanner(meds.length)
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.1),
              const SizedBox(height: 24),

              const Text(
                'Your Prescriptions',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textMuted,
                  letterSpacing: 0.5,
                ),
              ).animate().fadeIn(delay: 150.ms),
              const SizedBox(height: 12),

              // One card per medication
              ...meds.asMap().entries.map((entry) {
                final index = entry.key;
                final med = entry.value;
                final color = _cardColors[index % _cardColors.length];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildPrescriptionCard(
                    context: context,
                    med: med,
                    index: index,
                    color: color,
                    allMeds: meds,
                  )
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: 200 + index * 80))
                      .slideY(begin: 0.08),
                );
              }),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildSummaryBanner(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryOrange, AppTheme.primaryOrangeLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryOrange.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.clipboardList, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count Active Prescription${count != 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Prescribed by Dr. Uma Kanth',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Rx No.',
                style: TextStyle(color: Colors.white60, fontSize: 11),
              ),
              const Text(
                'AYU-RX-8472',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionCard({
    required BuildContext context,
    required Medication med,
    required int index,
    required Color color,
    required List<Medication> allMeds,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => PrescriptionReportScreen(
            singleMedication: med,
          ),
          transitionsBuilder: (_, anim, __, child) =>
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
                child: child,
              ),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Colored top strip
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(LucideIcons.pill, color: color, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              med.name,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              med.dosage,
                              style: TextStyle(
                                fontSize: 13,
                                color: color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Active',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _buildInfoChip(LucideIcons.repeat, med.frequency, color),
                      const SizedBox(width: 12),
                      _buildInfoChip(LucideIcons.userCheck, 'Dr. Uma Kanth', Colors.grey),
                      const Spacer(),
                      Row(
                        children: [
                          Text(
                            'View Rx',
                            style: TextStyle(
                              color: color,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(LucideIcons.chevronRight, color: color, size: 16),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
