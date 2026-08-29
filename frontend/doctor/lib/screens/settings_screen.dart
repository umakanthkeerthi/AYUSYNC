import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Account Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Card(
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: AppTheme.brandBg,
                        child: Text('👨‍⚕️', style: TextStyle(fontSize: 40)),
                      ),
                      const SizedBox(width: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Dr. Anil Mehta', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text('Chief Cardiologist', style: TextStyle(color: AppTheme.textSecondary)),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: () {},
                            child: const Text('Change Photo'),
                          )
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text('Email Address', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: 'dr.mehta@ayusync.com',
                    readOnly: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppTheme.brandBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppTheme.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppTheme.borderColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Notification Preferences', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Checkbox(value: true, onChanged: (v) {}, activeColor: AppTheme.brandActive),
                      const Text('Email alerts for critical patients'),
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(value: true, onChanged: (v) {}, activeColor: AppTheme.brandActive),
                      const Text('SMS alerts for new messages'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Save Changes'),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
