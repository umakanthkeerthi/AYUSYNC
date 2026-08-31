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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 6)),
                  BoxShadow(color: Colors.white.withOpacity(0.05), blurRadius: 1, offset: const Offset(-1, -1))
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.brandActive.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.shield_outlined, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Insurance\nDashboard',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700, height: 1.2, letterSpacing: 0.5),
                    ),
                  ),
                ],
              ),
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 6)),
                  BoxShadow(color: Colors.white.withOpacity(0.05), blurRadius: 1, offset: const Offset(-1, -1))
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.brandActive.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.shield_outlined, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Insurance\nDashboard',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700, height: 1.2, letterSpacing: 0.5),
                    ),
                  ),
                ],
              ),
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
    return GlassSidebarItem(
      icon: icon,
      label: label,
      isActive: isActive,
      onTap: () => _onTap(index, context),
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

class GlassSidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const GlassSidebarItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  }) : super(key: key);

  @override
  State<GlassSidebarItem> createState() => _GlassSidebarItemState();
}

class _GlassSidebarItemState extends State<GlassSidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    bool showGlass = widget.isActive || _isHovered;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutQuart,
            transform: Matrix4.translationValues(0, _isHovered ? -4.0 : 0.0, 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: showGlass ? Colors.white.withOpacity(0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: showGlass ? Colors.white.withOpacity(0.25) : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: showGlass
                  ? [
                      // Inner glow / subtle float shadow
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                      // Top-left highlight for premium glass edge
                      BoxShadow(
                        color: Colors.white.withOpacity(0.05),
                        blurRadius: 1,
                        offset: const Offset(-1, -1),
                      )
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  color: showGlass ? Colors.white : Colors.white.withOpacity(0.6),
                  size: 22,
                ),
                const SizedBox(width: 16),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: showGlass ? Colors.white : Colors.white.withOpacity(0.6),
                    fontWeight: showGlass ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
