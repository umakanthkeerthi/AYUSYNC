import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.brandBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings & Configuration',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 24),
            _buildSettingsSection(
              title: 'Account Profile',
              children: [
                _buildSettingsRow(Icons.person, 'Personal Information', 'Update your name, email, and contact details'),
                _buildSettingsRow(Icons.security, 'Security & Password', 'Change password and set up 2FA'),
              ],
            ),
            const SizedBox(height: 24),
            _buildSettingsSection(
              title: 'Insurance Preferences',
              children: [
                _buildSettingsRow(Icons.business, 'Hospital Billing Details', 'Manage hospital NPI and tax information'),
                _buildSettingsRow(Icons.notifications, 'Alerts & Notifications', 'Configure email and SMS alerts for claim status'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsRow(IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.brandBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.brandActive),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textSecondary),
      onTap: () {},
    );
  }
}
