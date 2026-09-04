import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/app_theme.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({Key? key}) : super(key: key);

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  List<dynamic> _patients = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8001/api/v1/nurse/patients'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _patients = data['patients'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load patients';
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
                'Patients Directory',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, ),
              ),
              ElevatedButton.icon(
                onPressed: _fetchPatients,
                icon: Icon(Icons.refresh, size: 18),
                label: Text('Refresh'),
              )
            ],
          ),
          SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 320,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 140,
              ),
              itemCount: _patients.length,
              itemBuilder: (context, index) {
                final patient = _patients[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: AppTheme.brandPrimary.withOpacity(0.1),
                              child: Text(patient['name'][0], style: TextStyle(color: AppTheme.brandPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text(patient['name'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                      _buildSeverityBadge(patient['status'] ?? 'STABLE'),
                                    ],
                                  ),
                                  Text('${patient['age']} yrs • Blood: ${patient['blood_type']}', style: TextStyle(color: Theme.of(context).hintColor, fontSize: 11)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Divider(),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildVital('Heart Rate', '${patient['vitals']?['heart_rate'] ?? '--'} bpm', Icons.favorite, Colors.red),
                            _buildVital('BP', patient['vitals']?['blood_pressure'] ?? '--/--', Icons.bloodtype, Colors.blue),
                          ],
                        )
                      ],
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

  Widget _buildVital(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 9, color: Theme.of(context).hintColor)),
            Text(value, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11)),
          ],
        )
      ],
    );
  }

  Widget _buildSeverityBadge(String severity) {
    Color bgColor;
    Color textColor;
    
    if (severity == 'HIGH' || severity == 'CRITICAL') {
      bgColor = AppTheme.colorUrgent.withOpacity(0.1);
      textColor = AppTheme.colorUrgent;
    } else if (severity == 'MEDIUM') {
      bgColor = AppTheme.colorTotal.withOpacity(0.1);
      textColor = AppTheme.colorTotal;
    } else {
      bgColor = AppTheme.colorOnTrack.withOpacity(0.1);
      textColor = AppTheme.colorOnTrack;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        severity,
        style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
