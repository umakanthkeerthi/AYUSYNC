import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  String _error = '';
  Map<String, dynamic> _dashboardData = {
    'metrics': {
      'urgent_count': 0,
      'follow_up_count': 0,
      'on_track_count': 0,
      'total_patients': 0
    },
    'patient_queue': []
  };

  @override
  void initState() {
    super.initState();
    _fetchDashboard();
  }

  Future<void> _fetchDashboard() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8001/api/v1/nurse/dashboard'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('metrics')) {
          setState(() {
            _dashboardData = data;
            _isLoading = false;
          });
        } else {
          setState(() { _error = 'Failed to load dashboard'; _isLoading = false; });
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

    final metrics = _dashboardData['metrics'] as Map<String, dynamic>? ?? {};
    final urgent = metrics['urgent_count']?.toString() ?? '0';
    final followup = metrics['follow_up_count']?.toString() ?? '0';
    final ontrack = metrics['on_track_count']?.toString() ?? '0';
    final total = metrics['total_patients']?.toString() ?? '0';
    final queue = _dashboardData['patient_queue'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 280,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 110,
            ),
            children: [
              _MetricCard(title: 'Urgent', value: urgent, subtitle: 'Needs attention', color: AppTheme.colorUrgent, isActive: false),
              _MetricCard(title: 'Follow-up', value: followup, subtitle: 'Pending tasks', color: AppTheme.colorFollowup, isActive: false),
              _MetricCard(title: 'On Track', value: ontrack, subtitle: 'Completed tasks', color: AppTheme.colorOnTrack, isActive: false),
              _MetricCard(title: 'Total Patients', value: total, subtitle: 'Under care', color: AppTheme.colorTotal, isActive: true),
            ],
          ),
          SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      Text('Patient Queue', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: 250,
                            height: 40,
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search patients, tasks...',
                                prefixIcon: Icon(Icons.search, size: 20),
                                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() { _isLoading = true; });
                              _fetchDashboard();
                            },
                            icon: Icon(Icons.refresh, size: 18),
                            label: Text('Refresh'),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                const Divider(height: 1),
                if (queue.isEmpty)
                  Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: Text("No patients in queue", style: TextStyle(color: Theme.of(context).hintColor))),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: queue.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = queue[index];
                      return _PatientQueueRow(
                        name: item['patient_name'] ?? 'Unknown',
                        severity: item['severity'] ?? 'LOW',
                        time: item['added_time'] ?? '',
                        reason: item['reason'] ?? 'Triage Review',
                      );
                    },
                  )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final bool isActive;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isActive ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isActive ? color : AppTheme.borderColor,
          width: isActive ? 2 : 1,
        ),
      ),
      color: isActive ? color.withOpacity(0.05) : AppTheme.bgCard,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color, height: 1)),
            SizedBox(height: 4),
            Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            SizedBox(height: 2),
            Text(subtitle, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _PatientQueueRow extends StatelessWidget {
  final String name;
  final String severity;
  final String time;
  final String reason;
  
  const _PatientQueueRow({required this.name, required this.severity, required this.time, this.reason = 'Triage Review'});

  @override
  Widget build(BuildContext context) {
    bool isUrgent = severity == 'HIGH';
    
    String formattedTime = time;

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.borderColor,
                    child: Icon(Icons.person, color: Theme.of(context).hintColor),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 4),
                        Text(reason, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 14)),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.schedule, size: 14, color: Theme.of(context).hintColor),
                            SizedBox(width: 4),
                            Expanded(child: Text('Added at $formattedTime', style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12), overflow: TextOverflow.ellipsis)),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                if (isUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('Urgent', style: TextStyle(color: AppTheme.colorUrgent, fontSize: 12, fontWeight: FontWeight.bold)),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(severity, style: TextStyle(color: AppTheme.colorFollowup, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                SizedBox(width: 16),
                Icon(Icons.chevron_right, color: Theme.of(context).hintColor),
              ],
            )
          ],
        ),
      ),
    );
  }
}
