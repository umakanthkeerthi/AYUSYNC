import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/app_theme.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  List<dynamic> _appointments = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8001/api/v1/nurse/appointments'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _appointments = data['appointments'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load appointments';
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
                'Upcoming Appointments',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, ),
              ),
              ElevatedButton.icon(
                onPressed: _fetchAppointments,
                icon: Icon(Icons.refresh, size: 18),
                label: Text('Refresh'),
              )
            ],
          ),
          SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: _appointments.length,
              itemBuilder: (context, index) {
                final appt = _appointments[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.brandPrimary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.event, color: AppTheme.brandPrimary),
                    ),
                    title: Text('${appt['patient_name']} with ${appt['doctor_name']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text('${appt['date']} at ${appt['time']}', style: TextStyle(color: Theme.of(context).hintColor)),
                    trailing: OutlinedButton(
                      onPressed: () {},
                      child: Text('View Details'),
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
