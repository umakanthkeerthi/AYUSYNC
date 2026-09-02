import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/app_theme.dart';

class SamplesScreen extends StatefulWidget {
  const SamplesScreen({Key? key}) : super(key: key);

  @override
  State<SamplesScreen> createState() => _SamplesScreenState();
}

class _SamplesScreenState extends State<SamplesScreen> {
  bool _isLoading = true;
  String _error = '';
  List<dynamic> _samples = [];

  @override
  void initState() {
    super.initState();
    _fetchSamples();
  }

  Future<void> _fetchSamples() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8001/api/v1/lab/samples'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _samples = data['samples'] ?? [];
            _isLoading = false;
          });
        } else {
          setState(() { _error = 'Failed to load samples'; _isLoading = false; });
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
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error.isNotEmpty) return Scaffold(body: Center(child: Text(_error, style: const TextStyle(color: Colors.red))));

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('All Samples', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() { _isLoading = true; });
                    _fetchSamples();
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Refresh'),
                )
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 1000),
                  child: DataTable(
                    columnSpacing: 24,
                    horizontalMargin: 24,
                    headingTextStyle: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark),
                    dataTextStyle: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                    columns: const [
                      DataColumn(label: Text('Sample ID')),
                      DataColumn(label: Text('Patient')),
                      DataColumn(label: Text('Test')),
                      DataColumn(label: Text('Type')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Action')),
                    ],
                    rows: _samples.map((s) {
                      Color color = AppTheme.statPurple;
                      if (s['status'] == 'Completed' || s['status'] == 'Results Ready') color = Colors.green;
                      if (s['status'] == 'Collected') color = AppTheme.statBlue;
                      return _createDataRow(
                        s['id'] ?? 'Unknown',
                        s['patient'] ?? 'Unknown',
                        s['test'] ?? 'Unknown',
                        s['type'] ?? 'Blood',
                        s['status'] ?? 'Unknown',
                        color
                      );
                    }).toList(),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  DataRow _createDataRow(String id, String patient, String test, String type, String status, Color statusColor) {
    return DataRow(
      cells: [
        DataCell(Text(id, style: const TextStyle(fontWeight: FontWeight.w600))),
        DataCell(Text(patient, style: const TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w500))),
        DataCell(Text(test)),
        DataCell(Text(type)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ),
        DataCell(
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
            ),
            child: const Text('View Details', style: TextStyle(fontSize: 12)),
          ),
        ),
      ],
    );
  }
}
