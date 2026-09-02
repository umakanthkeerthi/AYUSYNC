import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:fl_chart/fl_chart.dart'; // Just in case, though not strictly used in this snippet directly
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/app_theme.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _isLoading = true;
  String _error = '';
  Map<String, dynamic> _reportData = {
    'total_revenue': '₹0',
    'orders_delivered': '0',
    'avg_turnaround': '0 hrs',
    'pending_bills': '₹0',
    'table_data': []
  };

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8001/api/v1/lab/reports'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _reportData = data;
            _isLoading = false;
          });
        } else {
          setState(() { _error = 'Failed to load reports'; _isLoading = false; });
        }
      } else {
        setState(() { _error = 'Server error'; _isLoading = false; });
      }
    } catch (e) {
      setState(() { _error = 'Error connecting to server'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        bool isMobile = sizingInformation.deviceScreenType == DeviceScreenType.mobile;
        
        if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        if (_error.isNotEmpty) return Scaffold(body: Center(child: Text(_error, style: const TextStyle(color: Colors.red))));

        return Scaffold(
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
                  'Recent Reports & Revenue',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
                const SizedBox(height: 16),
                _buildDataList(context, isMobile),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today, size: 16, color: AppTheme.textSecondary),
                SizedBox(width: 8),
                Text('This Month', style: TextStyle(color: AppTheme.textDark, fontSize: 13, fontWeight: FontWeight.w500)),
                SizedBox(width: 8),
                Icon(Icons.keyboard_arrow_down, size: 16, color: AppTheme.textSecondary),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () {
              setState(() { _isLoading = true; });
              _fetchReports();
            },
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.brandActive,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards(bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 0) return const SizedBox.shrink();
        
        double cardWidth = constraints.maxWidth < 600 
            ? ((constraints.maxWidth - 20) / 2).clamp(0.0, double.infinity)
            : ((constraints.maxWidth - 52) / 4).clamp(0.0, double.infinity);
            
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: cardWidth,
              child: HoverReportCard(
                title: 'Total Revenue',
                value: _reportData['total_revenue'] ?? '₹0',
                subtitle: '+12% from last month',
                bgColor: const Color(0xFFF0FDF4), 
                iconColor: const Color(0xFF22C55E),
                icon: Icons.account_balance_wallet,
                imagePath: 'assets/images/report_revenue.jpg',
              )
            ),
            SizedBox(
              width: cardWidth,
              child: HoverReportCard(
                title: 'Orders Delivered',
                value: _reportData['orders_delivered'] ?? '0',
                subtitle: 'Tests completed',
                bgColor: const Color(0xFFEFF6FF), 
                iconColor: const Color(0xFF3B82F6),
                icon: Icons.check_circle_outline,
                imagePath: 'assets/images/report_orders.jpg',
              )
            ),
            SizedBox(
              width: cardWidth,
              child: HoverReportCard(
                title: 'Avg Turnaround',
                value: _reportData['avg_turnaround'] ?? '0 hrs',
                subtitle: 'Improved by 30m',
                bgColor: const Color(0xFFFFF7ED), 
                iconColor: const Color(0xFFF97316),
                icon: Icons.timer,
                imagePath: 'assets/images/report_time.jpg',
              )
            ),
            SizedBox(
              width: cardWidth,
              child: HoverReportCard(
                title: 'Pending Bills',
                value: _reportData['pending_bills'] ?? '₹0',
                subtitle: '15 invoices',
                bgColor: const Color(0xFFFEF2F2), 
                iconColor: const Color(0xFFEF4444),
                icon: Icons.receipt_long,
                imagePath: 'assets/images/report_bills.jpg',
              )
            ),
          ],
        );
      }
    );
  }

  Widget _buildDataList(BuildContext context, bool isMobile) {
    final List<dynamic> rawData = _reportData['table_data'] ?? [];
    
    // Convert to list of maps with string keys/values
    final List<Map<String, String>> data = rawData.map((e) => {
      'date': e['date']?.toString() ?? '',
      'patient': e['patient']?.toString() ?? '',
      'tests': e['tests']?.toString() ?? '',
      'status': e['status']?.toString() ?? '',
      'revenue': e['revenue']?.toString() ?? '',
    }).toList();

    if (MediaQuery.of(context).size.width < 800) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: data.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = data[index];
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item['patient']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(item['revenue']!, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.statBlue)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(item['tests']!, style: const TextStyle(color: AppTheme.textSecondary)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 14, color: AppTheme.textSecondary),
                          const SizedBox(width: 4),
                          Text(item['date']!, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.statBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(item['status']!, style: const TextStyle(color: AppTheme.statBlue, fontSize: 12, fontWeight: FontWeight.bold)),
                      )
                    ],
                  )
                ],
              ),
            );
          },
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))
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
              columns: [
                DataColumn(label: _buildCellText('Date', const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary), 120)),
                DataColumn(label: _buildCellText('Patient', const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary), 140)),
                DataColumn(label: _buildCellText('Tests Performed', const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary), 160)),
                DataColumn(label: _buildCellText('Status', const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary), 100)),
                DataColumn(label: _buildCellText('Revenue', const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary), 100)),
              ],
              rows: data.map((item) => _buildRow(item['date']!, item['patient']!, item['tests']!, item['status']!, item['revenue']!)).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCellText(String text, TextStyle style, double width) {
    return SizedBox(
      width: width,
      child: Text(text, style: style, overflow: TextOverflow.ellipsis),
    );
  }

  DataRow _buildRow(String date, String patient, String tests, String status, String revenue) {
    return DataRow(
      cells: [
        DataCell(_buildCellText(date, const TextStyle(color: AppTheme.textSecondary), 120)),
        DataCell(_buildCellText(patient, const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark), 140)),
        DataCell(_buildCellText(tests, const TextStyle(color: AppTheme.textSecondary), 160)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.statBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(status, style: const TextStyle(color: AppTheme.statBlue, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
        DataCell(_buildCellText(revenue, const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark), 100)),
      ],
    );
  }
}

class HoverReportCard extends StatefulWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color bgColor;
  final Color iconColor;
  final IconData icon;
  final String imagePath;

  const HoverReportCard({
    Key? key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.bgColor,
    required this.iconColor,
    required this.icon,
    required this.imagePath,
  }) : super(key: key);

  @override
  State<HoverReportCard> createState() => _HoverReportCardState();
}

class _HoverReportCardState extends State<HoverReportCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuart,
        transformAlignment: Alignment.center,
        transform: Matrix4.identity()
          ..translate(0.0, _isHovered ? -8.0 : 0.0, 0.0)
          ..scale(_isHovered ? 1.02 : 1.00),
        decoration: BoxDecoration(
          color: widget.bgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.9),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
            BoxShadow(
              color: _isHovered ? widget.iconColor.withOpacity(0.3) : widget.iconColor.withOpacity(0.0),
              blurRadius: _isHovered ? 24 : 0,
              offset: Offset(0, _isHovered ? 12 : 0),
              spreadRadius: _isHovered ? 2 : 0,
            )
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 20, spreadRadius: 10)],
                ),
                child: ClipOval(
                  child: Image.asset(
                    widget.imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
                    ),
                    child: Icon(widget.icon, color: widget.iconColor, size: 24),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textSecondary, height: 1.1),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        widget.value,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: widget.iconColor, letterSpacing: -0.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(widget.subtitle, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
