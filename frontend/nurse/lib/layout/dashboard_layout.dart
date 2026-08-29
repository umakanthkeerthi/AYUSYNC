import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../theme/app_theme.dart';

class DashboardLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const DashboardLayout({Key? key, required this.navigationShell}) : super(key: key);

  void _onTap(int index, BuildContext context) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
    if (MediaQuery.of(context).size.width < 768 && Scaffold.of(context).isDrawerOpen) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        bool isMobile = sizingInformation.deviceScreenType == DeviceScreenType.mobile;

        return Scaffold(
          appBar: isMobile
              ? AppBar(
                  backgroundColor: AppTheme.bgCard,
                  title: Row(
                    children: [
                      const Icon(Icons.favorite, color: AppTheme.brandPrimary),
                      const SizedBox(width: 8),
                      const Text('AyuSync Nurse', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: const Badge(
                        label: Text('2'),
                        backgroundColor: AppTheme.colorUrgent,
                        child: Icon(Icons.notifications_none),
                      ),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 16),
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
                    Expanded(child: navigationShell),
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

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 260,
      color: AppTheme.brandSecondary,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: Row(
              children: [
                const Icon(Icons.favorite, color: AppTheme.brandPrimary),
                const SizedBox(width: 12),
                const Text('AyuSync Nurse', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              children: [
                _buildNavItem(context, 0, Icons.home_filled, 'Dashboard'),
                _buildNavItem(context, 1, Icons.person_outline, 'Patients'),
                _buildNavItem(context, 2, Icons.checklist, 'Tasks'),
                _buildNavItem(context, 3, Icons.science_outlined, 'Lab Coordination'),
                _buildNavItem(context, 4, Icons.calendar_today, 'Appointments'),
                _buildNavItem(context, 5, Icons.notifications_none, 'Alerts'),
                _buildNavItem(context, 6, Icons.chat_bubble_outline, 'Messages'),
                _buildNavItem(context, 7, Icons.description_outlined, 'Reports'),
                const SizedBox(height: 16),
                _buildNavItem(context, 8, Icons.settings_outlined, 'Settings'),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.brandSecondary,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            child: Row(
              children: [
                const Icon(Icons.favorite, color: AppTheme.brandPrimary, size: 32),
                const SizedBox(width: 12),
                const Text('AyuSync Nurse', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildNavItem(context, 0, Icons.home_filled, 'Dashboard'),
                _buildNavItem(context, 1, Icons.person_outline, 'Patients'),
                _buildNavItem(context, 2, Icons.checklist, 'Tasks'),
                _buildNavItem(context, 3, Icons.science_outlined, 'Lab Coordination'),
                _buildNavItem(context, 4, Icons.calendar_today, 'Appointments'),
                _buildNavItem(context, 5, Icons.notifications_none, 'Alerts'),
                _buildNavItem(context, 6, Icons.chat_bubble_outline, 'Messages'),
                _buildNavItem(context, 7, Icons.description_outlined, 'Reports'),
                const SizedBox(height: 16),
                _buildNavItem(context, 8, Icons.settings_outlined, 'Settings'),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label) {
    bool isActive = navigationShell.currentIndex == index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: InkWell(
        onTap: () => _onTap(index, context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF273145) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border(left: BorderSide(color: isActive ? AppTheme.brandPrimary : Colors.transparent, width: 3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: isActive ? AppTheme.brandPrimary : AppTheme.textSecondary, size: 20),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : AppTheme.textSecondary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopHeader(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.bgMain,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              _getTitle(navigationShell.currentIndex),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Badge(
                  label: Text('2'),
                  backgroundColor: AppTheme.colorUrgent,
                  child: Icon(Icons.notifications_none, color: AppTheme.textSecondary),
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 16),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: const Center(child: Text('👩‍⚕️', style: TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 8),
              const Text('Nurse Priya', style: TextStyle(fontWeight: FontWeight.w600)),
              const Icon(Icons.keyboard_arrow_down, size: 16, color: AppTheme.textSecondary),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    // In mobile, we might only show the first 5 tabs in the bottom nav to prevent overcrowding.
    // The rest can be accessed via drawer.
    int currentIndex = navigationShell.currentIndex;
    int navIndex = currentIndex > 4 ? 0 : currentIndex; // Fallback to 0 if viewing a drawer-only screen

    return BottomNavigationBar(
      currentIndex: navIndex,
      onTap: (index) => _onTap(index, context),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.brandPrimary,
      unselectedItemColor: AppTheme.textSecondary,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Patients'),
        BottomNavigationBarItem(icon: Icon(Icons.checklist), label: 'Tasks'),
        BottomNavigationBarItem(icon: Icon(Icons.science_outlined), label: 'Lab'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Schedule'),
      ],
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0: return 'Dashboard';
      case 1: return 'Patients';
      case 2: return 'Tasks';
      case 3: return 'Lab Coordination';
      case 4: return 'Appointments';
      case 5: return 'System & Patient Alerts';
      case 6: return 'Messages';
      case 7: return 'Medical Reports';
      case 8: return 'Settings';
      default: return 'Dashboard';
    }
  }
}
