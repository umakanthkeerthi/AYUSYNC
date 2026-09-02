import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/app_theme.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  Map<String, dynamic> _reports = {};
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8001/api/v1/nurse/reports'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _reports = data['reports'] ?? {};
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load reports';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Center(child: CircularProgressIndicator());
    if (_errorMessage.isNotEmpty) return Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red)));

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nursing Analytics & Reports',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, ),
              ),
              ElevatedButton.icon(
                onPressed: _fetchReports,
                icon: Icon(Icons.refresh, size: 18),
                label: Text('Refresh'),
              )
            ],
          ),
          SizedBox(height: 32),
          Row(
            children: [
              _buildStatCard('Total Tasks Handled', _reports['total_tasks_handled'].toString(), Icons.assignment, AppTheme.colorTotal),
              SizedBox(width: 16),
              _buildStatCard('Tasks Completed', _reports['tasks_completed'].toString(), Icons.check_circle, AppTheme.colorOnTrack),
              SizedBox(width: 16),
              _buildStatCard('Avg Response Time', _reports['average_response_time'].toString(), Icons.timer, AppTheme.colorFollowup),
              SizedBox(width: 16),
              _buildStatCard('Patient Satisfaction', _reports['patient_satisfaction'].toString(), Icons.sentiment_very_satisfied, AppTheme.brandPrimary),
            ],
          ),
          SizedBox(height: 32),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Performance Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 16),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.borderColor),
                              ),
                              child: Center(child: Text('Chart Placeholder', style: TextStyle(color: Theme.of(context).hintColor))),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Top Interventions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 16),
                          Expanded(
                            child: ListView(
                              children: const [
                                ListTile(leading: Icon(Icons.vaccines, color: AppTheme.brandPrimary), title: Text('Medication Administration')),
                                ListTile(leading: Icon(Icons.monitor_heart, color: AppTheme.brandPrimary), title: Text('Vitals Monitoring')),
                                ListTile(leading: Icon(Icons.medical_services, color: AppTheme.brandPrimary), title: Text('Wound Care')),
                                ListTile(leading: Icon(Icons.bloodtype, color: AppTheme.brandPrimary), title: Text('IV Setup')),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 24),
              ),
              SizedBox(height: 16),
              Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(label, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
