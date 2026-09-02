import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'utils/theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/refills_screen.dart';
import 'screens/deliveries_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/settings_screen.dart';

import 'screens/login_screen.dart';

void main() {
  runApp(const PharmacyApp());
}

class PharmacyApp extends StatelessWidget {
  const PharmacyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AyuSync Pharmacy',
      theme: PharmacyTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const RefillsScreen(),
    const DeliveriesScreen(),
    const InventoryScreen(),
    const ReportsScreen(),
    const SettingsScreen(),
  ];

  final List<NavigationDestinationData> _destinations = [
    NavigationDestinationData('Prescriptions', LucideIcons.fileText),
    NavigationDestinationData('Refills', LucideIcons.rotateCcw),
    NavigationDestinationData('Deliveries', LucideIcons.truck),
    NavigationDestinationData('Inventory', LucideIcons.package),
    NavigationDestinationData('Reports', LucideIcons.barChart2),
    NavigationDestinationData('Settings', LucideIcons.settings),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 800;

        return Scaffold(
          appBar: isMobile
              ? AppBar(
                  backgroundColor: PharmacyTheme.sidebar,
                  iconTheme: const IconThemeData(color: Colors.white),
                  title: const Row(
                    children: [
                      Icon(LucideIcons.pill, color: PharmacyTheme.statOrange),
                      SizedBox(width: 8),
                      Text('AyuSync Pharmacy', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              : null,
          drawer: isMobile ? _buildDrawer() : null,
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                // Desktop Sidebar
                if (!isMobile)
                  Container(
                    width: 260,
                    decoration: BoxDecoration(
                      color: PharmacyTheme.sidebar,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: PharmacyTheme.premiumShadow,
                    ),
                    child: Column(
                      children: [
                        // Logo
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(LucideIcons.pill, color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 14),
                              const Text(
                                'AyuSync\nPharmacy',
                                style: TextStyle(color: Colors.white, fontSize: 18, height: 1.1, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                              ),
                            ],
                          ),
                        ),
                        // Main Navigation
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            children: [
                              for (int i = 0; i < 5; i++) _buildNavItem(i, _destinations[i]),
                            ],
                          ),
                        ),
                        // Bottom Navigation
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildNavItem(5, _destinations[5]), // Settings
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                // Main Workspace
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24.0),
                    child: Column(
                      children: [
                        // Top Header
                        Container(
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: PharmacyTheme.premiumShadow,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            children: [
                              Text(_destinations[_selectedIndex].label, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: PharmacyTheme.textDark, letterSpacing: -0.5)),
                              const Spacer(),
                              _buildGlobalSearch(),
                              const SizedBox(width: 24),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: PharmacyTheme.background,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(LucideIcons.bell, color: PharmacyTheme.textSecondary, size: 20),
                              ),
                              const SizedBox(width: 20),
                              _buildProfileIndicator(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Main Content
                        Expanded(
                          child: _screens[_selectedIndex],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlobalSearch() {
    return SizedBox(
      width: 320,
      height: 48,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search patients, medications...',
          prefixIcon: const Icon(LucideIcons.search, size: 18, color: PharmacyTheme.textSecondary),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          border: OutlineInputBorder(borderRadius: PharmacyTheme.pillRadius, borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: PharmacyTheme.pillRadius, borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: PharmacyTheme.pillRadius, borderSide: const BorderSide(color: PharmacyTheme.primary, width: 2)),
          fillColor: PharmacyTheme.background,
        ),
      ),
    );
  }

  Widget _buildProfileIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: PharmacyTheme.background,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 18, backgroundColor: PharmacyTheme.primary.withOpacity(0.1), child: const Text('👩‍⚕️', style: TextStyle(fontSize: 18))),
          const SizedBox(width: 12),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Admin', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: PharmacyTheme.textDark, height: 1)),
              Text('Pharmacist', style: TextStyle(fontSize: 12, color: PharmacyTheme.textSecondary, height: 1.5, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(width: 12),
          const Icon(LucideIcons.chevronDown, size: 16, color: PharmacyTheme.textSecondary),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: PharmacyTheme.sidebar,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white12)),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.pill, color: PharmacyTheme.statOrange, size: 32),
                SizedBox(width: 12),
                Text('AyuSync Pharmacy', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          ..._destinations.asMap().entries.map((entry) {
            final int index = entry.key;
            final NavigationDestinationData dest = entry.value;
            final bool isSelected = _selectedIndex == index;
            
            return ListTile(
              leading: Icon(dest.icon, color: isSelected ? Colors.white : const Color(0xFFD1D5DB)),
              title: Text(dest.label, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFFD1D5DB), fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
              selected: isSelected,
              selectedTileColor: PharmacyTheme.primary,
              onTap: () {
                _onItemTapped(index);
                Navigator.pop(context); // Close drawer
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, NavigationDestinationData dest) {
    final bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? PharmacyTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected ? [BoxShadow(color: PharmacyTheme.primary.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))] : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              dest.icon, 
              size: 22, 
              color: isSelected ? Colors.white : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 14),
            Text(
              dest.label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 15,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationDestinationData {
  final String label;
  final IconData icon;
  NavigationDestinationData(this.label, this.icon);
}
