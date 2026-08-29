import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AuthorizationsScreen extends StatelessWidget {
  const AuthorizationsScreen({Key? key}) : super(key: key);

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
              'Authorizations Directory',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 24),
            _buildFilters(),
            const SizedBox(height: 24),
            _buildFullDataTable(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        _buildFilterChip('All Statuses'),
        const SizedBox(width: 8),
        _buildFilterChip('Pending'),
        const SizedBox(width: 8),
        _buildFilterChip('Approved'),
        const SizedBox(width: 8),
        _buildFilterChip('Rejected'),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
    );
  }

  Widget _buildFullDataTable(BuildContext context) {
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
                DataColumn(label: Text('Auth ID', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary))),
                DataColumn(label: Text('Patient', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary))),
                DataColumn(label: Text('Date Request', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary))),
                DataColumn(label: Text('Procedure', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary))),
                DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary))),
                DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary))),
              ],
              rows: [
                _buildRow('AUTH-1042', 'Rahul Kumar', 'Oct 12, 2026', 'MRI Scan', 'Pending', AppTheme.statPending),
                _buildRow('AUTH-1041', 'Priya Sharma', 'Oct 11, 2026', 'CT Scan', 'Approved', AppTheme.statApproved),
                _buildRow('AUTH-1040', 'Arjun Rao', 'Oct 10, 2026', 'Physiotherapy', 'Rejected', AppTheme.statRejected),
                _buildRow('AUTH-1039', 'Meera Iyer', 'Oct 09, 2026', 'Echocardiogram', 'Approved', AppTheme.statApproved),
                _buildRow('AUTH-1038', 'Sanjay Patel', 'Oct 08, 2026', 'Blood Test', 'Pending', AppTheme.statPending),
                _buildRow('AUTH-1037', 'Kavita Singh', 'Oct 08, 2026', 'X-Ray', 'Under Review', AppTheme.statReview),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DataRow _buildRow(String id, String patient, String date, String procedure, String status, Color statusColor) {
    return DataRow(
      cells: [
        DataCell(Text(id, style: const TextStyle(fontWeight: FontWeight.w500, color: AppTheme.brandActive))),
        DataCell(Text(patient, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark))),
        DataCell(Text(date, style: const TextStyle(color: AppTheme.textSecondary))),
        DataCell(Text(procedure, style: const TextStyle(color: AppTheme.textDark))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor)),
          ),
        ),
        DataCell(
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF3b82f6),
              side: const BorderSide(color: Color(0xFFbfdbfe)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('View', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}
