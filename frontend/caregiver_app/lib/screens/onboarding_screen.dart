import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';
import '../utils/theme.dart';
import '../main.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  bool _isLoading = false;

  Future<void> _loginCaregiver() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/v1/caregivers/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _username,
          'password': _password
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Navigate to Dashboard
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MainLayout(caregiverId: data['caregiver_id'])),
        );
      } else {
        _showError(data['detail'] ?? 'Login failed.');
      }
    } catch (e) {
      _showError('Network error connecting to AyuSync Backend.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE0F2F1), Color(0xFFF3F4F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: AyuTheme.primary.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.heartHandshake, size: 48, color: AyuTheme.primary)
                              .animate().scale(delay: 200.ms, duration: 500.ms),
                          const SizedBox(height: 16),
                          const Text(
                            "AyuSync Caregiver",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AyuTheme.primary,
                            ),
                          ).animate().fadeIn(),
                          const SizedBox(height: 8),
                          const Text(
                            "Link your account to your loved one",
                            style: TextStyle(color: AyuTheme.textMuted),
                          ).animate().fadeIn(delay: 100.ms),
                          const SizedBox(height: 32),
                          
                          _buildTextField(LucideIcons.user, "Username", (val) => _username = val!),
                          const SizedBox(height: 16),
                          _buildTextField(LucideIcons.lock, "Password", (val) => _password = val!, isObscure: true),
                          
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _loginCaregiver,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AyuTheme.primary,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading 
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text("Login", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ).animate().slideY(begin: 0.5, delay: 300.ms),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(IconData icon, String hint, void Function(String?) onSaved, {bool isObscure = false}) {
    return TextFormField(
      obscureText: isObscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AyuTheme.primary.withOpacity(0.6)),
        hintText: hint,
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (val) => val == null || val.isEmpty ? "Required" : null,
      onSaved: onSaved,
    ).animate().fadeIn(duration: 400.ms);
  }
}

