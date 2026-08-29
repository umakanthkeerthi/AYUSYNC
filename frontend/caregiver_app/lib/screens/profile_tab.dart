import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../utils/theme.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            children: [
              _buildCenterAvatar(),
              const SizedBox(height: 32),
              const Text('ACCOUNT SETTINGS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AyuTheme.textMuted, letterSpacing: 1.2)),
              const SizedBox(height: 16),
              _buildSettingsTile(LucideIcons.globe, 'Language Preference', 'English (US)'),
              _buildSettingsTile(LucideIcons.bell, 'Notification Settings', 'All enabled'),
              _buildSettingsTile(LucideIcons.lock, 'Privacy & Security', null),
              
              const SizedBox(height: 32),
              const Text('SUPPORT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AyuTheme.textMuted, letterSpacing: 1.2)),
              const SizedBox(height: 16),
              _buildSettingsTile(LucideIcons.helpCircle, 'Help Center', null),
              _buildSettingsTile(LucideIcons.logOut, 'Log Out', null, isDestructive: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 24),
      decoration: const BoxDecoration(
        color: AyuTheme.surface,
        boxShadow: [BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: const Text(
        'Profile',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          fontFamily: 'Outfit',
          color: AyuTheme.textMain,
        ),
      ),
    );
  }

  Widget _buildCenterAvatar() {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AyuTheme.primaryGradient,
              boxShadow: AyuTheme.glowShadow,
            ),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: AyuTheme.bgApp, shape: BoxShape.circle),
              child: const CircleAvatar(
                radius: 48,
                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1590611936760-eeb9bc5031ce?auto=format&fit=crop&w=300&q=80'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Dr. Sarah Jenkins',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'Outfit', color: AyuTheme.textMain),
          ),
          const SizedBox(height: 4),
          const Text(
            'Certified Healthcare Companion',
            style: TextStyle(fontSize: 14, color: AyuTheme.primary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(color: AyuTheme.border, borderRadius: BorderRadius.circular(20)),
            child: const Text('Assigned Patients: 3', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AyuTheme.textMuted)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String? value, {bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AyuTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AyuTheme.softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDestructive ? Colors.red.withOpacity(0.1) : AyuTheme.bgApp,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: isDestructive ? Colors.red : AyuTheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isDestructive ? Colors.red : AyuTheme.textMain,
              ),
            ),
          ),
          if (value != null) ...[
            Text(value, style: const TextStyle(fontSize: 13, color: AyuTheme.textMuted, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
          ],
          Icon(LucideIcons.chevronRight, size: 20, color: AyuTheme.border.withOpacity(0.8)),
        ],
      ),
    );
  }
}
