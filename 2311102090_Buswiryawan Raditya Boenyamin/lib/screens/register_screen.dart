// 2311102090-Buswiryawan Raditya Boenyamin
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  final bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final success = await _authService.register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _nameController.text.trim(),
        );
        if (success && mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              title: Text('SUCCESS::ACCOUNT_CREATED', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w800, fontSize: 16)),
              content: Text('IDENT_VERIFIED. PLEASE_PROCEED_TO_LOGIN.', style: GoogleFonts.jetBrainsMono(fontSize: 12)),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  child: Text('REDIRECT_TO_LOGIN', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w700, fontSize: 12)),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('REG_ERR::${e.toString().toUpperCase()}', style: GoogleFonts.jetBrainsMono(fontSize: 11)),
              backgroundColor: Colors.redAccent,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ACCOUNT\nREGISTRATION',
                style: theme.textTheme.displayLarge?.copyWith(height: 0.9, letterSpacing: -2),
              ),
              const SizedBox(height: 12),
              Text(
                'START_NEW_SESSION_NODE',
                style: GoogleFonts.jetBrainsMono(fontSize: 12, color: theme.colorScheme.primary.withOpacity(0.5), fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('FULL_NAME_STRING'),
                    TextFormField(
                      controller: _nameController,
                      style: GoogleFonts.jetBrainsMono(fontSize: 14),
                      validator: (v) => (v == null || v.isEmpty) ? 'ERR_REQUIRED' : null,
                      decoration: const InputDecoration(hintText: 'John Doe'),
                    ),
                    const SizedBox(height: 24),
                    _buildLabel('EMAIL_ADDRESS'),
                    TextFormField(
                      controller: _emailController,
                      style: GoogleFonts.jetBrainsMono(fontSize: 14),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => (v == null || !v.contains('@')) ? 'ERR_INVALID_EMAIL' : null,
                      decoration: const InputDecoration(hintText: 'user@domain.io'),
                    ),
                    const SizedBox(height: 24),
                    _buildLabel('ACCESS_TOKEN_SECRET'),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: GoogleFonts.jetBrainsMono(fontSize: 14),
                      validator: (v) => (v == null || v.length < 6) ? 'ERR_TOO_SHORT' : null,
                      decoration: const InputDecoration(hintText: '••••••••'),
                    ),
                    const SizedBox(height: 24),
                    _buildLabel('CONFIRM_TOKEN'),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscurePassword,
                      style: GoogleFonts.jetBrainsMono(fontSize: 14),
                      validator: (v) => v != _passwordController.text ? 'ERR_MISMATCH' : null,
                      decoration: const InputDecoration(hintText: '••••••••'),
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        child: _isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('INITIALIZE_ACCOUNT'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'RETURN_TO_LOGIN_INDEX',
                          style: GoogleFonts.jetBrainsMono(fontSize: 12, color: theme.colorScheme.primary, decoration: TextDecoration.underline),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(
        text,
        style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),
      ),
    );
  }
}
