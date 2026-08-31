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
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildFilterChip('All Statuses'),
        _buildFilterChip('Pending'),
        _buildFilterChip('Approved'),
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

  Widget _buildCellText(String text, TextStyle style, double width) {
    return SizedBox(
      width: width,
      child: Text(
        text, 
        style: style,
        overflow: TextOverflow.ellipsis,
      ),
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
              columns: [
                DataColumn(label: _buildCellText('Auth ID', const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary), 100)),
                DataColumn(label: _buildCellText('Patient', const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary), 140)),
                DataColumn(label: _buildCellText('Date Request', const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary), 110)),
                DataColumn(label: _buildCellText('Procedure', const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary), 140)),
                DataColumn(label: _buildCellText('Status', const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary), 100)),
                DataColumn(label: _buildCellText('Action', const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary), 100)),
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
        DataCell(_buildCellText(id, const TextStyle(fontWeight: FontWeight.w500, color: AppTheme.brandActive), 100)),
        DataCell(_buildCellText(patient, const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark), 140)),
        DataCell(_buildCellText(date, const TextStyle(color: AppTheme.textSecondary), 110)),
        DataCell(_buildCellText(procedure, const TextStyle(color: AppTheme.textDark), 140)),
        DataCell(
          Container(
            width: 100,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor), overflow: TextOverflow.ellipsis),
          ),
        ),
        DataCell(
          SizedBox(
            width: 100,
            child: OutlinedButton(
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
        ),
      ],
    );
  }
}
