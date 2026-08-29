import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../utils/theme.dart';

class TripTab extends StatelessWidget {
  final VoidCallback onCompleteTrip;

  const TripTab({super.key, required this.onCompleteTrip});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildMapCard(),
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ACTIVE TRANSPORT', style: TextStyle(color: DriverTheme.primary, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 12)),
            const SizedBox(height: 4),
            const Text('Patient ID: #10482', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'Outfit')),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: DriverTheme.redBg, borderRadius: BorderRadius.circular(8)),
          child: const Text('CRITICAL', style: TextStyle(color: DriverTheme.red, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildMapCard() {
    return Container(
      decoration: BoxDecoration(
        color: DriverTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DriverTheme.border),
      ),
      child: Column(
        children: [
          // Route info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.mapPin, color: DriverTheme.red, size: 16),
                          const SizedBox(width: 8),
                          const Text('FROM: City Hospital', style: TextStyle(color: DriverTheme.textMuted, fontSize: 13)),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 7),
                        child: SizedBox(height: 12, child: VerticalDivider(color: DriverTheme.border, thickness: 2)),
                      ),
                      Row(
                        children: [
                          const Icon(LucideIcons.mapPin, color: DriverTheme.primary, size: 16),
                          const SizedBox(width: 8),
                          const Text('TO: Apollo Hospital', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: DriverTheme.background, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      const Text('ETA', style: TextStyle(color: DriverTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text('12m', style: TextStyle(color: DriverTheme.primary, fontSize: 18, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Map Placeholder
          Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF0B1121),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.map, size: 48, color: DriverTheme.border),
                  SizedBox(height: 12),
                  Text('GPS Navigation Active', style: TextStyle(color: DriverTheme.textMuted)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: DriverTheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
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
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: ElevatedButton(
            onPressed: onCompleteTrip,
            style: ElevatedButton.styleFrom(
              backgroundColor: DriverTheme.green.withOpacity(0.2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: DriverTheme.green),
            ),
            child: const Text('Arrived', style: TextStyle(color: DriverTheme.green, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
