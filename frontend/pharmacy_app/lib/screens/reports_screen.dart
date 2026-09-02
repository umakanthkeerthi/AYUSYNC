import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/theme.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _totalDispensed = 0;
  String _percentageChange = "+0%";
  List<dynamic> _chartData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8001/api/v1/pharmacy/reports'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _totalDispensed = data['total_dispensed'];
            _percentageChange = data['percentage_change'];
            _chartData = data['chart_data'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;
        final double padding = isMobile ? 16.0 : 32.0;

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text('Reports', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: PharmacyTheme.textDark)),
                ],
              ),
              const SizedBox(height: 4),
              const Text('Review pharmacy performance and dispensing trends.', style: TextStyle(color: PharmacyTheme.textSecondary, fontSize: 15)),
              const SizedBox(height: 32),
              if (_isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
              else
                _buildMainAnalyticsChart(isMobile),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainAnalyticsChart(bool isMobile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: PharmacyTheme.cardRadius,
        border: Border.all(color: PharmacyTheme.border),
        boxShadow: PharmacyTheme.premiumShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Dispensing Trends', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: PharmacyTheme.textDark)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('$_totalDispensed', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: PharmacyTheme.textDark, height: 1)),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: PharmacyTheme.statGreenBg, borderRadius: BorderRadius.circular(4)),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.trendingUp, size: 14, color: PharmacyTheme.statGreen),
                              const SizedBox(width: 4),
                              Text(_percentageChange, style: const TextStyle(color: PharmacyTheme.statGreen, fontWeight: FontWeight.w600, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('Prescriptions dispensed this week', style: TextStyle(color: PharmacyTheme.textSecondary, fontSize: 13)),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.calendar, size: 16),
                  label: const Text('Last 7 Days'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: PharmacyTheme.textDark,
                    side: const BorderSide(color: PharmacyTheme.border),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: PharmacyTheme.border),
          Container(
            height: 340,
            padding: const EdgeInsets.all(32),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildYAxis(),
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: _chartData.map((d) {
                      bool isToday = d['day'] == 'Fri';
                      return _buildChartBar(d['day'], d['value'].toDouble(), isToday: isToday);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYAxis() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('50', style: TextStyle(color: PharmacyTheme.textSecondary, fontSize: 12)),
        Text('40', style: TextStyle(color: PharmacyTheme.textSecondary, fontSize: 12)),
        Text('30', style: TextStyle(color: PharmacyTheme.textSecondary, fontSize: 12)),
        Text('20', style: TextStyle(color: PharmacyTheme.textSecondary, fontSize: 12)),
        Text('10', style: TextStyle(color: PharmacyTheme.textSecondary, fontSize: 12)),
        Text('0', style: TextStyle(color: PharmacyTheme.textSecondary, fontSize: 12)),
        SizedBox(height: 24), // space for x axis labels
      ],
    );
  }

  Widget _buildChartBar(String day, double heightRatio, {bool isToday = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 40,
          height: 250 * heightRatio,
          decoration: BoxDecoration(
            color: isToday ? PharmacyTheme.primary : PharmacyTheme.border,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
        const SizedBox(height: 12),
        Text(day, style: TextStyle(
          color: isToday ? PharmacyTheme.textDark : PharmacyTheme.textSecondary,
          fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
          fontSize: 13
        )),
      ],
    );
  }
}
