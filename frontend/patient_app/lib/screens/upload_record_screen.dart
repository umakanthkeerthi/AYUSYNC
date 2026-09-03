import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../repositories/patient_repository.dart';
import '../providers/patient_providers.dart';

class UploadRecordScreen extends ConsumerStatefulWidget {
  const UploadRecordScreen({super.key});

  @override
  ConsumerState<UploadRecordScreen> createState() => _UploadRecordScreenState();
}

class _UploadRecordScreenState extends ConsumerState<UploadRecordScreen> {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final patientId = ref.read(patientIdProvider);
      if (patientId == null) throw Exception("Patient ID not found");
      
      final repo = ref.read(patientRepositoryProvider);
      await repo.uploadMedicalRecord(patientId, _imageFile!.path);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload successful! Our AI is processing your record.')),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Upload Medical Record'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Upload Prescription or Lab Report',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Our AI agent will automatically analyze your record and add new daily medications and reminders to your schedule.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
                    onPressed: _isUploading ? null : () => setState(() => _imageFile = null),
                    icon: const Icon(LucideIcons.x, size: 18),
                    label: const Text('Retake'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isUploading ? null : _uploadImage,
                    icon: _isUploading 
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(LucideIcons.upload, size: 18),
                    label: Text(_isUploading ? 'Uploading...' : 'Process Record'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              )
            ] else ...[
              GestureDetector(
                onTap: () => _pickImage(ImageSource.camera),
                child: GlassCard(
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primaryOrange.withOpacity(0.3), width: 2, style: BorderStyle.solid),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.camera, size: 40, color: AppTheme.primaryOrange),
                        const SizedBox(height: 12),
                        const Text('Take a Photo', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primaryOrange)),
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
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.3), width: 2, style: BorderStyle.solid),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.image, size: 40, color: Colors.blue),
                        const SizedBox(height: 12),
                        const Text('Upload from Gallery', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue)),
                      ],
                    ),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
