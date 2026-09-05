import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';

class PatientDetailsDialog extends StatefulWidget {
  final String patientId;
  final String patientName;

  const PatientDetailsDialog({
    Key? key,
    required this.patientId,
    required this.patientName,
  }) : super(key: key);

  @override
  State<PatientDetailsDialog> createState() => _PatientDetailsDialogState();
}

class _PatientDetailsDialogState extends State<PatientDetailsDialog> {
  bool _isLoading = true;
  String _error = '';
  
  List<dynamic> _vitals = [];
  List<dynamic> _medications = [];
  
  int _completedMeds = 0;
  int _totalMeds = 0;
  
  bool _isReviewed = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final baseUrl = 'http://16.171.226.51/api/v1/patients/${widget.patientId}';
      
      final responses = await Future.wait([
        http.get(Uri.parse('$baseUrl/vitals')),
        http.get(Uri.parse('$baseUrl/medications')),
        http.get(Uri.parse('$baseUrl/plan')),
      ]);

      if (responses.any((r) => r.statusCode != 200)) {
        throw Exception('Failed to fetch some patient data');
      }

      final vitalsData = json.decode(responses[0].body) as List;
      final medsData = json.decode(responses[1].body) as List;
      final planData = json.decode(responses[2].body);
      
      // Calculate medication adherence from today's tasks
      int completed = 0;
      int total = 0;
      if (planData['status'] == 'success' && planData['today_tasks'] != null) {
        final tasks = planData['today_tasks'] as List;
        for (var t in tasks) {
          if (t['id'].toString().startsWith('med_') || t['title'] == 'Take Medication') {
            total++;
            if (t['is_completed'] == true) {
              completed++;
            }
          }
        }
      }

      setState(() {
        _vitals = vitalsData;
        _medications = medsData;
        _completedMeds = completed;
        _totalMeds = total;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading data: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildVitalsSection() {
    if (_vitals.isEmpty) {
      return const Text('No recent telemetry data available.', style: TextStyle(color: AppTheme.textSecondary));
    }

    // Sort by timestamp descending
    _vitals.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
    final latest = _vitals.first;
    
    // Reverse for chart (oldest to newest)
    final chartData = List.from(_vitals).reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Latest Telemetry (Past Hour)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildVitalCard('Heart Rate', '${latest['heart_rate']} bpm', Icons.favorite, Colors.red),
            _buildVitalCard('Blood Pressure', '${latest['bp_systolic']}/${latest['bp_diastolic']}', Icons.bloodtype, Colors.blue),
            _buildVitalCard('SpO2', '${latest['spo2']}%', Icons.air, Colors.green),
          ],
        ),
        const SizedBox(height: 24),
        if (chartData.length > 1) ...[
          const Text('Heart Rate Trend', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (chartData.length - 1).toDouble(),
                minY: 40,
                maxY: 160,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      chartData.length,
                      (index) => FlSpot(index.toDouble(), (chartData[index]['heart_rate'] as num).toDouble()),
                    ),
                    isCurved: true,
                    color: Colors.redAccent,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.redAccent.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildVitalCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        ],
      ),
    );
  }

  Widget _buildMedicationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Current Medications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        if (_medications.isEmpty)
          const Text('No active medications.', style: TextStyle(color: AppTheme.textSecondary))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _medications.length,
            itemBuilder: (context, index) {
              final med = _medications[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.brandActive.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.medication, color: AppTheme.brandActive),
                ),
                title: Text(med['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${med['dosage']} - ${med['frequency']}'),
              );
            },
          ),
      ],
    );
  }

  Widget _buildAdherenceSection() {
    final double adherencePercent = _totalMeds > 0 ? (_completedMeds / _totalMeds) : 1.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Today\'s Medication Adherence', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: adherencePercent,
                    strokeWidth: 6,
                    backgroundColor: Colors.grey[200],
                    color: adherencePercent > 0.8 ? Colors.green : (adherencePercent > 0.5 ? Colors.orange : Colors.red),
                  ),
                  Center(
                    child: Text(
                      '${(adherencePercent * 100).toInt()}%',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Taken: $_completedMeds of $_totalMeds doses today', style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    _totalMeds == 0 ? 'No medications scheduled for today.' : (adherencePercent == 1.0 ? 'Perfect adherence today.' : 'Patient missed some doses.'),
                    style: const TextStyle(color: AppTheme.textSecondary),
                  )
                ],
              ),
            )
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 800,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Patient Overview: ${widget.patientName}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.brandActive),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(height: 32),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error.isNotEmpty
                      ? Center(child: Text(_error, style: const TextStyle(color: Colors.red)))
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildVitalsSection(),
                              const SizedBox(height: 32),
                              const Divider(),
                              const SizedBox(height: 32),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _buildMedicationsSection()),
                                  const SizedBox(width: 32),
                                  Expanded(child: _buildAdherenceSection()),
                                ],
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
            ),
            if (!_isLoading && _error.isEmpty) ...[
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _isReviewed,
                        onChanged: (val) {
                          setState(() {
                            _isReviewed = val ?? false;
                          });
                        },
                        activeColor: AppTheme.brandActive,
                      ),
                      const Text(
                        'I have reviewed this patient\'s latest telemetry and adherence.',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: _isReviewed ? () => Navigator.of(context).pop() : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isReviewed ? AppTheme.brandActive : Colors.grey,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Confirm & Close', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                ],
              )
            ]
          ],
        ),
      ),
    );
  }
}
