import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/app_theme.dart';

class LabScreen extends StatefulWidget {
  const LabScreen({Key? key}) : super(key: key);

  @override
  State<LabScreen> createState() => _LabScreenState();
}

class _LabScreenState extends State<LabScreen> {
  bool _isLoading = true;
  String _error = '';
  List<dynamic> _labs = [];

  @override
  void initState() {
    super.initState();
    _fetchLabs();
  }

  Future<void> _fetchLabs() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8001/api/v1/nurse/labs'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _labs = data['labs'] ?? [];
            _isLoading = false;
          });
        } else {
          setState(() { _error = 'Failed to load labs'; _isLoading = false; });
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
    if (_error.isNotEmpty) return Scaffold(body: Center(child: Text(_error, style: TextStyle(color: Colors.red))));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Lab Coordination', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() { _isLoading = true; });
                  _fetchLabs();
                },
                icon: Icon(Icons.refresh, size: 18),
                label: Text('Refresh'),
              ),
            ],
          ),
          SizedBox(height: 24),
          if (_labs.isEmpty)
            Center(child: Text("No lab orders found.", style: TextStyle(color: Theme.of(context).hintColor)))
          else
            Card(
              clipBehavior: Clip.antiAlias,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingTextStyle: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).hintColor),
                  dataRowMinHeight: 60,
                  dataRowMaxHeight: 60,
                  columns: const [
                    DataColumn(label: Text('Patient')),
                    DataColumn(label: Text('Test Type')),
                    DataColumn(label: Text('Date Ordered')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: _labs.map((lab) {
                    return _buildRow(
                      lab['patient_name'] ?? 'Unknown',
                      lab['test_type'] ?? 'Unknown Test',
                      lab['date'] ?? '',
                      lab['status'] ?? 'Pending',
                      (lab['status'] ?? '') == 'Completed'
                    );
                  }).toList(),
                ),
              ),
            )
        ],
      ),
    );
  }

  DataRow _buildRow(String name, String testType, String date, String status, bool isComplete) {
    Color statusColor;
    if (status == 'Completed' || status == 'Results Ready') {
      statusColor = AppTheme.colorOnTrack;
    } else if (status == 'In Progress' || status == 'Processing') {
      statusColor = AppTheme.colorTotal;
    } else {
      statusColor = AppTheme.colorFollowup;
    }

    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.borderColor,
                child: Icon(Icons.person, size: 20, color: Theme.of(context).hintColor),
              ),
              SizedBox(width: 12),
              Text(name, style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        DataCell(Text(testType)),
        DataCell(Text(date)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
        DataCell(
          isComplete 
            ? TextButton(onPressed: () {}, child: Text('View Results'))
            : OutlinedButton(onPressed: () {}, child: Text('Follow Up'))
        ),
      ],
    );
  }
}

