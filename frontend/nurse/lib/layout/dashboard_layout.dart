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
                      Icon(Icons.favorite, color: AppTheme.brandPrimary, size: 20),
                      SizedBox(width: 8),
                      Text('AyuSync Nurse', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                    IconButton(
                      icon: Icon(Icons.person_outline),
                      onPressed: () => _onTap(4, context),
                    ),
                    SizedBox(width: 8),
                  ],
                )
              : null,
          drawer: null, // Removed mobile side drawer as per audio request
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.brandSecondary,
            Color(0xFF020617), // Deepest Slate
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: Row(
              children: [
                Icon(Icons.favorite, color: AppTheme.brandPrimary, size: 20),
                SizedBox(width: 12),
                Text('AyuSync Nurse', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
                _buildNavItem(context, 3, Icons.house_outlined, 'Home Visits'),
                SizedBox(height: 16),
                _buildNavItem(context, 4, Icons.settings_outlined, 'Settings'),
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
                Icon(Icons.favorite, color: AppTheme.brandPrimary, size: 24),
                SizedBox(width: 12),
                Text('AyuSync Nurse', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
                _buildNavItem(context, 3, Icons.house_outlined, 'Home Visits'),
                SizedBox(height: 16),
                _buildNavItem(context, 4, Icons.settings_outlined, 'Settings'),
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
            gradient: isActive ? const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF312E81), Color(0xFF1E1B4B)]) : null,
            color: isActive ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: isActive ? AppTheme.brandPrimary : Colors.transparent, width: 4)),
            boxShadow: isActive ? [BoxShadow(color: AppTheme.brandPrimary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
          ),
          child: Row(
            children: [
              Icon(icon, color: isActive ? AppTheme.brandPrimary : Colors.white.withOpacity(0.7), size: 20),
              SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: isActive ? Colors.white : Colors.white.withOpacity(0.7),
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
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              _getTitle(navigationShell.currentIndex),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Badge(
                  label: Text('2'),
                  backgroundColor: AppTheme.colorUrgent,
                  child: Icon(Icons.notifications_none, color: Theme.of(context).hintColor),
                ),
                onPressed: () {},
              ),
              SizedBox(width: 16),
              PopupMenuButton<String>(
                offset: const Offset(0, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (value) {
                  if (value == 'profile') {
                    _onTap(4, context);
                  } else if (value == 'logout') {
                    context.go('/login');
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person_outline, size: 20),
                        SizedBox(width: 12),
                        Text('Profile & Settings'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Sign Out', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: Center(child: Text('👩‍⚕️', style: TextStyle(fontSize: 16))),
                      ),
                      SizedBox(width: 8),
                      Text('Nurse Clara', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Icon(Icons.keyboard_arrow_down, size: 16, color: Theme.of(context).hintColor),
                    ],
                  ),
                ),
              ),
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
    int navIndex = currentIndex >= 4 ? 0 : currentIndex; // Fallback to 0 if viewing a drawer-only screen

    return BottomNavigationBar(
      currentIndex: navIndex,
      onTap: (index) => _onTap(index, context),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.brandPrimary,
      unselectedItemColor: Theme.of(context).hintColor,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle: TextStyle(fontSize: 12),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Patients'),
        BottomNavigationBarItem(icon: Icon(Icons.checklist), label: 'Tasks'),
        BottomNavigationBarItem(icon: Icon(Icons.house_outlined), label: 'Visits'),
      ],
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0: return 'Dashboard';
      case 1: return 'Patients';
      case 2: return 'Tasks';
      case 3: return 'Home Visits';
      case 4: return 'Profile & Settings';
      default: return 'Dashboard';
    }
  }
}
