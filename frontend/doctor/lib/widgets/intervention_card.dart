import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../theme/app_theme.dart';

class InterventionCard extends StatelessWidget {
  final String name;
  final String age;
  final String riskScore;
  final bool isHighRisk;
  final VoidCallback? onReviewCase;

  const InterventionCard({
    Key? key,
    this.name = 'Sarah Jenkins',
    this.age = '68',
    this.riskScore = '85',
    this.isHighRisk = true,
    this.onReviewCase,
  }) : super(key: key);

  void _showReviewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.medical_information, color: AppTheme.brandActive),
            const SizedBox(width: 8),
            Text('Case Review: $name', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Patient: $name (Age $age)', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Risk Score: $riskScore', style: TextStyle(color: isHighRisk ? AppTheme.colorDanger : AppTheme.colorWarning, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Clinical notes and detailed vitals will be loaded here.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Case review for $name started.')),
              );
            },
            child: const Text('Start Review'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ResponsiveBuilder(
          builder: (context, sizingInformation) {
            bool isMobile = sizingInformation.deviceScreenType == DeviceScreenType.mobile;
            
            Widget patientDetails = Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.borderColor,
                  child: Icon(Icons.person, size: 32, color: AppTheme.textSecondary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Age: $age yrs', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      const SizedBox(height: 12),
                      const Text('Recent Changes:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(width: 6, height: 6, decoration: BoxDecoration(color: isHighRisk ? AppTheme.colorDanger : AppTheme.colorWarning, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Text(isHighRisk ? 'Needs medical review' : 'Routine monitoring', style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );

            Widget actionDetails = Column(
              crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isHighRisk ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 8, color: isHighRisk ? AppTheme.colorDanger : AppTheme.colorWarning),
                      const SizedBox(width: 6),
                      Text(isHighRisk ? 'High Risk' : 'Monitoring', style: TextStyle(color: isHighRisk ? AppTheme.colorDanger : AppTheme.colorWarning, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                SizedBox(height: isMobile ? 16 : 24),
                const Text('RISK SCORE', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                Text(riskScore, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: isMobile ? 16 : 0),
                if (isMobile)
                  ElevatedButton(onPressed: onReviewCase ?? () => _showReviewDialog(context), child: const Text('Review Case'))
              ],
            );

            if (isMobile) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  patientDetails,
                  const Divider(height: 32),
                  actionDetails,
                ],
              );
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: patientDetails),
                actionDetails,
                const SizedBox(width: 24),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(onPressed: onReviewCase ?? () => _showReviewDialog(context), child: const Text('Review Case')),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
