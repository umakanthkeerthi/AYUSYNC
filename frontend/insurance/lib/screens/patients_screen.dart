import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PatientsScreen extends StatelessWidget {
  const PatientsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.brandBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Patient Coverage Directory',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 24),
            _buildPatientsTable(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientsTable(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width > 800 ? MediaQuery.of(context).size.width - 350 : 800),
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
              columns: const [
                DataColumn(label: Text('Patient ID', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary))),
                DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary))),
                DataColumn(label: Text('Provider', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary))),
                DataColumn(label: Text('Policy #', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary))),
                DataColumn(label: Text('Coverage', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary))),
                DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary))),
              ],
              rows: [
                _buildRow('PAT-101', 'Rahul Kumar', 'HDFC ERGO', 'POL-49210', 'Active (80%)'),
                _buildRow('PAT-102', 'Priya Sharma', 'Star Health', 'POL-82199', 'Active (80%)'),
                _buildRow('PAT-103', 'Arjun Rao', 'ICICI Lombard', 'POL-11920', 'Active (60%)'),
                _buildRow('PAT-104', 'Meera Iyer', 'Apollo Munich', 'POL-33291', 'Expired'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DataRow _buildRow(String id, String name, String provider, String policy, String coverage) {
    bool isActive = coverage.contains('Active');
    return DataRow(
      cells: [
        DataCell(Text(id, style: const TextStyle(fontWeight: FontWeight.w500, color: AppTheme.textSecondary))),
        DataCell(Text(name, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark))),
        DataCell(Text(provider, style: const TextStyle(color: AppTheme.textDark))),
        DataCell(Text(policy, style: const TextStyle(color: AppTheme.textSecondary))),
        DataCell(
          Text(coverage, style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? AppTheme.statApproved : AppTheme.statRejected)),
        ),
        DataCell(
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.brandActive,
              side: const BorderSide(color: AppTheme.brandActive),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Verify', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}
