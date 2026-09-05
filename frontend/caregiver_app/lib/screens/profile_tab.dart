import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../utils/theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/glass_card.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF0FDFA), AyuTheme.bgApp],
          stops: [0.0, 0.3],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              children: [
                _buildCenterAvatar().animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.9, 0.9)),
                const SizedBox(height: 32),
                const Text('ACCOUNT SETTINGS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AyuTheme.textMuted, letterSpacing: 1.2)).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 16),
                _buildSettingsTile(LucideIcons.globe, 'Language Preference', 'English (US)').animate().fadeIn(delay: 400.ms).slideX(begin: 0.1),
                _buildSettingsTile(LucideIcons.bell, 'Notification Settings', 'All enabled').animate().fadeIn(delay: 500.ms).slideX(begin: 0.1),
                _buildSettingsTile(LucideIcons.lock, 'Privacy & Security', null).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1),
                
                const SizedBox(height: 32),
                const Text('SUPPORT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AyuTheme.textMuted, letterSpacing: 1.2)).animate().fadeIn(delay: 700.ms),
                const SizedBox(height: 16),
                _buildSettingsTile(LucideIcons.helpCircle, 'Help Center', null).animate().fadeIn(delay: 800.ms).slideX(begin: 0.1),
                _buildSettingsTile(LucideIcons.logOut, 'Log Out', null, isDestructive: true).animate().fadeIn(delay: 900.ms).slideX(begin: 0.1),
                const SizedBox(height: 100), // Space for nav bar
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 16, left: 16, right: 24, bottom: 16),
        color: Colors.transparent,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(LucideIcons.arrowLeft, color: AyuTheme.textMain),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 8),
            const Text(
              'Profile',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w900,
                color: AyuTheme.textMain,
              ),
            ),
          ],
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
              child: CircleAvatar(
                radius: 48,
                backgroundColor: AyuTheme.primary.withOpacity(0.1),
                child: const Icon(LucideIcons.user, size: 48, color: AyuTheme.primary),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Giri',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AyuTheme.textMain),
          ),
          const SizedBox(height: 4),
          const Text(
            'Primary Family Caregiver',
            style: TextStyle(fontSize: 11, color: AyuTheme.primary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(color: AyuTheme.border.withOpacity(0.5), borderRadius: BorderRadius.circular(20)),
            child: const Text('Relationship: Son', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AyuTheme.textMuted)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String? value, {bool isDestructive = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDestructive ? Colors.red.withOpacity(0.1) : AyuTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 17, color: isDestructive ? Colors.red : AyuTheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: isDestructive ? Colors.red : AyuTheme.textMain,
                ),
              ),
            ),
            if (value != null) ...[
              Text(value, style: const TextStyle(fontSize: 11, color: AyuTheme.textMuted, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
            ],
            Icon(LucideIcons.chevronRight, size: 17, color: AyuTheme.textMuted.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}
