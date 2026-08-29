import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/intervention_card.dart';
import 'package:responsive_builder/responsive_builder.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                children: const [
                  _MetricCard(value: '248', label: 'Total Patients', valueColor: AppTheme.textDark),
                  _MetricCard(value: '214', label: 'Stable', valueColor: AppTheme.colorSuccess, labelColor: AppTheme.colorSuccess),
                  _MetricCard(value: '27', label: 'Monitoring', valueColor: AppTheme.colorWarning, labelColor: AppTheme.colorWarning),
                  _MetricCard(value: '7', label: 'Need Intervention', valueColor: AppTheme.colorDanger, isDangerBadge: true),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          const Text('Needs Your Intervention', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return const InterventionCard();
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


