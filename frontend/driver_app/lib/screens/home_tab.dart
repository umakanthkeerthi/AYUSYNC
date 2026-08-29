import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../utils/theme.dart';

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
              _buildNewTripRequest(),
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    Icon(LucideIcons.coffee, size: 48, color: DriverTheme.border),
                    const SizedBox(height: 16),
                    const Text('No more alerts.', style: TextStyle(color: DriverTheme.textMuted, fontWeight: FontWeight.bold)),
                    const Text('Waiting for dispatch...', style: TextStyle(color: DriverTheme.textMuted, fontSize: 12)),
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

  Widget _buildNewTripRequest() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DriverTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DriverTheme.border, width: 1.5),
        boxShadow: [
          BoxShadow(color: DriverTheme.primary.withOpacity(0.1), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: DriverTheme.primary.withOpacity(0.15), shape: BoxShape.circle),
                child: const Icon(LucideIcons.info, color: DriverTheme.primary),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('NEW TRIP REQUEST', style: TextStyle(color: DriverTheme.primary, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.1)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow('Patient Name:', 'Rahul Kumar (#10482)'),
          const SizedBox(height: 8),
          _buildInfoRow('Location:', 'Fetching GPS coordinates...', color: Colors.white),
          const SizedBox(height: 8),
          _buildInfoRow('Priority:', 'HIGH PRIORITY', color: DriverTheme.primary),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onAcceptTrip,
              style: ElevatedButton.styleFrom(
                backgroundColor: DriverTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('ACCEPT & NAVIGATE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: DriverTheme.textMuted)),
        Text(value, style: TextStyle(color: color ?? DriverTheme.textMain, fontWeight: FontWeight.bold)),
      ],
    );
  }

}
