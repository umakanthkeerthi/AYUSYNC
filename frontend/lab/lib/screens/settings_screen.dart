import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Settings',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
                const SizedBox(height: 24),
                
                // Profile Section
                _buildSectionCard(
                  title: 'Profile Settings',
                  icon: Icons.person_outline,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppTheme.brandActive.withOpacity(0.1),
                          child: const Text('LT', style: TextStyle(color: AppTheme.brandActive, fontSize: 24, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTextField(label: 'Full Name', initialValue: 'Lab Technician'),
                              const SizedBox(height: 16),
                              _buildTextField(label: 'Email Address', initialValue: 'technician@ayusync.com'),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.brandActive,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Save Profile'),
                      ),
                    )
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Lab Details Section
                _buildSectionCard(
                  title: 'Laboratory Details',
                  icon: Icons.science_outlined,
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildTextField(label: 'Laboratory Name', initialValue: 'City Central Diagnostics')),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTextField(label: 'Registration Number', initialValue: 'REG-2023-9981')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildTextField(label: 'Contact Number', initialValue: '+91 9876543210')),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTextField(label: 'Support Email', initialValue: 'support@citydiagnostics.com')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(label: 'Address', initialValue: '123 Health Avenue, Medical District, City', maxLines: 2),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.brandActive,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Update Lab Info'),
                      ),
                    )
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Preferences Section (Multilingual)
                _buildSectionCard(
                  title: 'Preferences',
                  icon: Icons.tune,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Language', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                              SizedBox(height: 4),
                              Text('Select your preferred system language', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: 'English',
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.borderColor)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.borderColor)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.brandActive, width: 2)),
                            ),
                            items: ['English', 'Hindi (हिंदी)', 'Telugu (తెలుగు)', 'Tamil (தமிழ்)'].map((String val) {
                              return DropdownMenuItem(value: val, child: Text(val));
                            }).toList(),
                            onChanged: (val) {},
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email Notifications', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                            SizedBox(height: 4),
                            Text('Receive alerts for critical test results', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                          ],
                        ),
                        Switch(
                          value: true,
                          onChanged: (val) {},
                          activeColor: AppTheme.brandActive,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.brandActive, size: 24),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({required String label, required String initialValue, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textDark)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          maxLines: maxLines,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.borderColor)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.borderColor)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.brandActive, width: 2)),
          ),
        ),
      ],
    );
  }
}
