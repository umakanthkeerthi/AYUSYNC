import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../theme/app_theme.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        bool isMobile = sizingInformation.deviceScreenType == DeviceScreenType.mobile;

        Widget board = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildColumn('Pending', AppTheme.colorFollowup, 5)),
            const SizedBox(width: 24),
            Expanded(child: _buildColumn('In Progress', AppTheme.colorTotal, 3)),
            const SizedBox(width: 24),
            Expanded(child: _buildColumn('Completed', AppTheme.colorOnTrack, 12)),
          ],
        );

        if (isMobile) {
          board = SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 300, child: _buildColumn('Pending', AppTheme.colorFollowup, 5)),
                const SizedBox(width: 16),
                SizedBox(width: 300, child: _buildColumn('In Progress', AppTheme.colorTotal, 3)),
                const SizedBox(width: 16),
                SizedBox(width: 300, child: _buildColumn('Completed', AppTheme.colorOnTrack, 12)),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Task Management', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Task'),
                  )
                ],
              ),
              const SizedBox(height: 24),
              board,
            ],
          ),
        );
      },
    );
  }

  Widget _buildColumn(String title, Color badgeColor, int count) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(count.toString(), style: TextStyle(color: badgeColor, fontSize: 12, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const Divider(height: 32),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _TaskCard();
            },
          )
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgMain,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Administer IV Fluids', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('Patient: Sarah Jenkins (Room 302)', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.schedule, size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  const Text('10:30 AM', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
              const Icon(Icons.more_horiz, color: AppTheme.textSecondary, size: 16),
            ],
          )
        ],
      ),
    );
  }
}
