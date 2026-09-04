import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../repositories/patient_repository.dart';
import '../providers/patient_providers.dart';
import 'main_layout.dart';

class PickedFile {
  final Uint8List bytes;
  final String name;
  PickedFile(this.bytes, this.name);
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final Map<String, List<PickedFile>> _files = {
    'discharge_summary': [],
    'prescription': [],
    'lab_report': [],
    'scans': [],
  };
  
  bool _isUploading = false;

  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'discharge_summary',
      'title': 'Discharge Summary',
      'icon': LucideIcons.fileText,
      'color': Colors.blue,
    },
    {
      'id': 'prescription',
      'title': 'Prescription',
      'icon': LucideIcons.pill,
      'color': AppTheme.primaryOrange,
    },
    {
      'id': 'lab_report',
      'title': 'Lab Report',
      'icon': LucideIcons.testTube,
      'color': Colors.purple,
    },
    {
      'id': 'scans',
      'title': 'Medical Scans',
      'icon': LucideIcons.scan,
      'color': Colors.teal,
    },
  ];

  Future<void> _pickFile(String categoryId) async {
    try {
      const XTypeGroup typeGroup = XTypeGroup(
        label: 'Documents and Images',
        extensions: <String>['pdf', 'png', 'jpg', 'jpeg'],
      );
      final List<XFile> pickedFiles = await openFiles(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
      
      if (pickedFiles.isNotEmpty) {
        final newFiles = <PickedFile>[];
        for (var f in pickedFiles) {
          newFiles.add(PickedFile(await f.readAsBytes(), f.name));
        }
        setState(() {
          _files[categoryId]!.addAll(newFiles);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
      }
    }
  }

  Future<void> _uploadFiles() async {
    bool hasFiles = _files.values.any((list) => list.isNotEmpty);
    if (!hasFiles) return;

    setState(() => _isUploading = true);

    try {
      final patientId = ref.read(authProvider).patientId;
      if (patientId == null) throw Exception("Patient ID not found");
      
      final repo = ref.read(patientRepositoryProvider);
      
      for (final entry in _files.entries) {
        final category = entry.key;
        for (final file in entry.value) {
          await repo.uploadMedicalRecord(patientId, file.bytes, file.name, category);
        }
      }
      
      // Trigger Profile Setup Welcome Call once onboarding profile setup completes
      await repo.completeProfile(patientId);

      if (mounted) {
        // Refresh providers before going to home screen
        ref.invalidate(medicationsProvider);
        ref.invalidate(recoveryPlanProvider);
        ref.invalidate(labTestsProvider);
        ref.invalidate(reportsSummaryProvider);
        
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

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    final categoryId = category['id'] as String;
    final title = category['title'] as String;
    final icon = category['icon'] as IconData;
    final color = category['color'] as Color;
    final categoryFiles = _files[categoryId]!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                ],
              ),
              const SizedBox(height: 16),
              if (categoryFiles.isEmpty)
                GestureDetector(
                  onTap: () => _pickFile(categoryId),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: color.withOpacity(0.3), width: 1.5, style: BorderStyle.solid),
                    ),
                    child: Column(
                      children: [
                        Icon(LucideIcons.uploadCloud, color: color.withOpacity(0.6), size: 36),
                        const SizedBox(height: 8),
                        Text('Tap to upload', style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 15)),
                        const SizedBox(height: 4),
                        const Text('PDF, PNG, JPEG', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                      ],
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categoryFiles.length + 1,
                    itemBuilder: (context, index) {
                      if (index == categoryFiles.length) {
                        return GestureDetector(
                          onTap: () => _pickFile(categoryId),
                          child: Container(
                            width: 80,
                            margin: const EdgeInsets.only(right: 8, top: 5, bottom: 5),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: color.withOpacity(0.3), width: 1.5),
                            ),
                            child: Icon(LucideIcons.plus, color: color, size: 28),
                          ),
                        );
                      }
                      
                      final file = categoryFiles[index];
                      final isPdf = file.name.toLowerCase().endsWith('.pdf');
                      
                      return Container(
                        width: 85,
                        margin: const EdgeInsets.only(right: 14, top: 5),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 85,
                              height: 105,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey[100],
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: isPdf 
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(LucideIcons.fileText, color: Colors.red[400], size: 36),
                                        const SizedBox(height: 6),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 6),
                                          child: Text(file.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                                        )
                                      ],
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(11),
                                      child: Image.memory(file.bytes, fit: BoxFit.cover),
                                    ),
                            ),
                            Positioned(
                              top: -10,
                              right: -10,
                              child: GestureDetector(
                                onTap: _isUploading ? null : () {
                                  setState(() {
                                    _files[categoryId]!.removeAt(index);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 1)],
                                  ),
                                  child: const Icon(Icons.close, color: Colors.redAccent, size: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool hasAnyFiles = _files.values.any((list) => list.isNotEmpty);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Complete Profile',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Upload your medical documents securely. Our AI will automatically process them and generate your personalized care plan.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              
              ..._categories.map((category) => _buildCategoryCard(category)).toList(),

              const SizedBox(height: 16),
              
              if (hasAnyFiles) ...[
                ElevatedButton.icon(
                  onPressed: _isUploading ? null : _uploadFiles,
                  icon: _isUploading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(LucideIcons.checkCircle, size: 20),
                  label: Text(_isUploading ? 'Analyzing Documents...' : 'Upload & Finish Setup', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                    shadowColor: AppTheme.primaryOrange.withOpacity(0.4),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              
              TextButton(
                onPressed: _isUploading ? null : _skipOnboarding,
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Skip for now', style: TextStyle(color: AppTheme.textMuted, fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
