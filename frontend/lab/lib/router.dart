import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'layout/dashboard_layout.dart';
import 'screens/work_queue_screen.dart';
import 'screens/samples_screen.dart';
import 'screens/results_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/placeholder_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorQueueKey = GlobalKey<NavigatorState>(debugLabel: 'queue');
final GlobalKey<NavigatorState> _shellNavigatorSamplesKey = GlobalKey<NavigatorState>(debugLabel: 'samples');
final GlobalKey<NavigatorState> _shellNavigatorResultsKey = GlobalKey<NavigatorState>(debugLabel: 'results');
final GlobalKey<NavigatorState> _shellNavigatorReportsKey = GlobalKey<NavigatorState>(debugLabel: 'reports');
final GlobalKey<NavigatorState> _shellNavigatorAnalyticsKey = GlobalKey<NavigatorState>(debugLabel: 'analytics');
final GlobalKey<NavigatorState> _shellNavigatorSettingsKey = GlobalKey<NavigatorState>(debugLabel: 'settings');

final goRouter = GoRouter(
  initialLocation: '/queue',
  navigatorKey: _rootNavigatorKey,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return DashboardLayout(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorQueueKey,
          routes: [
            GoRoute(
              path: '/queue',
              builder: (context, state) => const WorkQueueScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorSamplesKey,
          routes: [
            GoRoute(
              path: '/samples',
              builder: (context, state) => const SamplesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorResultsKey,
          routes: [
            GoRoute(
              path: '/results',
              builder: (context, state) => const ResultsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorReportsKey,
          routes: [
            GoRoute(
              path: '/reports',
              builder: (context, state) => const PlaceholderScreen(title: 'Laboratory Reports'),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorAnalyticsKey,
          routes: [
            GoRoute(
              path: '/analytics',
              builder: (context, state) => const PlaceholderScreen(title: 'Laboratory Analytics'),
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
