import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../utils/theme.dart';
import 'glass_card.dart';

class SosEmergencyModal extends StatelessWidget {
  final VoidCallback onAccept;

  const SosEmergencyModal({super.key, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GlassCard(
            blur: 20,
            color: DriverTheme.redBg.withOpacity(0.8),
            borderColor: DriverTheme.red.withOpacity(0.5),
            boxShadow: [
              BoxShadow(
                color: DriverTheme.red.withOpacity(0.3),
                blurRadius: 40,
                spreadRadius: 10,
              )
            ],
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pulsating Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: DriverTheme.red.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: DriverTheme.red.withOpacity(0.5), width: 2),
                    ),
                    child: const Icon(
                      LucideIcons.alertTriangle,
                      color: DriverTheme.red,
                      size: 48,
                    ),
                  ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                   .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 600.ms)
                   .shimmer(color: Colors.white24, duration: 1200.ms),
                  
                  const SizedBox(height: 24),
                  const Text(
                    'SOS EMERGENCY',
                    style: TextStyle(
                      color: DriverTheme.red,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      fontFamily: 'Outfit',
                    ),
                  ).animate().fadeIn().slideY(begin: 0.2),
                  
                  const SizedBox(height: 16),
                  const Text(
                    'Patient #10482 has triggered an emergency alert. Immediate transport to Apollo Hospital required.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white.withOpacity(0.3)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Decline', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // Close modal
                            onAccept(); // Trigger map flow
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DriverTheme.red,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 10,
                            shadowColor: DriverTheme.red.withOpacity(0.5),
                          ),
                          child: const Text('ACCEPT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
