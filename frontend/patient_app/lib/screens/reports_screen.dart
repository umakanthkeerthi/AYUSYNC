import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../providers/patient_providers.dart';
import 'lab_tests_screen.dart';
import 'prescriptions_list_screen.dart';
import 'discharge_summaries_list_screen.dart';
import 'ai_chat_summaries_list_screen.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(reportsSummaryProvider);
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('My Reports'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: summaryAsync.when(
        data: (summary) {
          if (summary == null) return const Center(child: Text('Please log in.'));
          
          final counts = summary['counts'] ?? {};
          final recentDocs = summary['recent_documents'] as List<dynamic>? ?? [];
          
          return ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              _buildReportFolder(
                context: context,
                title: 'Lab Tests & Results',
                count: '${counts['labs'] ?? 0} documents',
                icon: LucideIcons.flaskConical,
                color: Colors.teal,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LabTestsScreen()));
                },
              ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1),
              const SizedBox(height: 16),
              _buildReportFolder(
                context: context,
                title: 'Discharge Summaries',
                count: '${counts['discharge_summaries'] ?? 0} documents',
                icon: LucideIcons.folderHeart,
                color: Colors.red,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const DischargeSummariesListScreen()));
                },
              ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1),
              const SizedBox(height: 16),
              _buildReportFolder(
                context: context,
                title: 'Prescriptions',
                count: '${counts['prescriptions'] ?? 0} documents',
                icon: LucideIcons.fileText,
                color: Colors.blue,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const PrescriptionsListScreen()));
                },
              ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),
              const SizedBox(height: 16),
              _buildReportFolder(
                context: context,
                title: 'Radiology (X-Rays, MRI)',
                count: '${counts['radiology'] ?? 0} documents',
                icon: LucideIcons.scan,
                color: Colors.purple,
                onTap: () {},
              ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1),
              const SizedBox(height: 16),
              _buildReportFolder(
                context: context,
                title: 'AI Chat Summaries',
                count: '${counts['chat_summaries'] ?? 0} summaries',
                icon: LucideIcons.messageSquare,
                color: AppTheme.primaryOrange,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AiChatSummariesListScreen()));
                },
              ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1),
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
              if (recentDocs.isEmpty)
                const Text('No recent documents.')
              else
                ...recentDocs.asMap().entries.map((entry) {
                  int idx = entry.key;
                  var doc = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _buildRecentDocument(doc['title'], doc['date'], doc['meta']).animate().fadeIn(delay: (700 + (idx * 100)).ms),
                  );
                }).toList(),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange)),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildReportFolder({
    required BuildContext context,
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
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
