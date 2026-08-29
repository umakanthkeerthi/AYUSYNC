import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'utils/theme.dart';
import 'screens/home_tab.dart';
import 'screens/trip_tab.dart';
import 'screens/history_tab.dart';
import 'screens/profile_tab.dart';

void main() {
  runApp(const DriverApp());
}

class DriverApp extends StatelessWidget {
  const DriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareOS Driver',
      theme: DriverTheme.darkTheme,
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
  bool _hasActiveTrip = false;

  void _acceptTrip() {
    setState(() {
      _hasActiveTrip = true;
      _currentIndex = 1; // Jump to Trip Tab
    });
  }

  void _completeTrip() {
    setState(() {
      _hasActiveTrip = false;
      _currentIndex = 0; // Jump back to Home Tab
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      HomeTab(onAcceptTrip: _acceptTrip),
      _hasActiveTrip 
          ? TripTab(onCompleteTrip: _completeTrip)
          : const Center(child: Text("No Active Trip. Waiting for SOS requests...", style: TextStyle(color: DriverTheme.textMuted))),
      const HistoryTab(),
      const ProfileTab(),
    ];

    return Scaffold(
      body: SafeArea(
        child: tabs[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: DriverTheme.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: DriverTheme.background,
          selectedItemColor: DriverTheme.primary,
          unselectedItemColor: DriverTheme.textMuted,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.navigation),
              label: 'Active Trip',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.user),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
