import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/app_theme.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({Key? key}) : super(key: key);

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<dynamic> _alerts = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchAlerts();
  }

  Future<void> _fetchAlerts() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8001/api/v1/nurse/alerts'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _alerts = data['alerts'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load alerts';
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
                'Critical Alerts & Escalations',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, ),
              ),
              ElevatedButton.icon(
                onPressed: _fetchAlerts,
                icon: Icon(Icons.refresh, size: 18),
                label: Text('Refresh'),
              )
            ],
          ),
          SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: _alerts.length,
              itemBuilder: (context, index) {
                final alert = _alerts[index];
                final bool isTriage = alert['type'] == 'Triage Alert';
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: isTriage ? AppTheme.colorUrgent.withOpacity(0.5) : AppTheme.colorFollowup.withOpacity(0.5), width: 1),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isTriage ? AppTheme.colorUrgent.withOpacity(0.1) : AppTheme.colorFollowup.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(isTriage ? Icons.warning_amber_rounded : Icons.priority_high, color: isTriage ? AppTheme.colorUrgent : AppTheme.colorFollowup),
                    ),
                    title: Text('${alert['patient_name']} - ${alert['type']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text('${alert['description']} • ${alert['time']}', style: TextStyle(color: Theme.of(context).hintColor)),
                    trailing: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: isTriage ? AppTheme.colorUrgent : AppTheme.colorFollowup),
                      child: Text('Respond'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
