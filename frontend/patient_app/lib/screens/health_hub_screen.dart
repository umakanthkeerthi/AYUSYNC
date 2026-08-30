import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

import 'insurance_screen.dart';
import 'medications_screen.dart';
import 'profile_screen.dart';

import 'appointments_screen.dart';
import 'lab_tests_screen.dart';
import 'reports_screen.dart';
import 'chat_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/patient_providers.dart';

class HealthHubScreen extends ConsumerWidget {
  const HealthHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicationsAsync = ref.watch(medicationsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Hub'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell),
            onPressed: () {},
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(24),
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        children: [
          _buildHubCard(
            context,
            LucideIcons.pill,
            'Medications',
            medicationsAsync.when(
              data: (meds) => '${meds.length} active',
              loading: () => '...',
              error: (_, __) => 'Error',
            ),
            Colors.blue,
            destination: const MedicationsScreen(),
          ),
          _buildHubCard(context, LucideIcons.calendarClock, 'Appointments', 'Upcoming at 4pm', Colors.purple, destination: const AppointmentsScreen()),
          _buildHubCard(context, LucideIcons.testTube2, 'Lab Tests', 'Results ready', Colors.teal, destination: const LabTestsScreen()),
          _buildHubCard(context, LucideIcons.shieldCheck, 'Insurance', 'Active Policy', Colors.indigo, destination: const InsuranceScreen()),
          _buildHubCard(context, LucideIcons.fileText, 'Reports', 'View documents', Colors.orange, destination: const ReportsScreen()),
          _buildHubCard(context, LucideIcons.bot, 'AI Chatbot', 'Health Assistant', AppTheme.primaryOrange, destination: const ChatScreen()),
        ].animate(interval: 100.ms).fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9)),
      ),
    );
  }

  Widget _buildHubCard(BuildContext context, IconData icon, String title, String subtitle, Color color, {Widget? destination}) {
    return GestureDetector(
      onTap: () {
        if (destination != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title screen coming soon!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
