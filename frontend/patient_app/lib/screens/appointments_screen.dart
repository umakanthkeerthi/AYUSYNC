import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('My Appointments'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildUpcomingSection().animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
          const SizedBox(height: 32),
          _buildPastSection().animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
        ],
      ),
    );
  }

  Widget _buildUpcomingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Upcoming',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Book New',
                style: TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildAppointmentCard(
          doctor: 'Dr. Ramesh Kumar',
          specialty: 'Cardiologist',
          date: 'Today, 4:00 PM',
          mode: 'Video Consultation',
          isUpcoming: true,
          iconColor: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildPastSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Past Appointments',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 16),
        _buildAppointmentCard(
          doctor: 'Dr. Anjali Desai',
          specialty: 'General Physician',
          date: 'Aug 10, 10:30 AM',
          mode: 'In-person Visit',
          isUpcoming: false,
          iconColor: Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildAppointmentCard(
          doctor: 'Dr. Ramesh Kumar',
          specialty: 'Cardiologist',
          date: 'Jul 22, 2:15 PM',
          mode: 'In-person Visit',
          isUpcoming: false,
          iconColor: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildAppointmentCard({
    required String doctor,
    required String specialty,
    required String date,
    required String mode,
    required bool isUpcoming,
    required Color iconColor,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(LucideIcons.stethoscope, color: iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      specialty,
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.calendarClock, size: 16, color: AppTheme.textDark),
                    const SizedBox(width: 8),
                    Text(date, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      mode.contains('Video') ? LucideIcons.video : LucideIcons.mapPin,
                      size: 16,
                      color: AppTheme.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(mode, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          if (isUpcoming) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textDark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Reschedule'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryOrange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Join Call'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
