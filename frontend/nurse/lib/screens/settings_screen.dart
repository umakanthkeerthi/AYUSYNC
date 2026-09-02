import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic> _profile = {};
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8001/api/v1/nurse/profile'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _profile = data['profile'] ?? {};
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load profile';
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
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings & Profile',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, ),
            ),
            SizedBox(height: 32),
            ResponsiveBuilder(
              builder: (context, sizingInformation) {
                bool isMobile = sizingInformation.isMobile || sizingInformation.isTablet;
                
                Widget profileCard = Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: AppTheme.brandPrimary.withOpacity(0.1),
                              child: Text(_profile['name']?[0] ?? 'N', style: TextStyle(fontSize: 32, color: AppTheme.brandPrimary, fontWeight: FontWeight.bold)),
                            ),
                            SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_profile['name'] ?? 'Unknown', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                  Text(_profile['role'] ?? 'Nurse', style: TextStyle(fontSize: 16, color: Theme.of(context).hintColor)),
                                  SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.colorOnTrack.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text('Active Duty', style: TextStyle(color: AppTheme.colorOnTrack, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 48),
                        Text('Account Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Divider(height: 32),
                        _buildInfoRow('Employee ID', _profile['employee_id']),
                        _buildInfoRow('Department', _profile['department']),
                        _buildInfoRow('Email Address', _profile['email']),
                        _buildInfoRow('Phone Number', _profile['phone']),
                      ],
                    ),
                  ),
                );

                Widget preferencesCard = Column(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 24),
                            SwitchListTile(
                              title: Text('Push Notifications'),
                              value: true,
                              onChanged: (val) {},
                              activeColor: AppTheme.brandPrimary,
                            ),
                            SwitchListTile(
                              title: Text('Email Summaries'),
                              value: false,
                              onChanged: (val) {},
                              activeColor: AppTheme.brandPrimary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.go('/login');
                        },
                        icon: Icon(Icons.logout, color: Colors.red),
                        label: Text('Sign Out', style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                );

                if (isMobile) {
                  return Column(
                    children: [
                      profileCard,
                      SizedBox(height: 24),
                      preferencesCard,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: profileCard),
                    SizedBox(width: 24),
                    Expanded(flex: 1, child: preferencesCard),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text(label, style: TextStyle(color: Theme.of(context).hintColor, fontWeight: FontWeight.w500))),
          Expanded(child: Text(value ?? '--', style: TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
