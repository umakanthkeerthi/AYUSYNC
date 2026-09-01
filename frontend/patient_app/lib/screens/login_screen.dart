import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'main_layout.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../providers/patient_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMsg;

  void _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() => _errorMsg = "Please enter both credentials");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    // Simulate small delay for UI smoothness
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    try {
      await ref.read(authProvider.notifier).login(username, password);
      
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MainLayout(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMsg = "Invalid Username or Password";
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Stack(
        children: [
          // Background Aesthetic
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryOrange.withOpacity(0.15),
              ),
            ).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 3000.ms),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.1),
              ),
            ),
          ),
          // Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    const Icon(
                      LucideIcons.activity,
                      size: 64,
                      color: AppTheme.primaryOrange,
                    ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.5, 0.5)),
                    const SizedBox(height: 16),
                    const Text(
                      'AyuSync',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textDark,
                        letterSpacing: -1.0,
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                    const Text(
                      'Patient Portal',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textMuted,
                        letterSpacing: 1.2,
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                    const SizedBox(height: 48),

                    // Login Form Card
                    GlassCard(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Welcome Back',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Enter your credentials to continue',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Username Field
                          TextField(
                            controller: _usernameController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: InputDecoration(
                              labelText: 'Patient ID (Username)',
                              hintText: 'e.g. AYU-1234',
                              prefixIcon: const Icon(LucideIcons.user, color: AppTheme.textMuted),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey.withOpacity(0.05),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(LucideIcons.lock, color: AppTheme.textMuted),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey.withOpacity(0.05),
                            ),
                          ),
                          const SizedBox(height: 8),

                          if (_errorMsg != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                              child: Text(
                                _errorMsg!,
                                style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center,
                              ).animate().shake(duration: 400.ms),
                            ),
                          
                          const SizedBox(height: 24),

                          // Login Button
                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryOrange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Secure Login',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
