import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'home_screen.dart';
import 'chat_screen.dart';
import 'health_hub_screen.dart';
import 'plan_screen.dart';
import 'upload_record_screen.dart';
import 'profile_screen.dart';
import '../theme/app_theme.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const PlanScreen(),
    const HealthHubScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const UploadRecordScreen()));
        },
        backgroundColor: AppTheme.primaryOrange,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(LucideIcons.scanLine, color: Colors.white, size: 28),
      ).animate().scale(delay: 200.ms, duration: 400.ms, curve: Curves.easeOutBack),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 20,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(0, LucideIcons.home, 'Home'),
                    _buildNavItem(1, LucideIcons.calendar, 'Plan'),
                  ],
                ),
              ),
              const SizedBox(width: 48), // Notch space
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(2, LucideIcons.layoutGrid, 'Hub'),
                    _buildNavItem(3, LucideIcons.user, 'Profile'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ).animate().slideY(begin: 1, duration: 500.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryOrange : AppTheme.textMuted,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? AppTheme.primaryOrange : AppTheme.textMuted,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
