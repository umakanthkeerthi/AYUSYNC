import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'auth_screen.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to Main Layout after 3.5 seconds
    Timer(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const AuthScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: 'AyuSync'.split('').map((char) {
                return Text(
                  char,
                  style: const TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primaryOrange,
                    letterSpacing: -1.0,
                  ),
                );
              }).toList().animate(interval: 150.ms).fadeIn(duration: 50.ms).scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 100.ms),
            ),
            // Blinking cursor
            const Text(
              '|',
              style: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w300,
                color: AppTheme.primaryOrange,
              ),
            ).animate(onPlay: (controller) => controller.repeat()).fade(duration: 400.ms, begin: 0, end: 1),
          ],
        ),
      ),
    );
  }
}
