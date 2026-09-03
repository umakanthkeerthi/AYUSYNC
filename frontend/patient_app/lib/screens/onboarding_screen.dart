import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../repositories/patient_repository.dart';
import '../providers/patient_providers.dart';
import 'main_layout.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  File? _imageFile;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    setState(() => _isUploading = true);

    try {
      final patientId = ref.read(authProvider).patientId;
      if (patientId == null) throw Exception("Patient ID not found");
      
      final repo = ref.read(patientRepositoryProvider);
      await repo.uploadMedicalRecord(patientId, _imageFile!.path);
      
      if (mounted) {
        // Refresh providers before going to home screen
        ref.invalidate(medicationsProvider);
        ref.invalidate(recoveryPlanProvider);
        
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainLayout()),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }
  
  void _skipOnboarding() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainLayout()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Welcome to AyuSync!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Let\'s set up your profile. Upload a photo of your most recent prescription or lab report. Our AI will automatically generate your daily medication schedule and health reminders.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              
              if (_imageFile != null) ...[
                GlassCard(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _imageFile!,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _isUploading ? null : _uploadImage,
                  icon: _isUploading 
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(LucideIcons.check, size: 18),
                  label: Text(_isUploading ? 'Analyzing Document...' : 'Finish Setup'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                TextButton(
                  onPressed: _isUploading ? null : () => setState(() => _imageFile = null),
                  child: const Text('Choose a different photo', style: TextStyle(color: AppTheme.textMuted)),
                ),
              ] else ...[
                GestureDetector(
                  onTap: () => _pickImage(ImageSource.camera),
                  child: GlassCard(
                    child: Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryOrange.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.primaryOrange.withOpacity(0.3), width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.camera, size: 48, color: AppTheme.primaryOrange),
                          const SizedBox(height: 12),
                          const Text('Take a Photo', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.primaryOrange)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _pickImage(ImageSource.gallery),
                  child: GlassCard(
                    child: Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.3), width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.image, size: 48, color: Colors.blue),
                          const SizedBox(height: 12),
                          const Text('Upload from Gallery', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.blue)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                TextButton(
                  onPressed: _skipOnboarding,
                  child: const Text('Skip for now', style: TextStyle(color: AppTheme.textMuted, fontSize: 16)),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
