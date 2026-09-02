import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/app_theme.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({Key? key}) : super(key: key);

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _isLoading = true;
  String _error = '';
  List<dynamic> _results = [];

  @override
  void initState() {
    super.initState();
    _fetchResults();
  }

  Future<void> _fetchResults() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8001/api/v1/lab/results'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _results = data['results'] ?? [];
            _isLoading = false;
          });
        } else {
          setState(() { _error = 'Failed to load results'; _isLoading = false; });
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
                const Text('Completed Results', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() { _isLoading = true; });
                    _fetchResults();
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
                      DataColumn(label: Text('Result')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Action')),
                    ],
                    rows: _results.map((r) {
                      Color color = Colors.green;
                      if (r['status'] == 'Low' || r['status'] == 'High') color = AppTheme.statOrange;
                      if (r['status'] == 'High (Critical)') color = AppTheme.statRed;
                      return _createDataRow(
                        r['id'] ?? 'Unknown',
                        r['patient'] ?? 'Unknown',
                        r['test'] ?? 'Unknown',
                        r['result'] ?? 'Unknown',
                        r['status'] ?? 'Unknown',
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

  DataRow _createDataRow(String id, String patient, String test, String result, String status, Color statusColor) {
    return DataRow(
      cells: [
        DataCell(Text(id, style: const TextStyle(fontWeight: FontWeight.w600))),
        DataCell(Text(patient, style: const TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w500))),
        DataCell(Text(test)),
        DataCell(Text(result, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold))),
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
            child: const Text('View Report', style: TextStyle(fontSize: 12)),
          ),
        ),
      ],
    );
  }
}
