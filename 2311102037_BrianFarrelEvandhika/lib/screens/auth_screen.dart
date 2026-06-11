import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _switchTab(bool isLogin) {
    if (_isLogin == isLogin) return;
    setState(() {
      _isLogin = isLogin;
      _formKey.currentState?.reset();
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
    Provider.of<AuthProvider>(context, listen: false).clearError();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    bool success = false;
    if (_isLogin) {
      success = await authProvider.signIn(email, password);
    } else {
      success = await authProvider.signUp(email, password);
    }

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background decorative glow circles
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentPurple.withOpacity(0.12),
                    blurRadius: 80,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentCyan.withOpacity(0.12),
                    blurRadius: 80,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          
          // Scrollable layout for form
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App title & subtitle
                  Icon(
                    Icons.task_alt_rounded,
                    size: 64,
                    color: AppTheme.accentCyan,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'TaskFlow',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          foreground: Paint()
                            ..shader = const LinearGradient(
                              colors: [AppTheme.accentCyan, AppTheme.accentPurple],
                            ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isLogin
                        ? 'Silakan masuk untuk mengelola tugas Anda'
                        : 'Daftarkan akun baru untuk memulai perjalanan Anda',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 36),

                  // Auth Mode Switch Tab Buttons
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _switchTab(true),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                gradient: _isLogin
                                    ? const LinearGradient(
                                        colors: [AppTheme.accentCyan, AppTheme.accentPurple],
                                      )
                                    : null,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Masuk',
                                style: TextStyle(
                                  color: _isLogin ? AppTheme.backgroundColor : AppTheme.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _switchTab(false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                gradient: !_isLogin
                                    ? const LinearGradient(
                                        colors: [AppTheme.accentCyan, AppTheme.accentPurple],
                                      )
                                    : null,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Daftar',
                                style: TextStyle(
                                  color: !_isLogin ? AppTheme.backgroundColor : AppTheme.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Form card
                  Card(
                    elevation: 10,
                    shadowColor: Colors.black38,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Email Input
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(color: AppTheme.textPrimary),
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textSecondary),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Harap masukkan email';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                  return 'Harap masukkan email yang valid';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Password Input
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: AppTheme.textPrimary),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.textSecondary),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: AppTheme.textSecondary,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Harap masukkan password';
                                }
                                if (value.length < 6) {
                                  return 'Password minimal 6 karakter';
                                }
                                return null;
                              },
                            ),
                            
                            // Confirm Password if Signing Up
                            if (!_isLogin) ...[
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                style: const TextStyle(color: AppTheme.textPrimary),
                                decoration: InputDecoration(
                                  labelText: 'Konfirmasi Password',
                                  prefixIcon: const Icon(Icons.lock_reset_rounded, color: AppTheme.textSecondary),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                      color: AppTheme.textSecondary,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword = !_obscureConfirmPassword;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Harap konfirmasi password Anda';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Password tidak cocok';
                                  }
                                  return null;
                                },
                              ),
                            ],
                            const SizedBox(height: 24),

                            // Error Message Display
                            if (authProvider.errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.priorityHigh.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.priorityHigh.withOpacity(0.3)),
                                ),
                                child: Text(
                                  authProvider.errorMessage!,
                                  style: const TextStyle(color: AppTheme.priorityHigh, fontSize: 13),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Submit Button or Loading Spinner
                            authProvider.isLoading
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(vertical: 12.0),
                                      child: SpinKitRing(
                                        color: AppTheme.accentCyan,
                                        size: 40,
                                        lineWidth: 3,
                                      ),
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: const LinearGradient(
                                        colors: [AppTheme.accentCyan, AppTheme.accentPurple],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.accentCyan.withOpacity(0.2),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _submit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        foregroundColor: AppTheme.backgroundColor,
                                        shadowColor: Colors.transparent,
                                        elevation: 0,
                                      ),
                                      child: Text(
                                        _isLogin ? 'Masuk Sekarang' : 'Buat Akun Baru',
                                        style: const TextStyle(color: AppTheme.backgroundColor),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Connection Mode Badge/Banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: authProvider.isOnlineMode
                          ? AppTheme.accentCyan.withOpacity(0.1)
                          : AppTheme.priorityMedium.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: authProvider.isOnlineMode
                            ? AppTheme.accentCyan.withOpacity(0.2)
                            : AppTheme.priorityMedium.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          authProvider.isOnlineMode
                              ? Icons.cloud_done_outlined
                              : Icons.cloud_off_outlined,
                          size: 16,
                          color: authProvider.isOnlineMode
                              ? AppTheme.accentCyan
                              : AppTheme.priorityMedium,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          authProvider.isOnlineMode
                              ? 'Mode Online: Terkoneksi ke Supabase'
                              : 'Mode Offline: Menyimpan data di Perangkat',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: authProvider.isOnlineMode
                                ? AppTheme.accentCyan
                                : AppTheme.priorityMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
