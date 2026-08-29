import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../theme/app_theme.dart';

class DashboardLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const DashboardLayout({Key? key, required this.navigationShell}) : super(key: key);

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        bool isMobile = sizingInformation.deviceScreenType == DeviceScreenType.mobile;

        return Scaffold(
          appBar: isMobile
              ? AppBar(
                  backgroundColor: AppTheme.brandSidebar,
                  iconTheme: const IconThemeData(color: Colors.white),
                  title: Row(
                    children: [
                      const Icon(Icons.medical_services, color: AppTheme.colorDanger),
                      const SizedBox(width: 8),
                      const Text('AyuSync Doctor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white,
                        child: Text('👨‍⚕️', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                )
              : null,
          drawer: isMobile ? _buildDrawer(context) : null,
          body: Row(
            children: [
              if (!isMobile) _buildSidebar(context),
              Expanded(
                child: Column(
                  children: [
                    if (!isMobile) _buildDesktopHeader(context),
                    Expanded(
                      child: Container(
                        color: AppTheme.brandBg,
                        child: navigationShell,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: isMobile ? _buildBottomNav(context) : null,
        );
      },
    );
  }

  Widget _buildDesktopHeader(BuildContext context) {
    final titles = ['Overview', 'My Patients', 'Alerts', 'Interventions', 'Messages'];
    final title = navigationShell.currentIndex < titles.length ? titles[navigationShell.currentIndex] : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      color: AppTheme.brandBg,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppTheme.textDark),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: AppTheme.borderColor),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
                  ],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: AppTheme.brandBg,
                      child: Text('👨‍⚕️', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(width: 12),
                    const Text('Dr. Mehta', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(width: 8),
                    const Icon(Icons.keyboard_arrow_down, size: 16, color: AppTheme.textSecondary),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 260,
      color: AppTheme.brandSidebar,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Row(
              children: [
                Icon(Icons.medical_services, color: AppTheme.colorDanger, size: 28),
                SizedBox(width: 12),
                Text('AyuSync Doctor', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _SidebarItem(icon: Icons.home_filled, label: 'Overview', isActive: navigationShell.currentIndex == 0, onTap: () => _goBranch(0)),
                _SidebarItem(icon: Icons.people, label: 'My Patients', isActive: navigationShell.currentIndex == 1, onTap: () => _goBranch(1)),
                _SidebarItem(icon: Icons.notifications, label: 'Alerts', isActive: navigationShell.currentIndex == 2, onTap: () => _goBranch(2)),
                _SidebarItem(icon: Icons.medical_information, label: 'Interventions', isActive: navigationShell.currentIndex == 3, onTap: () => _goBranch(3)),
                _SidebarItem(icon: Icons.message, label: 'Messages', isActive: navigationShell.currentIndex == 4, onTap: () => _goBranch(4)),
                _SidebarItem(icon: Icons.description, label: 'Reports', isActive: navigationShell.currentIndex == 5, onTap: () => _goBranch(5)),
                _SidebarItem(icon: Icons.settings, label: 'Settings', isActive: navigationShell.currentIndex == 6, onTap: () => _goBranch(6)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.brandSidebar,
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: AppTheme.brandSidebar),
            child: Row(
              children: [
                Icon(Icons.medical_services, color: AppTheme.colorDanger, size: 28),
                SizedBox(width: 12),
                Text('AyuSync Doctor', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          _SidebarItem(icon: Icons.home_filled, label: 'Overview', isActive: navigationShell.currentIndex == 0, onTap: () { _goBranch(0); Navigator.pop(context); }),
          _SidebarItem(icon: Icons.people, label: 'My Patients', isActive: navigationShell.currentIndex == 1, onTap: () { _goBranch(1); Navigator.pop(context); }),
          _SidebarItem(icon: Icons.settings, label: 'Settings', isActive: navigationShell.currentIndex == 6, onTap: () { _goBranch(6); Navigator.pop(context); }),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: navigationShell.currentIndex > 4 ? 0 : navigationShell.currentIndex,
      onTap: _goBranch,
      backgroundColor: AppTheme.brandSidebar,
      selectedItemColor: Colors.white,
      unselectedItemColor: const Color(0xFFA19DB0),
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Overview'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Patients'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
        BottomNavigationBarItem(icon: Icon(Icons.medical_information), label: 'Intervene'),
        BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
      ],
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarItem({required this.icon, required this.label, this.isActive = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.brandActive : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: isActive ? Colors.white : const Color(0xFFA19DB0), size: 20),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : const Color(0xFFA19DB0),
                  fontSize: 15,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
