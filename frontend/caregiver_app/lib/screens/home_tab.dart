import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../utils/theme.dart';
import '../widgets/modals.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AyuTheme.bgApp,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCleanHeader(context),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Overview'),
                    const SizedBox(height: 16),
                    _buildGlanceGrid(),
                    
                    const SizedBox(height: 32),
                    
                    _buildSectionTitle('Action Required'),
                    const SizedBox(height: 16),
                    _buildMinimalAlertCard(context),
                    
                    const SizedBox(height: 32),
                    
                    _buildSectionTitle('Recent Activity'),
                    const SizedBox(height: 16),
                    _buildCleanTimeline(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCleanHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      color: AyuTheme.surface,
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
                    'Assigned Patient',
                    style: TextStyle(
                      color: AyuTheme.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Rahul Kumar',
                    style: TextStyle(
                      color: AyuTheme.textMain,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ],
              ),
              const CircleAvatar(
                radius: 26,
                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AyuTheme.greenBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AyuTheme.green.withOpacity(0.2)),
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
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Updated 10m ago',
                  style: TextStyle(
                    color: AyuTheme.green.withOpacity(0.7),
                    fontSize: 12,
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
        fontSize: 18,
        fontWeight: FontWeight.w700,
        fontFamily: 'Outfit',
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
      ],
    );
  }

  Widget _buildMinimalGlanceCard(IconData icon, String title, String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: AyuTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AyuTheme.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AyuTheme.textMain),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AyuTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AyuTheme.amber.withOpacity(0.5)),
        boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
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
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: const Text('Arrange Transport', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCleanTimeline() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AyuTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AyuTheme.border),
      ),
      child: Column(
        children: [
          _buildCleanTimelineItem(LucideIcons.checkCircle2, 'Medicine taken', '8:05 AM', AyuTheme.green),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AyuTheme.border, height: 1),
          ),
          _buildCleanTimelineItem(LucideIcons.fileText, 'Blood test scheduled', '10:00 AM', AyuTheme.textMain),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AyuTheme.border, height: 1),
          ),
          _buildCleanTimelineItem(LucideIcons.calendar, 'Appointment confirmed', '4:00 PM', AyuTheme.textMain),
        ],
      ),
    );
  }

  Widget _buildCleanTimelineItem(IconData icon, String title, String time, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AyuTheme.textMain),
          ),
        ),
        Text(time, style: const TextStyle(fontSize: 12, color: AyuTheme.textMuted)),
      ],
    );
  }
}
