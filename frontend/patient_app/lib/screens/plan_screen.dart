import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Recovery Plan'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(LucideIcons.plus, size: 16, color: AppTheme.primaryOrange),
              label: const Text('Check-in', style: TextStyle(color: AppTheme.primaryOrange)),
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange.withOpacity(0.1),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildDateStrip().animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
          const SizedBox(height: 24),
          _buildRehabCard().animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.95, 0.95)),
          const SizedBox(height: 24),
          const Text(
            'Scheduled Today',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
              letterSpacing: -0.5,
            ),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 16),
          _buildTaskItem(
            time: '8:00 AM',
            title: 'Take Medication',
            subtitle: 'Ecosprin 75mg',
            icon: LucideIcons.pill,
            isCompleted: true,
          ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1),
          _buildTaskItem(
            time: '10:30 AM',
            title: 'AI Check-in',
            subtitle: 'Daily symptom log',
            icon: LucideIcons.messageSquare,
            isCompleted: false,
            isActive: true,
          ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1),
          _buildTaskItem(
            time: '2:00 PM',
            title: 'Sync Vitals',
            subtitle: 'Heart Rate & BP',
            icon: LucideIcons.activity,
            isCompleted: false,
          ).animate().fadeIn(delay: 700.ms).slideX(begin: 0.1),
          const SizedBox(height: 100), // Space for nav bar
        ],
      ),
    );
  }

  Widget _buildDateStrip() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDateBox('MON', '18', false),
        _buildDateBox('TUE', '19', false),
        _buildDateBox('TODAY', '20', true),
        _buildDateBox('THU', '21', false),
        _buildDateBox('FRI', '22', false),
      ],
    );
  }

  Widget _buildDateBox(String day, String date, bool isToday) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isToday ? AppTheme.primaryOrange : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isToday ? null : Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: isToday
            ? [BoxShadow(color: AppTheme.primaryOrange.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
            : [],
      ),
      child: Column(
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isToday ? Colors.white.withOpacity(0.9) : AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isToday ? Colors.white : AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRehabCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Post-Op Cardiac Rehab',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppTheme.textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '85% Done',
                  style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Doctor prescribed 14-day recovery protocol. 3 days remaining.',
            style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: 0.85,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem({
    required String time,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isCompleted,
    bool isActive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isActive ? Border.all(color: AppTheme.primaryOrange, width: 1.5) : Border.all(color: Colors.transparent, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green.withOpacity(0.1)
                    : (isActive ? AppTheme.primaryOrange.withOpacity(0.1) : AppTheme.backgroundLight),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isCompleted ? LucideIcons.checkCircle2 : icon,
                color: isCompleted
                    ? Colors.green
                    : (isActive ? AppTheme.primaryOrange : AppTheme.textMuted),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: isCompleted ? AppTheme.textMuted : AppTheme.textDark,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              time,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: isActive ? AppTheme.primaryOrange : AppTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
