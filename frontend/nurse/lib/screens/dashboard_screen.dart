import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveBuilder(
            builder: (context, sizingInformation) {
              bool isMobile = sizingInformation.isMobile || sizingInformation.isTablet;
              
              if (isMobile) {
                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: sizingInformation.isMobile ? 1.2 : 1.5,
                  children: const [
                    _MetricCard(title: 'Urgent', value: '3', subtitle: 'Needs attention', color: AppTheme.colorUrgent, isActive: false),
                    _MetricCard(title: 'Follow-up', value: '8', subtitle: 'Pending tasks', color: AppTheme.colorFollowup, isActive: false),
                    _MetricCard(title: 'On Track', value: '24', subtitle: 'Doing well', color: AppTheme.colorOnTrack, isActive: false),
                    _MetricCard(title: 'Total Patients', value: '35', subtitle: 'Under care', color: AppTheme.colorTotal, isActive: true),
                  ],
                );
              }

              return const Row(
                children: [
                  Expanded(child: _MetricCard(title: 'Urgent', value: '3', subtitle: 'Needs attention', color: AppTheme.colorUrgent, isActive: false)),
                  SizedBox(width: 16),
                  Expanded(child: _MetricCard(title: 'Follow-up', value: '8', subtitle: 'Pending tasks', color: AppTheme.colorFollowup, isActive: false)),
                  SizedBox(width: 16),
                  Expanded(child: _MetricCard(title: 'On Track', value: '24', subtitle: 'Doing well', color: AppTheme.colorOnTrack, isActive: false)),
                  SizedBox(width: 16),
                  Expanded(child: _MetricCard(title: 'Total Patients', value: '35', subtitle: 'Under care', color: AppTheme.colorTotal, isActive: true)),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      const Text('Patient Queue', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: 250,
                            height: 40,
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search patients, tasks...',
                                prefixIcon: const Icon(Icons.search, size: 20),
                                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.filter_list, size: 18),
                            label: const Text('Filter'),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                const Divider(height: 1),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    bool isUrgent = index == 0;
                    return _PatientQueueRow(isUrgent: isUrgent);
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final bool isActive;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isActive ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isActive ? color : AppTheme.borderColor,
          width: isActive ? 2 : 1,
        ),
      ),
      color: isActive ? color.withOpacity(0.05) : AppTheme.bgCard,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color, height: 1)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _PatientQueueRow extends StatelessWidget {
  final bool isUrgent;
  
  const _PatientQueueRow({required this.isUrgent});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.borderColor,
                    child: Icon(Icons.person, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Sarah Jenkins', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        const Text('Room 302 • Post-op Care', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.schedule, size: 14, color: AppTheme.textSecondary),
                            const SizedBox(width: 4),
                            const Expanded(child: Text('Check vitals in 30 mins', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12), overflow: TextOverflow.ellipsis)),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                if (isUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Urgent', style: TextStyle(color: AppTheme.colorUrgent, fontSize: 12, fontWeight: FontWeight.bold)),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Follow-up', style: TextStyle(color: AppTheme.colorFollowup, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                const SizedBox(width: 16),
                const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
              ],
            )
          ],
        ),
      ),
    );
  }
}
