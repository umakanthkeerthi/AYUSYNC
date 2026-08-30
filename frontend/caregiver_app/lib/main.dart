import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'utils/theme.dart';
import 'screens/home_tab.dart';
import 'screens/schedule_tab.dart';
import 'screens/chat_tab.dart';

import 'package:flutter_animate/flutter_animate.dart';

void main() {
  runApp(const CaregiverApp());
}

class CaregiverApp extends StatelessWidget {
  const CaregiverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AyuSync Caregiver',
      theme: AyuTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const MainLayout(),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const HomeTab(),
    const ScheduleTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _tabs[_currentIndex],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AyuTheme.primary.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, LucideIcons.home, 'Home'),
                _buildNavItem(1, LucideIcons.calendar, 'Schedule'),
                _buildNavItem(2, LucideIcons.messageSquare, 'Chat', pushesRoute: true, route: const ChatTab()),
              ],
            ),
          ),
        ),
      ).animate().slideY(begin: 1, duration: 500.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, {bool pushesRoute = false, Widget? route}) {
    final isSelected = !pushesRoute && _currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        if (pushesRoute && route != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => route));
        } else {
          setState(() {
            _currentIndex = index;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AyuTheme.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AyuTheme.primary : AyuTheme.textMuted,
              size: 20,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AyuTheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ).animate().fadeIn().slideX(),
            ]
          ],
        ),
      ),
    );
  }
}
