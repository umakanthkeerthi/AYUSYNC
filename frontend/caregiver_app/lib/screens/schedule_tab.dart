import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../utils/theme.dart';

class ScheduleTab extends StatelessWidget {
  const ScheduleTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            children: [
              _buildTimelineItem(
                title: 'Verify Morning Dose',
                subtitle: 'Rahul confirmed dose taken at 8:05 AM.',
                time: '08:00 AM',
                icon: LucideIcons.checkCircle,
                color: AyuTheme.green,
                isCompleted: true,
                isLast: false,
              ),
              _buildTimelineItem(
                title: 'Confirm Transport',
                subtitle: 'Pending action for 10:00 AM Blood Test tomorrow.',
                time: '10:00 AM',
                icon: LucideIcons.car,
                color: AyuTheme.amber,
                isCompleted: false,
                isLast: false,
                isActionable: true,
              ),
              _buildTimelineItem(
                title: 'Afternoon Check-in',
                subtitle: 'Scheduled call with patient.',
                time: '02:00 PM',
                icon: LucideIcons.phoneCall,
                color: AyuTheme.textMuted,
                isCompleted: false,
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 24),
      decoration: const BoxDecoration(
        color: AyuTheme.surface,
        boxShadow: [BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: const Text(
        'Duty Schedule',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          fontFamily: 'Outfit',
          color: AyuTheme.textMain,
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    required Color color,
    required bool isCompleted,
    required bool isLast,
    bool isActionable = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isCompleted || isActionable ? color.withOpacity(0.15) : AyuTheme.border,
                  shape: BoxShape.circle,
                  border: isActionable ? Border.all(color: color, width: 2) : null,
                ),
                child: Icon(icon, color: isCompleted || isActionable ? color : AyuTheme.textMuted, size: 20),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted ? AyuTheme.green.withOpacity(0.3) : AyuTheme.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AyuTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AyuTheme.softShadow,
                  border: isActionable ? Border.all(color: color.withOpacity(0.3)) : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(time, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isCompleted || isActionable ? color : AyuTheme.textMuted)),
                        if (isCompleted)
                          const Icon(LucideIcons.checkCircle2, color: AyuTheme.green, size: 16),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AyuTheme.textMain)),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: AyuTheme.textMuted, height: 1.4),
                    ),
                    if (isActionable) ...[
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color.withOpacity(0.1),
                          foregroundColor: color,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        child: const Text('Take Action', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
