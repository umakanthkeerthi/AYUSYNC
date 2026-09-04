import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class InsuranceScreen extends StatelessWidget {
  const InsuranceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Health Insurance'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildActivePolicySection().animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
          const SizedBox(height: 32),
          _buildComparisonSection().animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
          const SizedBox(height: 32),
          _buildClaimsHistorySection().animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
        ],
      ),
    );
  }

  Widget _buildActivePolicySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Insurance',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Icon(LucideIcons.shieldCheck, color: Colors.green),
                ],
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(LucideIcons.building2, size: 40, color: AppTheme.textDark),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Star Health Insurance',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                      ),
                      Text(
                        'Comprehensive Gold Plan',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPolicyStat('Policy No.', 'SH-98745210'),
                  _buildPolicyStat('Coverage', '₹10,00,000'),
                  _buildPolicyStat('Renewal', 'Oct 2026'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPolicyStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      ],
    );
  }

  Widget _buildComparisonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Better Insurance Options',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'AI Analysis: You could save money based on your recent health data.',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 16),
        _buildOptionCard('Care Health', 'Save ₹2,400/yr', 'Better OPD coverage', Colors.blue),
        const SizedBox(height: 12),
        _buildOptionCard('HDFC ERGO', 'Save ₹1,800/yr', 'No room rent limit', Colors.red),
      ],
    );
  }

  Widget _buildOptionCard(String provider, String saving, String feature, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(LucideIcons.trendingDown, color: color, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(provider, style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(feature, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Text(saving, style: TextStyle(color: color, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildClaimsHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Claims History',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 16),
        _buildClaimCard('Apollo Hospitals', 'Aug 12, 2026', '₹45,000', 'Approved', Colors.green),
        const SizedBox(height: 12),
        _buildClaimCard('Dr. Reddy Labs', 'Jun 05, 2026', '₹3,200', 'Processing', Colors.orange),
      ],
    );
  }

  Widget _buildClaimCard(String title, String date, String amount, String status, Color statusColor) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 4),
              Text(date, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              const SizedBox(height: 4),
              Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.w700, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
