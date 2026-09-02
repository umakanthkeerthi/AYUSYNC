import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'router.dart';

void main() {
  runApp(const AyuSyncNurseApp());
}

class AyuSyncNurseApp extends StatelessWidget {
  const AyuSyncNurseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AyuSync Nurse',
      theme: AppTheme.lightTheme,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
      scrollBehavior: NoScrollbarBehavior(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(0.85),
          ),
          child: child!,
        );
      },
    );
  }
}

class NoScrollbarBehavior extends MaterialScrollBehavior {
  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
