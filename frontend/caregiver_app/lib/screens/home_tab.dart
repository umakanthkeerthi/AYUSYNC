import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../utils/theme.dart';
import '../widgets/modals.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/glass_card.dart';
import 'profile_tab.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0FDFA), AyuTheme.bgApp],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCleanHeader(context).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Overview').animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 16),
                      _buildGlanceGrid(),
                      
                      const SizedBox(height: 32),
                      
                      _buildSectionTitle('Action Required').animate().fadeIn(delay: 400.ms),
                      const SizedBox(height: 16),
                      _buildMinimalAlertCard(context).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                      
                      const SizedBox(height: 32),
                      
                      _buildSectionTitle('Recent Activity').animate().fadeIn(delay: 600.ms),
                      const SizedBox(height: 16),
                      _buildCleanTimeline().animate().fadeIn(delay: 700.ms).slideX(begin: 0.1),
                      const SizedBox(height: 120), // Space for floating nav bar
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCleanHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Caring For',
                    style: TextStyle(
                      color: AyuTheme.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Rahul Kumar',
                    style: TextStyle(
                      color: AyuTheme.textMain,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileTab()),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AyuTheme.primary, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AyuTheme.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 26,
                    backgroundImage: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AyuTheme.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AyuTheme.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AyuTheme.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Vitals Stable',
                  style: TextStyle(
                    color: AyuTheme.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Updated 10m ago',
                  style: TextStyle(
                    color: AyuTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AyuTheme.textMain,
      ),
    );
  }

  Widget _buildGlanceGrid() {
    return Row(
      children: [
        Expanded(child: _buildMinimalGlanceCard(LucideIcons.pill, 'Medication', 'Done', AyuTheme.green)),
        const SizedBox(width: 12),
        Expanded(child: _buildMinimalGlanceCard(LucideIcons.droplet, 'Blood Test', 'Tomorrow', AyuTheme.amber)),
        const SizedBox(width: 12),
        Expanded(child: _buildMinimalGlanceCard(LucideIcons.calendar, 'Checkup', '4:00 PM', AyuTheme.primary)),
      ].animate(interval: 100.ms).fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9)),
    );
  }

  Widget _buildMinimalGlanceCard(IconData icon, String title, String status, Color color) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AyuTheme.textMain),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            status,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalAlertCard(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      color: AyuTheme.primary.withOpacity(0.12),
      borderColor: AyuTheme.primary.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AyuTheme.amberBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.alertTriangle, color: AyuTheme.amber, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Transport unconfirmed for tomorrow's lab visit.",
                  style: TextStyle(
                    color: AyuTheme.textMain,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const TransportModal(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AyuTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Arrange Transport', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCleanTimeline() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCleanTimelineItem(LucideIcons.checkCircle2, 'Medicine taken', '8:05 AM', AyuTheme.green),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: AyuTheme.border.withOpacity(0.5), height: 1),
          ),
          _buildCleanTimelineItem(LucideIcons.fileText, 'Blood test scheduled', '10:00 AM', AyuTheme.textMain),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: AyuTheme.border.withOpacity(0.5), height: 1),
          ),
          _buildCleanTimelineItem(LucideIcons.calendarClock, 'Appointment confirmed', '4:00 PM', AyuTheme.primary),
        ],
      ),
    );
  }

  Widget _buildCleanTimelineItem(IconData icon, String title, String time, Color iconColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AyuTheme.textMain),
          ),
        ),
        Text(time, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AyuTheme.textMuted)),
      ],
    );
  }
}
