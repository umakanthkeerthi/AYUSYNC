import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../providers/patient_providers.dart';

class DischargeSummaryScreen extends ConsumerWidget {
  /// If provided, displays this specific summary's content.
  /// If null, shows a default/static discharge summary.
  final Map<String, dynamic>? singleSummary;

  const DischargeSummaryScreen({super.key, this.singleSummary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(patientProfileProvider);

    return Scaffold(
      backgroundColor: Colors.grey[200], // Background behind paper
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Discharge Summary', style: TextStyle(color: Colors.black87, fontSize: 16)),
        elevation: 1,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.printer, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(LucideIcons.share2, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800, minHeight: 1000),
            decoration: BoxDecoration(
              color: const Color(0xFFFEFAf7), // Warm off-white
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
              ],
            ),
            child: Stack(
              children: [
                // Watermark
                Positioned.fill(
                  child: Center(
                    child: Opacity(
                      opacity: 0.03, // Very faint
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(LucideIcons.heartPulse, size: 200, color: Color(0xFFE85A2A)),
                          Text(
                            'AyuSync',
                            style: TextStyle(fontSize: 80, fontWeight: FontWeight.w800, color: Color(0xFFE85A2A)),
                          ),
                          Text(
                            'CONNECTING EVERY STEP OF CARE',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFFE85A2A), letterSpacing: 4),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildPatientDetails(profileAsync),
                      const SizedBox(height: 32),
                      _buildContentSection(singleSummary),
                      const SizedBox(height: 120), // Spacer before footer
                      _buildFooter(),
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

  Widget _buildHeader() {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.heartPulse, color: Color(0xFFE85A2A), size: 40),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'AyuSync',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFE85A2A),
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'CONNECTING EVERY STEP OF CARE',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                    color: Color(0xFFD49B86),
                  ),
                ),
              ],
            ),
          ],
        ),
        const Text(
          'DISCHARGE SUMMARY',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFFE85A2A),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPatientDetails(AsyncValue profileAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PATIENT DETAILS',
          style: TextStyle(color: Color(0xFFE85A2A), fontWeight: FontWeight.w700, fontSize: 14),
        ),
        const Divider(color: Color(0xFFE85A2A), thickness: 1, height: 16),
        const SizedBox(height: 8),
        profileAsync.when(
          data: (profile) {
            if (profile == null) return const Text('Loading...');
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDetailRow(LucideIcons.user, 'Name', profile.name),
                const SizedBox(height: 12),
                _buildDetailRow(LucideIcons.calendar, 'Age', '34'),
                const SizedBox(height: 12),
                _buildDetailRow(LucideIcons.users, 'Gender', 'Female'),
                const SizedBox(height: 12),
                _buildDetailRow(LucideIcons.fileText, 'Admit No.', 'AYU-ADM-112'),
                const SizedBox(height: 12),
                _buildDetailRow(LucideIcons.calendarClock, 'Date', DateTime.now().toString().split(' ')[0]),
                const SizedBox(height: 12),
                _buildDetailRow(LucideIcons.userCheck, 'Attending', 'Dr. Uma Kanth'),
              ],
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (e, s) => Text('Error: $e'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFFE85A2A)),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ),
        const Text(' : ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black26)),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 2.0),
              child: Text(
                value,
                style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection([Map<String, dynamic>? summary]) {
    final date = summary?['date'] ?? DateTime.now().toString().split(' ')[0];
    final content = summary?['content_text'] ??
        'The patient was admitted with complaints of severe migraine unresponsive to outpatient management. '
        'Intravenous fluids and acute migraine protocols were initiated immediately upon admission. '
        'Over the course of 48 hours, the patient showed significant improvement.';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CLINICAL COURSE',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFFE85A2A),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          content,
          style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
        ),
        const SizedBox(height: 24),
        const Text(
          'DISCHARGE INSTRUCTIONS',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFFE85A2A),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '1. Continue prescribed oral medications as directed.\n2. Follow up with Dr. Uma Kanth in 7 days.\n3. Return to the ER immediately if symptoms worsen or vision changes occur.',
          style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 200, height: 1, color: Colors.black54),
        const SizedBox(height: 8),
        const Text('Attending Physician Signature', style: TextStyle(color: Color(0xFFE85A2A), fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF5F0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(LucideIcons.fileText, color: Color(0xFFE85A2A), size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'This is a computer generated discharge summary. No signature is required.',
                      style: TextStyle(fontSize: 11, color: Colors.black87),
                    ),
                    Text(
                      'For medical records requests, please contact the hospital administration.',
                      style: TextStyle(fontSize: 11, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
