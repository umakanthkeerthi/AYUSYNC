import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../utils/theme.dart';
import '../widgets/modals.dart';
import '../widgets/glass_card.dart';

class HomeTab extends StatelessWidget {
  final VoidCallback onAcceptTrip;

  const HomeTab({super.key, required this.onAcceptTrip});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Text('Driver Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'Outfit')),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            children: [
              _buildSosTrigger(context),
              const SizedBox(height: 48),
              Center(
                child: Column(
                  children: [
                    Icon(LucideIcons.radio, size: 64, color: DriverTheme.border),
                    const SizedBox(height: 24),
                    const Text('SYSTEM ONLINE', style: TextStyle(color: DriverTheme.primary, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                    const SizedBox(height: 8),
                    const Text('Waiting for dispatch...', style: TextStyle(color: DriverTheme.textMuted, fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSosTrigger(BuildContext context) {
    return GlassCard(
      color: DriverTheme.surface.withOpacity(0.4),
      child: Column(
        children: [
          const Icon(LucideIcons.siren, color: DriverTheme.textMuted, size: 32),
          const SizedBox(height: 16),
          const Text('Simulation Mode', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Trigger a simulated SOS to test the emergency flow.', textAlign: TextAlign.center, style: TextStyle(color: DriverTheme.textMuted, fontSize: 12)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierColor: Colors.transparent,
                  builder: (context) => SosEmergencyModal(onAccept: onAcceptTrip),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DriverTheme.primary.withOpacity(0.2),
                foregroundColor: DriverTheme.primaryLight,
                side: const BorderSide(color: DriverTheme.primary),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('SIMULATE SOS REQUEST', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}
