import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:responsive_builder/responsive_builder.dart';
import '../theme/app_theme.dart';

class HomeVisitsScreen extends StatefulWidget {
  const HomeVisitsScreen({Key? key}) : super(key: key);

  @override
  State<HomeVisitsScreen> createState() => _HomeVisitsScreenState();
}

class _HomeVisitsScreenState extends State<HomeVisitsScreen> {
  bool _isLoading = true;
  String _error = '';
  List<dynamic> _visits = [];

  @override
  void initState() {
    super.initState();
    _fetchVisits();
  }

  Future<void> _fetchVisits() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8001/api/v1/nurse/visits'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('visits')) {
          setState(() {
            _visits = data['visits'] ?? [];
            _isLoading = false;
          });
        } else {
          setState(() { _error = 'Failed to load visits'; _isLoading = false; });
        }
      } else {
        setState(() { _error = 'Server error'; _isLoading = false; });
      }
    } catch (e) {
      setState(() { _error = 'Error connecting to server'; _isLoading = false; });
    }
  }

  void _showNoteModal(BuildContext context, String visitId, String patientName) {
    final TextEditingController _notesController = TextEditingController();
    bool _isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text('Log Visit Notes: $patientName'),
              content: SizedBox(
                width: 500,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Enter clinical observations and notes for ingestion by the Nurse Agent.', style: TextStyle(color: Theme.of(context).hintColor, fontSize: 13)),
                    SizedBox(height: 16),
                    TextField(
                      controller: _notesController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Vitals stable. Wound dressing changed successfully. Patient reported mild discomfort...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : () async {
                    if (_notesController.text.trim().isEmpty) return;
                    setModalState(() { _isSubmitting = true; });
                    
                    try {
                      final response = await http.post(
                        Uri.parse('http://127.0.0.1:8001/api/v1/nurse/visits/$visitId/notes'),
                        headers: {'Content-Type': 'application/json'},
                        body: json.encode({"notes": _notesController.text.trim()})
                      );
                      
                      if (response.statusCode == 200) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Notes successfully ingested & published to Event Bus!'), backgroundColor: AppTheme.colorOnTrack)
                        );
                        _fetchVisits(); // refresh
                      } else {
                        setModalState(() { _isSubmitting = false; });
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to submit notes'), backgroundColor: Colors.red));
                      }
                    } catch (e) {
                      setModalState(() { _isSubmitting = false; });
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Network error'), backgroundColor: Colors.red));
                    }
                  },
                  child: _isSubmitting ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text('Submit Notes'),
                )
              ],
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error.isNotEmpty) return Scaffold(body: Center(child: Text(_error, style: TextStyle(color: Colors.red))));

    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Home Visits Schedule', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() { _isLoading = true; });
                      _fetchVisits();
                    },
                    icon: Icon(Icons.refresh, size: 18),
                    label: Text('Refresh'),
                  )
                ],
              ),
              SizedBox(height: 24),
              if (_visits.isEmpty)
                Center(child: Padding(padding: EdgeInsets.all(48.0), child: Text('No upcoming visits', style: TextStyle(color: Theme.of(context).hintColor, fontSize: 16))))
              else
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: _visits.map((v) => _buildVisitCard(context, v, sizingInformation)).toList(),
                )
            ],
          ),
        );
      },
    );
  }

  Widget _buildVisitCard(BuildContext context, dynamic visit, SizingInformation sizing) {
    double width = sizing.deviceScreenType == DeviceScreenType.mobile ? double.infinity : 350;
    
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppTheme.brandPrimary.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.house_outlined, color: AppTheme.brandPrimary),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(visit['patient_name'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(visit['assessment_type'] ?? 'In-home Assessment', style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Theme.of(context).hintColor),
                    SizedBox(width: 8),
                    Text(visit['date'], style: TextStyle(fontSize: 14)),
                    const Spacer(),
                    Icon(Icons.access_time, size: 16, color: Theme.of(context).hintColor),
                    SizedBox(width: 8),
                    Text(visit['time'], style: TextStyle(fontSize: 14)),
                  ],
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showNoteModal(context, visit['visit_id'], visit['patient_name']),
                    icon: Icon(Icons.edit_note),
                    label: Text('Log Visit Notes'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppTheme.brandPrimary,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
