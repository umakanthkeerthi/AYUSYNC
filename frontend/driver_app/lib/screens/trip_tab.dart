import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../utils/theme.dart';
import '../widgets/glass_card.dart';

class TripTab extends StatelessWidget {
  final VoidCallback onCompleteTrip;

  const TripTab({super.key, required this.onCompleteTrip});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Map Background
        Positioned.fill(
          child: Image.asset(
            'assets/map_bg.jpg',
            fit: BoxFit.cover,
          ),
        ),
        
        // Floating Top Panel (Active Transport Info)
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: GlassCard(
            blur: 20,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ACTIVE TRANSPORT', style: TextStyle(color: DriverTheme.primaryLight, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 11)),
                        const SizedBox(height: 4),
                        const Text('Patient ID: #10482', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'Outfit', color: Colors.white)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: DriverTheme.redBg.withOpacity(0.8),
                        border: Border.all(color: DriverTheme.red.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('CRITICAL', style: TextStyle(color: DriverTheme.red, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Colors.white12, height: 1),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(LucideIcons.mapPin, color: DriverTheme.red, size: 14),
                              const SizedBox(width: 8),
                              const Text('City Hospital', style: TextStyle(color: DriverTheme.textMuted, fontSize: 12)),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: SizedBox(height: 12, child: VerticalDivider(color: Colors.white24, thickness: 2)),
                          ),
                          Row(
                            children: [
                              const Icon(LucideIcons.mapPin, color: DriverTheme.primaryLight, size: 14),
                              const SizedBox(width: 8),
                              const Text('Apollo Hospital', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          const Text('ETA', style: TextStyle(color: DriverTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          const Text('12m', style: TextStyle(color: DriverTheme.primaryLight, fontSize: 18, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Floating Bottom Panel (Action Buttons)
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: GlassCard(
                  padding: EdgeInsets.zero,
                  color: DriverTheme.primary.withOpacity(0.3),
                  borderColor: DriverTheme.primary.withOpacity(0.5),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.navigation, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        const Text('NAVIGATING', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: GlassCard(
                  padding: EdgeInsets.zero,
                  color: DriverTheme.green.withOpacity(0.2),
                  borderColor: DriverTheme.green.withOpacity(0.5),
                  child: ElevatedButton(
                    onPressed: onCompleteTrip,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: const Text('Arrived', style: TextStyle(color: DriverTheme.green, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

