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
                  'Financial Reports',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
                const SizedBox(height: 24),
                _buildReportCard('Total Revenue (YTD)', '₹1,45,20,000', '+12.5% vs last year', isMobile),
                const SizedBox(height: 16),
                _buildReportCard('Average Claim Processing Time', '4.2 Days', '-0.8 Days vs last month', isMobile),
                const SizedBox(height: 16),
                _buildReportCard('Claim Denial Rate', '8.4%', '+1.2% vs last month', isMobile, isNegative: true),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildReportCard(String title, String value, String subtext, bool isMobile, {bool isNegative = false}) {
    return Container(
      width: isMobile ? double.infinity : 600,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              const SizedBox(width: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Text(
                  subtext,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isNegative ? AppTheme.statRejected : AppTheme.statApproved,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Simple visual progress bar instead of full fl_chart
          Container(
            height: 8,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.borderColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: isNegative ? 0.3 : 0.75,
              child: Container(
                decoration: BoxDecoration(
                  color: isNegative ? AppTheme.statRejected : AppTheme.statApproved,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
