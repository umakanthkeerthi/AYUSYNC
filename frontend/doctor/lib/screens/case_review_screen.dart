import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';

class CaseReviewScreen extends StatefulWidget {
  final String patientId;
  const CaseReviewScreen({Key? key, required this.patientId}) : super(key: key);

  @override
  State<CaseReviewScreen> createState() => _CaseReviewScreenState();
}

class _CaseReviewScreenState extends State<CaseReviewScreen> {
  bool _isLoading = true;
  String _error = '';
  Map<String, dynamic>? _data;
  final TextEditingController _noteController = TextEditingController();
  bool _isSavingNote = false;

  @override
  void initState() {
    super.initState();
    _fetchCaseDetails();
  }

  Future<void> _fetchCaseDetails() async {
    try {
      final response = await http.get(
        Uri.parse('http://16.171.226.51/api/v1/doctor/patient/${widget.patientId}/review'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _data = data;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Failed to load case review';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error connecting to server';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveNote() async {
    if (_noteController.text.trim().isEmpty) return;
    
    setState(() => _isSavingNote = true);
    
    try {
      final response = await http.post(
        Uri.parse('http://16.171.226.51/api/v1/doctor/patient/${widget.patientId}/note'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'content': _noteController.text.trim()}),
      );
      
      if (response.statusCode == 200) {
        _noteController.clear();
        await _fetchCaseDetails(); // Refresh notes list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Clinical note saved successfully'), backgroundColor: AppTheme.colorSuccess),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save note'), backgroundColor: AppTheme.colorDanger),
      );
    } finally {
      setState(() => _isSavingNote = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    if (_error.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Case Review')),
        body: Center(child: Text(_error, style: const TextStyle(color: AppTheme.colorDanger))),
      );
    }

    final patient = _data!['patient'];
    final summary = _data!['summary'];
    final notes = _data!['notes'] as List;
    final prescriptions = _data!['prescriptions'] as List;

    return Scaffold(
      backgroundColor: AppTheme.brandBg,
      appBar: AppBar(
        title: Text('Case Review: ${patient['name']}'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textDark,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Clinical Summary Section
            _buildSectionTitle('Clinical Summary'),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppTheme.borderColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.analytics, color: AppTheme.brandActive),
                        const SizedBox(width: 8),
                        Text('Age: ${patient['age']} • Blood Type: ${patient['blood_type']}', 
                             style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(summary, style: const TextStyle(fontSize: 15, height: 1.5)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Risk Score Analytics Section
            _buildSectionTitle('Risk Score Trend (Last 24 Hours)'),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppTheme.borderColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  height: 300,
                  child: _buildChart(patient['risk_score'] != null ? (patient['risk_score'] > 60) : true), // Assuming > 60 is high risk for mock
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Prescriptions Table Section
            _buildSectionTitle('Active Prescriptions'),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppTheme.borderColor),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                  columns: const [
                    DataColumn(label: Text('Drug Name')),
                    DataColumn(label: Text('Dosage Amount')),
                    DataColumn(label: Text('Frequency / Timing')),
                  ],
                  rows: prescriptions.map((p) => DataRow(
                    cells: [
                      DataCell(Text(p['drug_name'], style: const TextStyle(fontWeight: FontWeight.w600))),
                      DataCell(Text(p['dosage'])),
                      DataCell(Text(p['frequency'])),
                    ],
                  )).toList(),
                ),
              ),
            ),
            if (prescriptions.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text('No active prescriptions found.', style: TextStyle(color: AppTheme.textSecondary)),
              ),
            const SizedBox(height: 32),

            // Clinical Notes Workspace Section
            _buildSectionTitle('Clinical Notes Workspace'),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppTheme.borderColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Add New Clinical Note', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _noteController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'write patient case overview',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: const Color(0xFFFAFAFA),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: _isSavingNote ? null : _saveNote,
                        icon: _isSavingNote 
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.save),
                        label: const Text('Save Note'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.brandActive,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ),
                    if (notes.isNotEmpty) ...[
                      const Divider(height: 40),
                      const Text('Historical Notes', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(height: 16),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: notes.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final n = notes[index];
                          // parse timestamp
                          final date = DateTime.tryParse(n['timestamp'])?.toLocal().toString().split('.')[0] ?? 'Unknown Date';
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F4F7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(date, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                                const SizedBox(height: 8),
                                Text(n['text'], style: const TextStyle(fontSize: 14, height: 1.4)),
                              ],
                            ),
                          );
                        },
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
    );
  }

  Widget _buildChart(bool isHighRisk) {
    final spots = isHighRisk 
      ? const [FlSpot(0, 72), FlSpot(4, 75), FlSpot(8, 70), FlSpot(12, 85), FlSpot(16, 88), FlSpot(20, 82), FlSpot(24, 80)]
      : const [FlSpot(0, 68), FlSpot(4, 65), FlSpot(8, 62), FlSpot(12, 64), FlSpot(16, 60), FlSpot(20, 58), FlSpot(24, 55)];
    final color = isHighRisk ? const Color(0xFFEF4444) : const Color(0xFFF59E0B);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 20,
          verticalInterval: 4,
          getDrawingHorizontalLine: (value) => const FlLine(color: AppTheme.borderColor, strokeWidth: 1, dashArray: [5, 5]),
          getDrawingVerticalLine: (value) => const FlLine(color: AppTheme.borderColor, strokeWidth: 1, dashArray: [5, 5]),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 4,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const Padding(padding: EdgeInsets.only(top: 8), child: Text('-24h', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)));
                if (value == 24) return const Padding(padding: EdgeInsets.only(top: 8), child: Text('Now', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)));
                return Padding(padding: const EdgeInsets.only(top: 8), child: Text('-${24 - value.toInt()}h', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 20,
              reservedSize: 42,
              getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0, maxX: 24, minY: 0, maxY: 100,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => AppTheme.textDark,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                return LineTooltipItem('${touchedSpot.y.toInt()} Risk Score', TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14));
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 4, color: Colors.white, strokeWidth: 3, strokeColor: color),
            ),
            belowBarData: BarAreaData(show: true, color: color.withOpacity(0.1)),
          ),
        ],
      ),
    );
  }
}
