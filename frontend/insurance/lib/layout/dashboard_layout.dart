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
                  backgroundColor: AppTheme.brandSidebar,
                  iconTheme: const IconThemeData(color: Colors.white),
                  title: const Text('Insurance Dashboard', style: TextStyle(color: Colors.white)),
                )
              : null,
          drawer: isMobile ? _buildDrawer(context) : null,
          body: Row(
            children: [
              if (!isMobile) _buildSidebar(context),
              Expanded(
                child: navigationShell,
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
      width: 250,
      color: AppTheme.brandSidebar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: const Text(
              'Insurance Dashboard',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildNavItem(context, 0, Icons.dashboard, 'Dashboard'),
                _buildNavItem(context, 1, Icons.verified_user, 'Authorizations'),
                _buildNavItem(context, 2, Icons.receipt_long, 'Claims'),
                _buildNavItem(context, 3, Icons.people, 'Patients'),
                _buildNavItem(context, 4, Icons.insert_chart, 'Reports'),
                const SizedBox(height: 16),
                _buildNavItem(context, 5, Icons.settings, 'Settings'),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.brandSidebar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: const Text(
              'Insurance Dashboard',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildNavItem(context, 0, Icons.dashboard, 'Dashboard'),
                _buildNavItem(context, 1, Icons.verified_user, 'Authorizations'),
                _buildNavItem(context, 2, Icons.receipt_long, 'Claims'),
                _buildNavItem(context, 3, Icons.people, 'Patients'),
                _buildNavItem(context, 4, Icons.insert_chart, 'Reports'),
                const SizedBox(height: 16),
                _buildNavItem(context, 5, Icons.settings, 'Settings'),
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
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () => _onTap(index, context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.brandActive : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon, 
                color: Colors.white, 
                size: 20
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    int currentIndex = navigationShell.currentIndex;
    int navIndex = currentIndex > 4 ? 0 : currentIndex; 

    return BottomNavigationBar(
      currentIndex: navIndex,
      onTap: (index) => _onTap(index, context),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.brandActive,
      unselectedItemColor: AppTheme.textSecondary,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.verified_user), label: 'Auth'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Claims'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Patients'),
        BottomNavigationBarItem(icon: Icon(Icons.insert_chart), label: 'Reports'),
      ],
    );
  }
}
