import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('My Reports'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildReportFolder(
            title: 'Discharge Summaries',
            count: '2 documents',
            icon: LucideIcons.folderHeart,
            color: Colors.red,
          ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1),
          const SizedBox(height: 16),
          _buildReportFolder(
            title: 'Prescriptions',
            count: '14 documents',
            icon: LucideIcons.fileText,
            color: Colors.blue,
          ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),
          const SizedBox(height: 16),
          _buildReportFolder(
            title: 'Radiology (X-Rays, MRI)',
            count: '3 documents',
            icon: LucideIcons.scan,
            color: Colors.purple,
          ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1),
          const SizedBox(height: 32),
          const Text(
            'Recent Documents',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ).animate().fadeIn(delay: 600.ms),
          const SizedBox(height: 16),
          _buildRecentDocument('Apollo Discharge Summary', 'Aug 14, 2026', 'PDF • 1.2 MB').animate().fadeIn(delay: 700.ms),
          const SizedBox(height: 8),
          _buildRecentDocument('Dr. Ramesh Prescription', 'Aug 10, 2026', 'PDF • 450 KB').animate().fadeIn(delay: 800.ms),
        ],
      ),
    );
  }

  Widget _buildReportFolder({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.textDark),
                ),
                const SizedBox(height: 4),
                Text(
                  count,
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(LucideIcons.chevronRight, color: AppTheme.textMuted),
        ],
      ),
    );
  }

  Widget _buildRecentDocument(String title, String date, String meta) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.fileText, color: AppTheme.primaryOrange, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text('$date • $meta', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.download, size: 18, color: AppTheme.textMuted),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
