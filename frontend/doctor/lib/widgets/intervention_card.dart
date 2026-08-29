import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../theme/app_theme.dart';

class InterventionCard extends StatelessWidget {
  const InterventionCard({Key? key}) : super(key: key);

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
                      const Text('Sarah Jenkins', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text('ID: P-8472 • 68 yrs • Female', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      const SizedBox(height: 12),
                      const Text('Recent Changes:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.colorDanger, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          const Text('Missed Lisinopril for 2 days', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.colorDanger, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          const Text('BP elevated to 150/95', style: TextStyle(fontSize: 13)),
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
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 8, color: AppTheme.colorDanger),
                      SizedBox(width: 6),
                      Text('High Risk', style: TextStyle(color: AppTheme.colorDanger, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                SizedBox(height: isMobile ? 16 : 24),
                const Text('RISK SCORE', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                const Text('85', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: isMobile ? 16 : 0),
                if (isMobile)
                  ElevatedButton(onPressed: () {}, child: const Text('Review Case'))
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
                  child: ElevatedButton(onPressed: () {}, child: const Text('Review Case')),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
