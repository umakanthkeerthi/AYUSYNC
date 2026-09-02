import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  bool _isLoading = true;
  String _error = '';
  List<dynamic> _tasks = [];

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8001/api/v1/nurse/tasks'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _tasks = data['tasks'] ?? [];
            _isLoading = false;
          });
        } else {
          setState(() { _error = 'Failed to load tasks'; _isLoading = false; });
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

    final pending = _tasks.where((t) => t['status'] == 'Pending').toList();
    final inProgress = _tasks.where((t) => t['status'] == 'In Progress').toList();
    final completed = _tasks.where((t) => t['status'] == 'Completed').toList();

    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        bool isMobile = sizingInformation.deviceScreenType == DeviceScreenType.mobile;

        Widget board = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildColumn(context, 'Pending', AppTheme.colorFollowup, pending)),
            SizedBox(width: 24),
            Expanded(child: _buildColumn(context, 'In Progress', AppTheme.colorTotal, inProgress)),
            SizedBox(width: 24),
            Expanded(child: _buildColumn(context, 'Completed', AppTheme.colorOnTrack, completed)),
          ],
        );

        if (isMobile) {
          board = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildColumn(context, 'Pending', AppTheme.colorFollowup, pending),
              SizedBox(height: 16),
              _buildColumn(context, 'In Progress', AppTheme.colorTotal, inProgress),
              SizedBox(height: 16),
              _buildColumn(context, 'Completed', AppTheme.colorOnTrack, completed),
            ],
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Task Management', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 12,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() { _isLoading = true; });
                          _fetchTasks();
                        },
                        icon: Icon(Icons.refresh, size: 18),
                        label: Text('Refresh'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.add, size: 18),
                        label: Text('Add Task'),
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(height: 24),
              board,
            ],
          ),
        );
      },
    );
  }

  Widget _buildColumn(BuildContext context, String title, Color badgeColor, List<dynamic> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(items.length.toString(), style: TextStyle(color: badgeColor, fontSize: 12, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const Divider(height: 32),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Center(child: Text('No tasks', style: TextStyle(color: Theme.of(context).hintColor))),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => SizedBox(height: 12),
              itemBuilder: (context, index) {
                final task = items[index];
                return _TaskCard(
                  description: task['description'] ?? 'No Description',
                  patientName: task['patient_name'] ?? 'Unknown',
                  time: task['due_time'] ?? '',
                  type: task['type'] ?? 'CARE_TASK',
                );
              },
            )
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final String description;
  final String patientName;
  final String time;
  final String type;

  const _TaskCard({
    required this.description,
    required this.patientName,
    required this.time,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    String formattedTime = time;
    try {
      if (time.isNotEmpty) {
        final dt = DateTime.parse(time);
        formattedTime = DateFormat('h:mm a').format(dt);
      }
    } catch (_) {}

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(description, style: TextStyle(fontWeight: FontWeight.w600))),
              if (type == 'TRIAGE')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(4)),
                  child: Text('Triage', style: TextStyle(color: AppTheme.colorUrgent, fontSize: 10, fontWeight: FontWeight.bold)),
                )
            ],
          ),
          SizedBox(height: 4),
          Text('Patient: $patientName', style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12)),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.schedule, size: 14, color: Theme.of(context).hintColor),
                  SizedBox(width: 4),
                  Text(formattedTime, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12)),
                ],
              ),
              Icon(Icons.more_horiz, color: Theme.of(context).hintColor, size: 16),
            ],
          )
        ],
      ),
    );
  }
}

