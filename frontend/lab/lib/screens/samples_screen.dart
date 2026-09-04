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

  void _showSampleDetailsDialog(BuildContext context, Map<String, dynamic> sample) {
    final sampleId = sample['id'] ?? 'N/A';
    final patient = sample['patient'] ?? 'Unknown Patient';
    final testName = sample['test'] ?? 'Lab Test';
    final type = sample['type'] ?? 'Blood';
    final status = sample['status'] ?? 'Collected';

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.statPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.science_outlined, color: AppTheme.statPurple, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(testName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                            Text('Sample ID: $sampleId', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                _buildDetailRow('Patient Name', patient),
                const SizedBox(height: 12),
                _buildDetailRow('Sample Type', type),
                const SizedBox(height: 12),
                _buildDetailRow('Collection Status', status),
                const SizedBox(height: 12),
                _buildDetailRow('Storage Location', 'Cold Storage - Rack B4'),
                const SizedBox(height: 12),
                _buildDetailRow('Handling Protocol', 'Standard Blood Specimen (2-8°C)'),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.brandActive,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
      ],
    );
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
                      
                      final mapItem = Map<String, dynamic>.from(s as Map);
                      return _createDataRow(mapItem, color);
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

  DataRow _createDataRow(Map<String, dynamic> sample, Color statusColor) {
    final id = sample['id'] ?? 'Unknown';
    final patient = sample['patient'] ?? 'Unknown';
    final test = sample['test'] ?? 'Unknown';
    final type = sample['type'] ?? 'Blood';
    final status = sample['status'] ?? 'Unknown';

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
          OutlinedButton.icon(
            onPressed: () => _showSampleDetailsDialog(context, sample),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: Size.zero,
            ),
            icon: const Icon(Icons.info_outline, size: 14),
            label: const Text('View Details', style: TextStyle(fontSize: 12)),
          ),
        ),
      ],
    );
  }
}
