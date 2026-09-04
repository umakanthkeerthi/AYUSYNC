import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
  Uint8List? _imageBytes;
  String? _fileName;
  String? _selectedCategory;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  final List<Map<String, dynamic>> _categories = [
    {'id': 'Discharge Summary', 'icon': LucideIcons.fileText, 'color': Colors.blue},
    {'id': 'Prescription', 'icon': LucideIcons.pill, 'color': AppTheme.primaryOrange},
    {'id': 'X-Rays', 'icon': LucideIcons.image, 'color': Colors.purple},
    {'id': 'Lab Reports', 'icon': LucideIcons.activity, 'color': Colors.teal},
  ];

  Future<void> _pickImage(ImageSource source, String category) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _fileName = pickedFile.name;
          _selectedCategory = category;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _pickPDF(String category) async {
    try {
      final typeGroup = const XTypeGroup(label: 'pdfs', extensions: ['pdf']);
      final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);

      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _fileName = file.name;
          _selectedCategory = category;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking PDF: $e')),
        );
      }
    }
  }

  void _showSourcePicker(String category) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Upload $category', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _SourceOptionCard(
                    icon: LucideIcons.camera,
                    title: 'Camera',
                    color: AppTheme.primaryOrange,
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera, category);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SourceOptionCard(
                    icon: LucideIcons.image,
                    title: 'Gallery',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery, category);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SourceOptionCard(
                    icon: LucideIcons.fileText,
                    title: 'PDF File',
                    color: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      _pickPDF(category);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadImage() async {
    if (_imageBytes == null || _selectedCategory == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final patientId = ref.read(authProvider).patientId;
      if (patientId == null) throw Exception("Patient ID not found");
      
      final repo = ref.read(patientRepositoryProvider);
      await repo.uploadMedicalRecord(patientId, _imageBytes!, _fileName ?? 'document.pdf', _selectedCategory!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$_selectedCategory uploaded successfully! Our AI is processing it.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.red,
          ),
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
    final isPdf = _fileName?.toLowerCase().endsWith('.pdf') == true;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Upload Records'),
        elevation: 0,
        backgroundColor: AppTheme.backgroundLight,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'What would you like to upload?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select a category below to upload your documents securely. Our AI agent will automatically process the information.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppTheme.textMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                
                if (_imageBytes != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Preview: $_selectedCategory',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                      TextButton.icon(
                        onPressed: _isUploading ? null : () => setState(() => _imageBytes = null),
                        icon: Icon(LucideIcons.x, size: 16),
                        label: const Text('Clear'),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GlassCard(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: isPdf
                          ? Container(
                              height: 300,
                              width: double.infinity,
                              color: Colors.grey[100],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(LucideIcons.fileText, size: 80, color: Colors.red[400]),
                                  const SizedBox(height: 16),
                                  Text(_fileName ?? 'Document.pdf', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                            )
                          : Image.memory(
                              _imageBytes!,
                              height: 300,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _isUploading ? null : _uploadImage,
                    icon: Icon(LucideIcons.uploadCloud, size: 20),
                    label: const Text('Confirm & Upload', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                  ),
                ] else ...[
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      return _CategoryCard(
                        title: category['id'],
                        icon: category['icon'],
                        color: category['color'],
                        onTap: () => _showSourcePicker(category['id']),
                      );
                    },
                  ),
                ]
              ],
            ),
          ),
          
          if (_isUploading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: GlassCard(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: AppTheme.primaryOrange),
                        SizedBox(height: 24),
                        Text('Analyzing with AI...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2), width: 1),
            color: color.withOpacity(0.05),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 36, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SourceOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _SourceOptionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
