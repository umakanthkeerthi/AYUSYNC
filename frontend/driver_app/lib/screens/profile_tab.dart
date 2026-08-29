import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../utils/theme.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Driver Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'Outfit')),
          const SizedBox(height: 24),
          _buildProfileCard(),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DriverTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DriverTheme.border),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage('https://images.unsplash.com/photo-1590611936760-eeb9bc5031ce?auto=format&fit=crop&w=300&q=80'),
          ),
          const SizedBox(height: 16),
          const Text('Ramesh Singh', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('License #DL-84092', style: TextStyle(color: DriverTheme.textMuted)),
          const SizedBox(height: 24),
          _buildInfoRow('Vehicle Assigned', 'ALS #AMB-409'),
          const SizedBox(height: 12),
          _buildInfoRow('Shift Timings', '08:00 AM - 08:00 PM', color: DriverTheme.green),
          const SizedBox(height: 12),
          _buildInfoRow('Trips Completed Today', '4 Trips'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: DriverTheme.background,
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: DriverTheme.border),
              ),
              icon: const Icon(LucideIcons.logOut, color: DriverTheme.red, size: 18),
              label: const Text('End Shift', style: TextStyle(color: DriverTheme.red, fontWeight: FontWeight.bold)),
            ),
          )
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
