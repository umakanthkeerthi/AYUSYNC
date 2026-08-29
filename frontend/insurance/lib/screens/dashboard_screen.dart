import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:responsive_builder/responsive_builder.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

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
                _buildHeader(isMobile),
                const SizedBox(height: 32),
                _buildStatCards(isMobile),
                const SizedBox(height: 32),
                const Text(
                  'Pending Authorizations',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
                const SizedBox(height: 16),
                _buildDataTable(context),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {},
                  child: const Text('View all authorizations →', style: TextStyle(color: AppTheme.brandActive, fontWeight: FontWeight.w600)),
                )
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildHeader(bool isMobile) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Claims & Authorization', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          const SizedBox(height: 16),
          _buildSearchAndFilter(),
        ],
      );
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Claims & Authorization', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        _buildSearchAndFilter(),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Container(
          width: 200,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.borderColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: const Row(
            children: [
              Expanded(child: Text('Search patient / ID', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13))),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: const Row(
            children: [
              Icon(Icons.filter_list, size: 16, color: AppTheme.textSecondary),
              SizedBox(width: 8),
              Text('All', style: TextStyle(color: AppTheme.textDark, fontSize: 13)),
              SizedBox(width: 8),
              Icon(Icons.keyboard_arrow_down, size: 16, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCards(bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
        
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: isMobile ? 1.5 : 2.0,
          children: [
            _buildStatCard('12', 'Pending Authorization', AppTheme.statPending),
            _buildStatCard('38', 'Approved', AppTheme.statApproved),
            _buildStatCard('3', 'Rejected', AppTheme.statRejected),
            _buildStatCard('2', 'Under Review', AppTheme.statReview),
          ],
        );
      }
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: AppTheme.borderColor.withOpacity(0.5)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
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
              dividerThickness: 1,
              columns: const [
                DataColumn(label: Text('Patient', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary))),
                DataColumn(label: Text('Procedure', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary))),
                DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary))),
                DataColumn(label: Text('Coverage', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary))),
                DataColumn(label: Text('Patient Pay', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary))),
                DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary))),
              ],
              rows: [
                _buildRow('Rahul Kumar', 'MRI Scan', '₹8,500', '80%', '₹1,700'),
                _buildRow('Priya Sharma', 'CT Scan', '₹6,200', '80%', '₹1,240'),
                _buildRow('Arjun Rao', 'Physiotherapy', '₹3,000', '60%', '₹1,200'),
                _buildRow('Meera Iyer', 'Echocardiogram', '₹4,000', '80%', '₹800'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DataRow _buildRow(String patient, String procedure, String amount, String coverage, String pay) {
    return DataRow(
      cells: [
        DataCell(Text(patient, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark))),
        DataCell(Text(procedure, style: const TextStyle(color: AppTheme.textSecondary))),
        DataCell(Text(amount, style: const TextStyle(color: AppTheme.textDark))),
        DataCell(Text(coverage, style: const TextStyle(color: AppTheme.textSecondary))),
        DataCell(Text(pay, style: const TextStyle(color: AppTheme.textDark))),
        DataCell(
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF3b82f6), // Blue text
              side: const BorderSide(color: Color(0xFFbfdbfe)), // Light blue border
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Review', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}
