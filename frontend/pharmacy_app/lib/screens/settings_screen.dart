import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../utils/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _urgentAlerts = true;
  bool _stockAlerts = true;
  bool _emailSummary = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;
        final double padding = isMobile ? 16.0 : 32.0;

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: PharmacyTheme.textDark)),
              const SizedBox(height: 4),
              const Text('Manage your preferences and account settings.', style: TextStyle(color: PharmacyTheme.textSecondary, fontSize: 15)),
              const SizedBox(height: 32),
              Wrap(
                spacing: 32,
                runSpacing: 32,
                crossAxisAlignment: WrapCrossAlignment.start,
                children: [
                  SizedBox(width: isMobile ? double.infinity : 400, child: _buildProfileCard()),
                  SizedBox(width: isMobile ? double.infinity : 400, child: _buildNotificationsCard()),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: PharmacyTheme.cardRadius,
        border: Border.all(color: PharmacyTheme.border),
        boxShadow: PharmacyTheme.premiumShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Profile Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: PharmacyTheme.textDark)),
          const SizedBox(height: 8),
          const Text('Update your account details.', style: TextStyle(color: PharmacyTheme.textSecondary, fontSize: 13)),
          const Divider(height: 48, color: PharmacyTheme.border),
          const Text('Name', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: PharmacyTheme.textDark)),
          const SizedBox(height: 8),
          const TextField(
            decoration: InputDecoration(
              hintText: 'Admin',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Role', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: PharmacyTheme.textDark)),
          const SizedBox(height: 8),
          const TextField(
            decoration: InputDecoration(
              hintText: 'Lead Pharmacist',
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Save Profile'),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNotificationsCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: PharmacyTheme.cardRadius,
        border: Border.all(color: PharmacyTheme.border),
        boxShadow: PharmacyTheme.premiumShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: PharmacyTheme.textDark)),
          const SizedBox(height: 8),
          const Text('Manage your alert preferences.', style: TextStyle(color: PharmacyTheme.textSecondary, fontSize: 13)),
          const Divider(height: 48, color: PharmacyTheme.border),
          
          _buildToggle('Urgent Prescription Alerts', 'Receive alerts for critical prescriptions', _urgentAlerts, (val) => setState(() => _urgentAlerts = val)),
          const SizedBox(height: 24),
          _buildToggle('Low Stock Alerts', 'Get notified when inventory is low', _stockAlerts, (val) => setState(() => _stockAlerts = val)),
          const SizedBox(height: 24),
          _buildToggle('Email Daily Summary', 'Receive a daily recap at 6:00 PM', _emailSummary, (val) => setState(() => _emailSummary = val)),
        ],
      ),
    );
  }

  Widget _buildToggle(String label, String description, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: PharmacyTheme.textDark, fontSize: 14)),
              const SizedBox(height: 4),
              Text(description, style: const TextStyle(color: PharmacyTheme.textSecondary, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: PharmacyTheme.primary,
        ),
      ],
    );
  }
}
