import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../providers/patient_providers.dart';

class PrescriptionReportScreen extends ConsumerWidget {
  /// If provided, shows only this single medication in the Rx document.
  /// If null, shows all active medications (full report).
  final dynamic singleMedication;

  const PrescriptionReportScreen({super.key, this.singleMedication});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicationsAsync = ref.watch(medicationsProvider);
    final profileAsync = ref.watch(patientProfileProvider);

    return Scaffold(
      backgroundColor: Colors.grey[200], // Background behind paper
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Prescription', style: TextStyle(color: Colors.black87, fontSize: 16)),
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
                      _buildRxSection(medicationsAsync),
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
            Icon(LucideIcons.heartPulse, color: Color(0xFFE85A2A), size: 48),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'AyuSync',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFE85A2A),
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'CONNECTING EVERY STEP OF CARE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    color: Color(0xFFD49B86),
                  ),
                ),
              ],
            ),
          ],
        ),
        const Text(
          'PRESCRIPTION',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFFE85A2A),
            letterSpacing: 1,
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
                _buildDetailRow(LucideIcons.droplet, 'Blood Group', profile.bloodType ?? 'O+'),
                const SizedBox(height: 12),
                _buildDetailRow(LucideIcons.scale, 'Weight', '68 kg'),
                const SizedBox(height: 12),
                _buildDetailRow(LucideIcons.arrowUpDown, 'Height', '165 cm'),
                const SizedBox(height: 12),
                _buildDetailRow(LucideIcons.fileText, 'Rx No.', 'AYU-RX-8472'),
                const SizedBox(height: 12),
                _buildDetailRow(LucideIcons.calendarClock, 'Date', DateTime.now().toString().split(' ')[0]),
                const SizedBox(height: 12),
                _buildDetailRow(LucideIcons.userCheck, 'Doctor', 'Dr. Uma Kanth'),
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
          width: 75,
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ),
        const Text(' : ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black26)),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 2.0),
              child: Text(
                value,
                style: const TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRxSection(AsyncValue medicationsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rx Symbol (Since we don't have a perfect Rx icon in lucide, we'll use a styled text)
        const Text(
          'Rx',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 48,
            fontWeight: FontWeight.w600,
            color: Color(0xFFE85A2A),
          ),
        ),
        const SizedBox(height: 24),
        medicationsAsync.when(
          data: (allMeds) {
            // If a specific med was passed, show only that one
            final meds = singleMedication != null ? [singleMedication] : allMeds;
            if (meds == null || (meds as List).isEmpty) {
              return const Text('No active medications prescribed.', style: TextStyle(color: Colors.black54));
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (meds as List).asMap().entries.map((entry) {
                int idx = entry.key;
                var med = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24.0, left: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${idx + 1}.', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(med.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text('${med.dosage} — ${med.frequency}', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (e, s) => Text('Error: $e'),
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
        const Text('Doctor\'s Signature', style: TextStyle(color: Color(0xFFE85A2A), fontSize: 14, fontWeight: FontWeight.w600)),
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
                      'This is a computer generated prescription. No signature is required.',
                      style: TextStyle(fontSize: 11, color: Colors.black87),
                    ),
                    Text(
                      'Please consult your physician for any clarifications.',
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
