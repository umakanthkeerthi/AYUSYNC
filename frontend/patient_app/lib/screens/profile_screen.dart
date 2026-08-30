import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/patient_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientProfileAsync = ref.watch(patientProfileProvider);
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: patientProfileAsync.when(
        data: (profile) => ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            _buildProfileHeader(profile?.name ?? 'Unknown', profile?.id ?? 'N/A')
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: -0.1),
            const SizedBox(height: 32),
            _buildHealthMetrics(profile?.bloodType ?? 'Unknown')
                .animate()
                .fadeIn(delay: 200.ms)
                .slideY(begin: 0.1),
            const SizedBox(height: 32),
            _buildSettingsList().animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildProfileHeader(String name, String patientId) {
    return Center(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primaryOrange, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryOrange.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/patient_avatar.jpg'),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Patient ID: $patientId',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetrics(String bloodType) {
    return Row(
      children: [
        Expanded(child: _buildMetricCard('Blood Group', bloodType, LucideIcons.droplet, Colors.red)),
        const SizedBox(width: 16),
        Expanded(child: _buildMetricCard('Height', '175 cm', LucideIcons.ruler, Colors.blue)),
        const SizedBox(width: 16),
        Expanded(child: _buildMetricCard('Weight', '72 kg', LucideIcons.activity, Colors.green)),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.textDark),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsTile('Personal Information', LucideIcons.userCircle),
          const Divider(height: 1, indent: 56),
          _buildSettingsTile('Medical Records', LucideIcons.folderHeart),
          const Divider(height: 1, indent: 56),
          _buildSettingsTile('Family Access', LucideIcons.users),
          const Divider(height: 1, indent: 56),
          _buildSettingsTile('Notifications', LucideIcons.bell),
          const Divider(height: 1, indent: 56),
          _buildSettingsTile('Privacy & Security', LucideIcons.lock),
          const Divider(height: 1, indent: 56),
          _buildSettingsTile('Sign Out', LucideIcons.logOut, isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(String title, IconData icon, {bool isDestructive = false}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red.withOpacity(0.1) : AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : AppTheme.primaryOrange,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDestructive ? Colors.red : AppTheme.textDark,
        ),
      ),
      trailing: isDestructive
          ? null
          : const Icon(LucideIcons.chevronRight, color: AppTheme.textMuted, size: 20),
      onTap: () {},
    );
  }
}
