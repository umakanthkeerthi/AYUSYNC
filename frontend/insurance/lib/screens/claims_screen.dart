import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:responsive_builder/responsive_builder.dart';

class ClaimsScreen extends StatelessWidget {
  const ClaimsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        bool isMobile = sizingInformation.deviceScreenType == DeviceScreenType.mobile;
        
        return Scaffold(
          backgroundColor: AppTheme.brandBg,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Claims History',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
                const SizedBox(height: 24),
                _buildMetrics(isMobile),
                const SizedBox(height: 32),
                _buildClaimsTable(context),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildMetrics(bool isMobile) {
    return Row(
      children: [
        Expanded(child: _buildMetricCard('Total Claimed (YTD)', '₹14,50,000', AppTheme.textDark)),
        const SizedBox(width: 16),
        Expanded(child: _buildMetricCard('Total Approved', '₹12,25,000', AppTheme.statApproved)),
        if (!isMobile) const SizedBox(width: 16),
        if (!isMobile) Expanded(child: _buildMetricCard('Pending Payout', '₹2,25,000', AppTheme.statReview)),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildClaimsTable(BuildContext context) {
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
                DataColumn(label: Text('Claim ID', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary))),
                DataColumn(label: Text('Patient', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary))),
                DataColumn(label: Text('Claimed Amt', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary))),
                DataColumn(label: Text('Approved Amt', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary))),
                DataColumn(label: Text('Date Filed', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary))),
                DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary))),
              ],
              rows: [
                _buildRow('CLM-5501', 'Rahul Kumar', '₹8,500', '₹8,500', 'Oct 12', 'Paid', AppTheme.statApproved),
                _buildRow('CLM-5502', 'Priya Sharma', '₹6,200', '₹5,000', 'Oct 11', 'Paid', AppTheme.statApproved),
                _buildRow('CLM-5503', 'Arjun Rao', '₹3,000', '₹0', 'Oct 10', 'Denied', AppTheme.statRejected),
                _buildRow('CLM-5504', 'Meera Iyer', '₹4,000', '---', 'Oct 09', 'Processing', AppTheme.statPending),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DataRow _buildRow(String id, String patient, String claimed, String approved, String date, String status, Color statusColor) {
    return DataRow(
      cells: [
        DataCell(Text(id, style: const TextStyle(fontWeight: FontWeight.w500, color: AppTheme.textDark))),
        DataCell(Text(patient, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark))),
        DataCell(Text(claimed, style: const TextStyle(color: AppTheme.textSecondary))),
        DataCell(Text(approved, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark))),
        DataCell(Text(date, style: const TextStyle(color: AppTheme.textSecondary))),
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
      ],
    );
  }
}
