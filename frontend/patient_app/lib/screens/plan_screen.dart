import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../providers/patient_providers.dart';

class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final planAsync = ref.watch(recoveryPlanProvider(_selectedDate));

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Recovery Plan'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('AI Check-in feature coming soon!')),
                );
              },
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
      body: planAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange)),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
        data: (planData) {
          if (planData == null) {
            return const Center(child: Text('No plan found.'));
          }

          final carePlan = planData['care_plan'];
          final tasks = planData['today_tasks'] as List<dynamic>;

          return ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              _buildDateStrip().animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
              const SizedBox(height: 24),
              _buildRehabCard(
                title: carePlan['title'] ?? 'Recovery Plan',
                description: carePlan['description'] ?? '',
                progressPercent: carePlan['progress_percent'] ?? 0,
              ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.95, 0.95)),
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
              
              ...tasks.asMap().entries.map((entry) {
                int idx = entry.key;
                var t = entry.value;
                IconData iconData = LucideIcons.clipboard;
                if (t['icon'] == 'pill') iconData = LucideIcons.pill;
                if (t['icon'] == 'messageSquare') iconData = LucideIcons.messageSquare;
                
                return _buildTaskItem(
                  time: t['time'],
                  title: t['title'],
                  subtitle: t['subtitle'],
                  icon: iconData,
                  isCompleted: t['is_completed'],
                  isActive: t['is_active'],
                ).animate().fadeIn(delay: (500 + (idx * 100)).ms).slideX(begin: 0.1);
              }),
              
              const SizedBox(height: 100), // Space for nav bar
            ],
          );
        },
      ),
    );
  }

  Widget _buildDateStrip() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    List<Widget> dateBoxes = [];
    
    for (int i = -2; i <= 2; i++) {
      final date = now.add(Duration(days: i));
      final dateNorm = DateTime(date.year, date.month, date.day);
      
      final dayName = (dateNorm == today) ? 'TODAY' : days[date.weekday - 1];
      final dateNum = date.day.toString();
      
      final isSelected = _selectedDate.year == date.year && 
                         _selectedDate.month == date.month && 
                         _selectedDate.day == date.day;
                         
      dateBoxes.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = dateNorm;
            });
          },
          child: _buildDateBox(dayName, dateNum, isSelected),
        ),
      );
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: dateBoxes,
    );
  }

  Widget _buildDateBox(String day, String date, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryOrange : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isSelected ? null : Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: isSelected
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
              color: isSelected ? Colors.white.withOpacity(0.9) : AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isSelected ? Colors.white : AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRehabCard({required String title, required String description, required int progressPercent}) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppTheme.textDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$progressPercent% Done',
                  style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
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
                widthFactor: (progressPercent / 100.0).clamp(0.0, 1.0),
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
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isCompleted ? 'Task "$title" is already completed.' : 'Marking "$title" as complete...'),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {},
            ),
          ),
        );
      },
      child: Container(
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
      ),
    );
  }
}
