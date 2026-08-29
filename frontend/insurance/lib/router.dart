import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'layout/dashboard_layout.dart';
import 'screens/dashboard_screen.dart';
import 'screens/authorizations_screen.dart';
import 'screens/claims_screen.dart';
import 'screens/patients_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/settings_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorDashboardKey = GlobalKey<NavigatorState>(debugLabel: 'dashboard');
final GlobalKey<NavigatorState> _shellNavigatorAuthKey = GlobalKey<NavigatorState>(debugLabel: 'authorizations');
final GlobalKey<NavigatorState> _shellNavigatorClaimsKey = GlobalKey<NavigatorState>(debugLabel: 'claims');
final GlobalKey<NavigatorState> _shellNavigatorPatientsKey = GlobalKey<NavigatorState>(debugLabel: 'patients');
final GlobalKey<NavigatorState> _shellNavigatorReportsKey = GlobalKey<NavigatorState>(debugLabel: 'reports');
final GlobalKey<NavigatorState> _shellNavigatorSettingsKey = GlobalKey<NavigatorState>(debugLabel: 'settings');

final goRouter = GoRouter(
  initialLocation: '/dashboard',
  navigatorKey: _rootNavigatorKey,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return DashboardLayout(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorDashboardKey,
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorAuthKey,
          routes: [
            GoRoute(
              path: '/authorizations',
              builder: (context, state) => const AuthorizationsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorClaimsKey,
          routes: [
            GoRoute(
              path: '/claims',
              builder: (context, state) => const ClaimsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorPatientsKey,
          routes: [
            GoRoute(
              path: '/patients',
              builder: (context, state) => const PatientsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorReportsKey,
          routes: [
            GoRoute(
              path: '/reports',
              builder: (context, state) => const ReportsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorSettingsKey,
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
