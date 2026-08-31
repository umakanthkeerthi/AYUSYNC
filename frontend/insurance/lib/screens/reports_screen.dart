import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:responsive_builder/responsive_builder.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({Key? key}) : super(key: key);

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
                  'Financial Analytics Dashboard',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
                const SizedBox(height: 24),
                
                // 1. KPI RIBBON
                if (isMobile)
                  Column(
                    children: [
                      _buildKPICard('Total Revenue (YTD)', '₹1,45,20,000', '+12.5%', AppTheme.statApproved, Icons.account_balance_wallet, double.infinity),
                      const SizedBox(height: 16),
                      _buildKPICard('Avg Claim Processing', '4.2 Days', '-0.8 Days', AppTheme.statBlue, Icons.timer, double.infinity),
                      const SizedBox(height: 16),
                      _buildKPICard('Claim Denial Rate', '8.4%', '+1.2%', AppTheme.statRejected, Icons.error_outline, double.infinity),
                      const SizedBox(height: 16),
                      _buildKPICard('Active Policies', '1,24,050', '+5.4%', AppTheme.statPurple, Icons.verified_user, double.infinity),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(child: _buildKPICard('Total Revenue (YTD)', '₹1,45,20,000', '+12.5%', AppTheme.statApproved, Icons.account_balance_wallet, double.infinity)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildKPICard('Avg Claim Processing', '4.2 Days', '-0.8 Days', AppTheme.statBlue, Icons.timer, double.infinity)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildKPICard('Claim Denial Rate', '8.4%', '+1.2%', AppTheme.statRejected, Icons.error_outline, double.infinity)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildKPICard('Active Policies', '1,24,050', '+5.4%', AppTheme.statPurple, Icons.verified_user, double.infinity)),
                    ],
                  ),
                
                const SizedBox(height: 24),

                // 2. VISUALIZATIONS ROW
                if (isMobile)
                  Column(
                    children: [
                      _buildRevenueChartCard(double.infinity),
                      const SizedBox(height: 16),
                      _buildClaimStatusBreakdown(double.infinity),
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 7, child: _buildRevenueChartCard(double.infinity)),
                      const SizedBox(width: 24),
                      Expanded(flex: 3, child: _buildClaimStatusBreakdown(double.infinity)),
                    ],
                  ),

                const SizedBox(height: 24),
                
                // 3. RECENT HIGH-VALUE CLAIMS
                const Text(
                  'Recent High-Value Disbursals',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
                const SizedBox(height: 16),
                _buildClaimsTable(context),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildKPICard(String title, String value, String change, Color color, IconData icon, double width) {
    bool isPositive = change.startsWith('+');
    Color changeColor = isPositive ? AppTheme.statApproved : AppTheme.statRejected;
    if (title.contains('Denial Rate')) {
        changeColor = isPositive ? AppTheme.statRejected : AppTheme.statApproved;
    }

    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(title, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w600))),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 16),
              )
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          ),
          const SizedBox(height: 8),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(isPositive ? Icons.trending_up : Icons.trending_down, size: 16, color: changeColor),
              const SizedBox(width: 4),
              Text('$change vs last month', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: changeColor)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRevenueChartCard(double width) {
    final List<double> monthlyData = [45, 60, 55, 80, 70, 95, 85, 110, 100, 120, 115, 140];
    final List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    double maxVal = 150; 

    return Container(
      width: width,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Revenue Trend (2026)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          const SizedBox(height: 8),
          const Text('Monthly gross premium collection in Lakhs (₹)', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(12, (index) {
                  double heightRatio = monthlyData[index] / maxVal;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('₹${monthlyData[index].toInt()}L', style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutCubic,
                          height: 150 * heightRatio,
                          width: 25,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                AppTheme.statApproved.withOpacity(0.4),
                                AppTheme.statApproved,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(months[index], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                      ],
                    ),
                  );
                }),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildClaimStatusBreakdown(double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Claims Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          const SizedBox(height: 8),
          const Text('Status distribution for current year', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          const SizedBox(height: 24),
          _buildProgressRow('Approved', '68%', 0.68, AppTheme.statApproved),
          const SizedBox(height: 20),
          _buildProgressRow('Pending', '22%', 0.22, AppTheme.statPending),
          const SizedBox(height: 20),
          _buildProgressRow('Review', '8.4%', 0.084, AppTheme.statReview),
          const SizedBox(height: 20),
          _buildProgressRow('Rejected', '1.6%', 0.016, AppTheme.statRejected),
        ],
      ),
    );
  }

  Widget _buildProgressRow(String label, String percentStr, double percent, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark), overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 8),
            Text(percentStr, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(color: AppTheme.borderColor, borderRadius: BorderRadius.circular(4)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percent,
            child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
          ),
        )
      ],
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
              columns: [
                DataColumn(label: _buildCellText('Disbursal ID', const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary), 100)),
                DataColumn(label: _buildCellText('Hospital', const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary), 160)),
                DataColumn(label: _buildCellText('Patient', const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary), 120)),
                DataColumn(label: _buildCellText('Date', const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary), 100)),
                DataColumn(label: _buildCellText('Amount', const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary), 100)),
                DataColumn(label: _buildCellText('Status', const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary), 100)),
              ],
              rows: [
                _buildRow('DISB-9921', 'Apollo Hospitals', 'Ramesh Gupta', 'Oct 12', '₹4,50,000', 'Cleared', AppTheme.statApproved),
                _buildRow('DISB-9920', 'Fortis Healthcare', 'Sunita Sharma', 'Oct 11', '₹2,10,000', 'Processing', AppTheme.statBlue),
                _buildRow('DISB-9919', 'Max Super Speciality', 'Arun Patel', 'Oct 10', '₹8,75,000', 'Cleared', AppTheme.statApproved),
                _buildRow('DISB-9918', 'AIIMS Delhi', 'Pooja Singh', 'Oct 08', '₹1,25,000', 'Cleared', AppTheme.statApproved),
              ],
            ),
          ),
        ),
      ),
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

  DataRow _buildRow(String id, String hospital, String patient, String date, String amount, String status, Color statusColor) {
    return DataRow(
      cells: [
        DataCell(_buildCellText(id, const TextStyle(fontWeight: FontWeight.w500, color: AppTheme.textDark), 100)),
        DataCell(_buildCellText(hospital, const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark), 160)),
        DataCell(_buildCellText(patient, const TextStyle(color: AppTheme.textSecondary), 120)),
        DataCell(_buildCellText(date, const TextStyle(color: AppTheme.textSecondary), 100)),
        DataCell(_buildCellText(amount, const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark), 100)),
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
      ],
    );
  }
}
