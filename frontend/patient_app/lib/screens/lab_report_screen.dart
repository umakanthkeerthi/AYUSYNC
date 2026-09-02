import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';

class LabReportScreen extends StatelessWidget {
  final String testName;
  final String date;
  final List<dynamic>? results;

  const LabReportScreen({
    super.key,
    required this.testName,
    required this.date,
    this.results,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Background behind the paper
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Lab Report', style: TextStyle(color: Colors.black87, fontSize: 16)),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.printer, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(LucideIcons.share2, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            decoration: BoxDecoration(
              color: const Color(0xFFFEFAf7), // Slight warm off-white like the image
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
              ],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildSectionHeader(LucideIcons.user, 'PATIENT DETAILS'),
                  _buildPatientDetailsBox(),
                  const SizedBox(height: 32),
                  _buildSectionHeader(LucideIcons.flaskConical, 'INVESTIGATIONS'),
                  _buildInvestigationsTable(),
                  const SizedBox(height: 48),
                  _buildRemarksAndSignature(),
                  const SizedBox(height: 32),
                  const Divider(color: Color(0xFFFFD8C4), thickness: 2),
                  _buildBottomBar(),
                ],
              ),
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
            const Icon(LucideIcons.heartPulse, color: Color(0xFFE85A2A), size: 40),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'AyuSync LAB',
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
        Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(LucideIcons.activity, color: Color(0xFFE85A2A), size: 28),
            SizedBox(width: 8),
            Icon(LucideIcons.microscope, color: Color(0xFFE85A2A), size: 28),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFF18C62),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientDetailsBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFFFD8C4)),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
          topRight: Radius.circular(8), // Since the header is small
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDetailRow(LucideIcons.user, 'Name', 'Swathi Reddy'),
          const SizedBox(height: 8),
          _buildDetailRow(LucideIcons.calendar, 'Age', '34'),
          const SizedBox(height: 8),
          _buildDetailRow(LucideIcons.droplet, 'Blood Group', 'O+'),
          const SizedBox(height: 8),
          _buildDetailRow(LucideIcons.arrowUpDown, 'Height', '165 cm'),
          const SizedBox(height: 8),
          _buildDetailRow(LucideIcons.testTube2, 'Lab No.', 'AYU-L-8821'),
          const SizedBox(height: 8),
          _buildDetailRow(LucideIcons.calendarClock, 'Date', date.split(' - ')[0]),
          const SizedBox(height: 8),
          _buildDetailRow(LucideIcons.users, 'Gender', 'Female'),
          const SizedBox(height: 8),
          _buildDetailRow(LucideIcons.userCheck, 'Ref. By', 'Dr. Uma Kanth'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFE85A2A)),
          const SizedBox(width: 6),
          SizedBox(
            width: 85,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ),
          const Text(' : ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestigationsTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFFFD8C4)),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFFFEAE0),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: const [
                SizedBox(width: 40, child: Text('No.', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13), textAlign: TextAlign.center)),
                Expanded(flex: 3, child: Text('Test Name', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                Expanded(flex: 2, child: Text('Result', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13), textAlign: TextAlign.center)),
                Expanded(flex: 2, child: Text('Unit', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13), textAlign: TextAlign.center)),
                Expanded(flex: 2, child: Text('Reference Range', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13), textAlign: TextAlign.center)),
              ],
            ),
          ),
          
          if (results == null || results!.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('Results are processing...'),
            )
          else
            ...results!.asMap().entries.map((entry) {
              int idx = entry.key;
              var row = entry.value;
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                color: idx % 2 == 1 ? const Color(0xFFFFF5F0) : Colors.transparent,
                child: Row(
                  children: [
                    SizedBox(width: 40, child: Text('${idx + 1}', style: const TextStyle(fontSize: 13), textAlign: TextAlign.center)),
                    Expanded(flex: 3, child: Text(row['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                    Expanded(
                      flex: 2,
                      child: Text(
                        row['result'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(flex: 2, child: Text(row['unit'] ?? '', style: const TextStyle(fontSize: 13, color: Colors.black54), textAlign: TextAlign.center)),
                    Expanded(flex: 2, child: Text(row['range'] ?? '', style: const TextStyle(fontSize: 13, color: Colors.black54), textAlign: TextAlign.center)),
                  ],
                ),
              );
            }).toList(),
            
          // Add some empty space to make it look like a paper
          for(int i=0; i<3; i++)
            Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                color: (results!.length + i) % 2 == 1 ? const Color(0xFFFFF5F0) : Colors.transparent,
            )
        ],
      ),
    );
  }

  Widget _buildRemarksAndSignature() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(LucideIcons.messageSquare, color: Color(0xFFE85A2A), size: 18),
            const SizedBox(width: 8),
            const Text('Remarks : ', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            Expanded(
              child: Column(
                children: [
                  const Divider(color: Colors.black26, thickness: 1, height: 16),
                  const Divider(color: Colors.black26, thickness: 1, height: 16),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Row(
                children: [
                  const Icon(LucideIcons.qrCode, size: 48),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF5F0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(LucideIcons.info, color: Color(0xFFE85A2A), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('This is a computer generated report.', style: TextStyle(fontSize: 9, color: Colors.black87)),
                                Text('No signature is required.', style: TextStyle(fontSize: 9, color: Colors.black87)),
                                Text('For any queries, please contact the laboratory.', style: TextStyle(fontSize: 9, color: Colors.black87)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              children: [
                const Icon(LucideIcons.penTool, color: Color(0xFFE85A2A), size: 24),
                const SizedBox(height: 8),
                Container(width: 100, height: 1, color: Colors.black54),
                const SizedBox(height: 4),
                const Text('Authorized Signature', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600)),
              ],
            )
          ],
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: const Color(0xFFFFEAE0),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              _buildFooterContact(LucideIcons.globe, 'www.ayusync.com'),
              _buildFooterContact(LucideIcons.mail, 'support@ayusync.com'),
              _buildFooterContact(LucideIcons.phone, '+91 12345 67890'),
            ],
          ),
          const Text(
            'Health Data. Smarter Decisions.',
            style: TextStyle(fontSize: 10, color: Color(0xFFE85A2A), fontStyle: FontStyle.italic, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterContact(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: const Color(0xFFE85A2A)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 9, color: Color(0xFFE85A2A))),
      ],
    );
  }
}
