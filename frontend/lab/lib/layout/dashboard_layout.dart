import 'dart:ui';
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
                  backgroundColor: AppTheme.bgCard.withOpacity(0.9),
                  elevation: 0,
                  flexibleSpace: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                  title: Row(
                    children: [
                      const Icon(Icons.science, color: AppTheme.brandActive),
                      const SizedBox(width: 8),
                      const Text('AyuSync Lab', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textDark)),
                    ],
                  ),
                  iconTheme: const IconThemeData(color: AppTheme.textDark),
                  actions: [
                    IconButton(
                      icon: const Badge(
                        label: Text('3'),
                        backgroundColor: AppTheme.statRed,
                        child: Icon(Icons.notifications_none, color: AppTheme.textSecondary),
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
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: 250,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.brandSidebar.withOpacity(0.75),
                AppTheme.brandSidebar.withOpacity(0.95),
              ],
            ),
            border: Border(
              right: BorderSide(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(4, 0),
              )
            ]
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.25),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.science, color: Colors.tealAccent, size: 26),
                      const SizedBox(width: 12),
                      const Text('AyuSync Lab', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  children: [
                    _HoverableNavItem(index: 0, icon: Icons.assignment, label: 'Work Queue', isActive: navigationShell.currentIndex == 0, onTap: () => _onTap(0, context)),
                    _HoverableNavItem(index: 1, icon: Icons.healing, label: 'Samples', isActive: navigationShell.currentIndex == 1, onTap: () => _onTap(1, context)),
                    _HoverableNavItem(index: 2, icon: Icons.analytics, label: 'Results', isActive: navigationShell.currentIndex == 2, onTap: () => _onTap(2, context)),
                    _HoverableNavItem(index: 3, icon: Icons.description_outlined, label: 'Reports', isActive: navigationShell.currentIndex == 3, onTap: () => _onTap(3, context)),
                    _HoverableNavItem(index: 4, icon: Icons.trending_up, label: 'Analytics', isActive: navigationShell.currentIndex == 4, onTap: () => _onTap(4, context)),
                    const SizedBox(height: 16),
                    _HoverableNavItem(index: 5, icon: Icons.settings_outlined, label: 'Settings', isActive: navigationShell.currentIndex == 5, onTap: () => _onTap(5, context)),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.brandSidebar.withOpacity(0.75),
                  AppTheme.brandSidebar.withOpacity(0.95),
                ],
              ),
              border: Border(right: BorderSide(color: Colors.white.withOpacity(0.2), width: 1.5)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.25),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.science, color: Colors.tealAccent, size: 28),
                        const SizedBox(width: 12),
                        const Text('AyuSync Lab', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _HoverableNavItem(index: 0, icon: Icons.assignment, label: 'Work Queue', isActive: navigationShell.currentIndex == 0, onTap: () => _onTap(0, context)),
                      _HoverableNavItem(index: 1, icon: Icons.healing, label: 'Samples', isActive: navigationShell.currentIndex == 1, onTap: () => _onTap(1, context)),
                      _HoverableNavItem(index: 2, icon: Icons.analytics, label: 'Results', isActive: navigationShell.currentIndex == 2, onTap: () => _onTap(2, context)),
                      _HoverableNavItem(index: 3, icon: Icons.description_outlined, label: 'Reports', isActive: navigationShell.currentIndex == 3, onTap: () => _onTap(3, context)),
                      _HoverableNavItem(index: 4, icon: Icons.trending_up, label: 'Analytics', isActive: navigationShell.currentIndex == 4, onTap: () => _onTap(4, context)),
                      const SizedBox(height: 16),
                      _HoverableNavItem(index: 5, icon: Icons.settings_outlined, label: 'Settings', isActive: navigationShell.currentIndex == 5, onTap: () => _onTap(5, context)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Old _buildNavItem removed

  Widget _buildDesktopHeader(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width < 1250;
    
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppTheme.brandBg,
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
              if (!isTablet) ...[
                Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppTheme.borderColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.search, size: 18, color: AppTheme.textSecondary),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('Search...', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
              ],
              IconButton(
                icon: const Badge(
                  label: Text('3'),
                  backgroundColor: AppTheme.statRed,
                  child: Icon(Icons.notifications_none, color: AppTheme.textSecondary),
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 16),
              const Text('🧑‍🔬', style: TextStyle(fontSize: 24)),
              if (!isTablet) ...[
                const SizedBox(width: 8),
                const Text('Lab Technician', style: TextStyle(fontWeight: FontWeight.w600)),
                const Icon(Icons.keyboard_arrow_down, size: 16, color: AppTheme.textSecondary),
              ]
            ],
          )
        ],
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
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Queue'),
        BottomNavigationBarItem(icon: Icon(Icons.healing), label: 'Samples'),
        BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Results'),
        BottomNavigationBarItem(icon: Icon(Icons.description_outlined), label: 'Reports'),
        BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'Analytics'),
      ],
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0: return 'Lab Work Queue';
      case 1: return 'Samples';
      case 2: return 'Results';
      case 3: return 'Laboratory Reports';
      case 4: return 'Laboratory Analytics';
      case 5: return 'Settings';
      default: return 'Lab Work Queue';
    }
  }
}

class _HoverableNavItem extends StatefulWidget {
  final int index;
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _HoverableNavItem({
    Key? key,
    required this.index,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  }) : super(key: key);

  @override
  State<_HoverableNavItem> createState() => _HoverableNavItemState();
}

class _HoverableNavItemState extends State<_HoverableNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 8.0),
          transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0), // Lifts up
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: (widget.isActive || _isHovered)
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.25),
                      Colors.white.withOpacity(0.05),
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: (widget.isActive || _isHovered) 
                  ? Colors.white.withOpacity(0.4) 
                  : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: (widget.isActive || _isHovered)
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Icon(
                widget.icon, 
                color: (widget.isActive || _isHovered) ? Colors.white : Colors.white.withOpacity(0.6), 
                size: 22
              ),
              const SizedBox(width: 16),
              Text(
                widget.label,
                style: TextStyle(
                  color: (widget.isActive || _isHovered) ? Colors.white : Colors.white.withOpacity(0.6),
                  fontWeight: (widget.isActive || _isHovered) ? FontWeight.bold : FontWeight.w500,
                  fontSize: 15,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

