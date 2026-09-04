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
        setState(() { _error = 'Server error: ${response.statusCode}'; _isLoading = false; });
      }
    } catch (e) {
      setState(() { _error = 'Error connecting to server'; _isLoading = false; });
    }
  }

  List<Map<String, dynamic>> _parseResults(dynamic rawResult) {
    if (rawResult == null) return [];
    if (rawResult is List) {
      return rawResult.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    if (rawResult is String) {
      try {
        final decoded = json.decode(rawResult);
        if (decoded is List) {
          return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        } else if (decoded is Map) {
          return [Map<String, dynamic>.from(decoded)];
        }
      } catch (_) {
        return [{'name': 'Result', 'result': rawResult, 'unit': '', 'range': '-'}];
      }
    }
    return [];
  }

  String _formatResultSummary(dynamic rawResult) {
    final parsed = _parseResults(rawResult);
    if (parsed.isEmpty) {
      if (rawResult is String && rawResult.isNotEmpty) return rawResult;
      return 'Completed';
    }
    final first = parsed.first;
    final name = first['name'] ?? 'Test';
    final val = first['result'] ?? '';
    final unit = first['unit'] ?? '';
    final summaryText = '$name: $val${unit.isNotEmpty ? ' $unit' : ''}';
    
    if (parsed.length > 1) {
      return '$summaryText (+${parsed.length - 1} more)';
    }
    return summaryText;
  }

  void _showReportDialog(BuildContext context, Map<String, dynamic> item) {
    final sampleId = item['id'] ?? 'N/A';
    final patient = item['patient'] ?? 'Unknown Patient';
    final testName = item['test'] ?? 'Lab Test';
    final status = item['status'] ?? 'Completed';
    final parsed = _parseResults(item['result']);

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 650,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.brandActive.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.assignment_outlined, color: AppTheme.brandActive, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(testName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
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

                // Patient Info Bar
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.brandBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 18, color: AppTheme.textSecondary),
                          const SizedBox(width: 6),
                          const Text('Patient: ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                          Text(patient, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark, fontSize: 13)),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.check_circle_outline, size: 18, color: Colors.green),
                          const SizedBox(width: 6),
                          const Text('Status: ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(status, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Detailed Parameters Table
                const Text('Test Parameters & Diagnostic Results', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                const SizedBox(height: 10),

                if (parsed.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text(item['result']?.toString() ?? 'No parameters recorded', style: const TextStyle(color: AppTheme.textSecondary))),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(2.5),
                        1: FlexColumnWidth(2),
                        2: FlexColumnWidth(2),
                        3: FlexColumnWidth(1.5),
                      },
                      children: [
                        TableRow(
                          decoration: const BoxDecoration(color: AppTheme.brandBg),
                          children: const [
                            Padding(padding: EdgeInsets.all(10), child: Text('Parameter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textDark))),
                            Padding(padding: EdgeInsets.all(10), child: Text('Value', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textDark))),
                            Padding(padding: EdgeInsets.all(10), child: Text('Ref. Range', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textDark))),
                            Padding(padding: EdgeInsets.all(10), child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textDark))),
                          ],
                        ),
                        ...parsed.map((param) {
                          final pName = param['name'] ?? '-';
                          final pVal = param['result'] ?? '-';
                          final pUnit = param['unit'] ?? '';
                          final pRange = param['range'] ?? '-';

                          return TableRow(
                            children: [
                              Padding(padding: const EdgeInsets.all(10), child: Text(pName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.textDark))),
                              Padding(padding: const EdgeInsets.all(10), child: Text('$pVal $pUnit'.trim(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.brandActive))),
                              Padding(padding: const EdgeInsets.all(10), child: Text('$pRange $pUnit'.trim(), style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary))),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('Normal', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                // Footer Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Downloading PDF report...'), duration: Duration(seconds: 2)),
                        );
                      },
                      icon: const Icon(Icons.download_outlined, size: 16),
                      label: const Text('Download PDF'),
                    ),
                    const SizedBox(width: 12),
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
                      DataColumn(label: Text('Test Name')),
                      DataColumn(label: Text('Result Summary')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Action')),
                    ],
                    rows: _results.map((r) {
                      Color color = Colors.green;
                      if (r['status'] == 'Low' || r['status'] == 'High') color = AppTheme.statOrange;
                      if (r['status'] == 'High (Critical)') color = AppTheme.statRed;
                      
                      final mapItem = Map<String, dynamic>.from(r as Map);
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

  DataRow _createDataRow(Map<String, dynamic> item, Color statusColor) {
    final id = item['id'] ?? 'Unknown';
    final patient = item['patient'] ?? 'Unknown';
    final test = item['test'] ?? 'Unknown';
    final summary = _formatResultSummary(item['result']);
    final status = item['status'] ?? 'Completed';

    return DataRow(
      cells: [
        DataCell(Text(id, style: const TextStyle(fontWeight: FontWeight.w600))),
        DataCell(Text(patient, style: const TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w500))),
        DataCell(Text(test)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.brandBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Text(
              summary,
              style: const TextStyle(color: AppTheme.textDark, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ),
        DataCell(
          ElevatedButton.icon(
            onPressed: () => _showReportDialog(context, item),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.brandActive,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.visibility_outlined, size: 16),
            label: const Text('View Report', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
