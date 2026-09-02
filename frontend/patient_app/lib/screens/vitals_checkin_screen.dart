import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/patient_providers.dart';
import '../theme/app_theme.dart';

class VitalsCheckinScreen extends ConsumerStatefulWidget {
  const VitalsCheckinScreen({super.key});

  @override
  ConsumerState<VitalsCheckinScreen> createState() => _VitalsCheckinScreenState();
}

class _VitalsCheckinScreenState extends ConsumerState<VitalsCheckinScreen> {
  final _hrController = TextEditingController();
  final _bpSysController = TextEditingController();
  final _bpDiaController = TextEditingController();
  final _o2Controller = TextEditingController();

  bool _isSubmitting = false;

  Future<void> _submitVitals() async {
    final patientId = ref.read(authProvider).patientId;
    if (patientId == null) return;

    final hr = int.tryParse(_hrController.text.trim());
    final bpSys = int.tryParse(_bpSysController.text.trim());
    final bpDia = int.tryParse(_bpDiaController.text.trim());
    final o2 = int.tryParse(_o2Controller.text.trim());

    if (hr == null && bpSys == null && bpDia == null && o2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter at least one vital sign to save.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final payload = {
        'heart_rate': hr,
        'bp_systolic': bpSys,
        'bp_diastolic': bpDia,
        'oxygen_saturation': o2,
      };

      await ref.read(patientRepositoryProvider).submitVitals(patientId, payload);
      ref.read(completedTaskIdsProvider.notifier).update((state) => {...state, 'check_vitals'});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(LucideIcons.checkCircle2, color: Colors.white),
                const SizedBox(width: 12),
                const Text('Vitals logged successfully!'),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save vitals: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _hrController.dispose();
    _bpSysController.dispose();
    _bpDiaController.dispose();
    _o2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Log Daily Vitals',
          style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.textDark),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Track your health',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
                letterSpacing: -0.5,
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
            const SizedBox(height: 4),
            const Text(
              'Fill in the vitals you measured today. You can leave fields blank if you didn\'t measure them.',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 14, height: 1.4),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
            const SizedBox(height: 24),
            
            // Heart Rate Card
            _buildVitalCard(
              title: 'Heart Rate',
              subtitle: 'bpm',
              icon: LucideIcons.heartPulse,
              color: Colors.redAccent,
              delay: 200,
              child: _buildTextField(_hrController, 'e.g. 72'),
            ),
            const SizedBox(height: 16),

            // Blood Pressure Card
            _buildVitalCard(
              title: 'Blood Pressure',
              subtitle: 'mmHg',
              icon: LucideIcons.activity,
              color: Colors.purpleAccent,
              delay: 300,
              child: Row(
                children: [
                  Expanded(child: _buildTextField(_bpSysController, 'Sys (120)')),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('/', style: TextStyle(fontSize: 20, color: Colors.black26)),
                  ),
                  Expanded(child: _buildTextField(_bpDiaController, 'Dia (80)')),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Oxygen Saturation Card
            _buildVitalCard(
              title: 'Oxygen Saturation',
              subtitle: '% SpO2',
              icon: LucideIcons.wind,
              color: Colors.blueAccent,
              delay: 400,
              child: _buildTextField(_o2Controller, 'e.g. 98'),
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitVitals,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  disabledBackgroundColor: AppTheme.primaryOrange.withOpacity(0.5),
                ),
                child: _isSubmitting
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save Vitals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required int delay,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideY(begin: 0.1);
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.normal, fontSize: 15),
        filled: true,
        fillColor: AppTheme.backgroundLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryOrange.withOpacity(0.5), width: 2),
        ),
      ),
    );
  }
}
