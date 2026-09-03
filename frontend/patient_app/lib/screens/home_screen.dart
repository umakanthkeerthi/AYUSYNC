import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/sos_button.dart';
import '../providers/patient_providers.dart';
import '../models/patient_models.dart';

import 'profile_screen.dart';
import 'vitals_checkin_screen.dart';
import 'chat_screen.dart';
import 'upload_record_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientProfileAsync = ref.watch(patientProfileProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final planAsync = ref.watch(recoveryPlanProvider(today));

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const UploadRecordScreen()));
        },
        backgroundColor: AppTheme.primaryOrange,
        icon: const Icon(LucideIcons.camera, color: Colors.white),
        label: const Text('Scan Record', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF0E6), AppTheme.backgroundLight],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              _buildHeader(context, patientProfileAsync).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
              const SizedBox(height: 32),
              planAsync.when(
                data: (planData) {
                  if (planData == null) return const SizedBox.shrink();
                  final carePlan = planData['care_plan'];
                  final progressPercent = carePlan['progress_percent'] ?? 0;
                  final tasks = planData['today_tasks'] as List<dynamic>;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildRecoveryCard(progressPercent).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.95, 0.95)),
                      const SizedBox(height: 24),
                      const SosButton().animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                      const SizedBox(height: 32),
                      _buildTimelineSection(context, ref, tasks).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1),
                    ]
                  );
                },
                loading: () => const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AppTheme.primaryOrange))),
                error: (e, st) => Center(child: Text('Error: $e')),
              ),
              const SizedBox(height: 120), // Space for floating nav bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AsyncValue<PatientProfile?> patientProfileAsync) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Good morning,',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            patientProfileAsync.when(
              data: (profile) => Row(
                children: [
                  Text(
                    profile?.name ?? 'Guest',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                      letterSpacing: -0.5,
                    ),
                  ).animate().fade(duration: 600.ms).slideY(begin: 0.8, curve: Curves.easeOutBack),
                  const SizedBox(width: 8),
                  const Text('👋', style: TextStyle(fontSize: 20))
                      .animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .moveY(begin: 0, end: -5, duration: 1000.ms)
                      .rotate(begin: 0, end: 0.1),
                ],
              ),
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text(
                'Error: $err',
                style: const TextStyle(color: Colors.red, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primaryOrange, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryOrange.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(
                  'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecoveryCard(int progressPercent) {
    return GlassCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'RECOVERY STATUS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryOrangeDark,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "You're on track",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Keep following your plan',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 75,
                height: 75,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: progressPercent / 100.0),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return CircularProgressIndicator(
                      value: value,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange),
                      strokeCap: StrokeCap.round,
                    );
                  },
                ),
              ),
              Text(
                '$progressPercent%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection(BuildContext context, WidgetRef ref, List<dynamic> tasks) {
    final completedTasks = ref.watch(completedTaskIdsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Today's Plan",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
                letterSpacing: -0.5,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'See all',
                style: TextStyle(
                  color: AppTheme.primaryOrange,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...tasks.map((t) {
            IconData iconData = LucideIcons.clipboard;
            if (t['icon'] == 'pill') iconData = LucideIcons.pill;
            if (t['icon'] == 'messageSquare') iconData = LucideIcons.messageSquare;
            if (t['icon'] == 'activity') iconData = LucideIcons.activity;
            
            final bool isLocallyCompleted = completedTasks.contains(t['id']);
            final bool isCompleted = t['is_completed'] || isLocallyCompleted;
            
            return _buildTimelineItem(
                context: context,
                ref: ref,
                taskId: t['id'],
                time: t['time'],
                title: t['title'],
                subtitle: t['subtitle'],
                icon: iconData,
                isCompleted: isCompleted,
                isActive: t['is_active'] && !isCompleted,
            );
        }),
      ],
    );
  }

  Widget _buildTimelineItem({
    required BuildContext context,
    required WidgetRef ref,
    required String taskId,
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (isCompleted) return; // Do nothing if already completed
            
            if (title == 'Take Medication') {
              ref.read(completedTaskIdsProvider.notifier).update((state) => {...state, taskId});
            } else if (title == 'Check Vitals') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const VitalsCheckinScreen()));
            } else if (title == 'AI Check-in') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatScreen()));
            }
          },
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
                    size: 24,
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
                        style: TextStyle(
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
      ),
    );
  }
}
