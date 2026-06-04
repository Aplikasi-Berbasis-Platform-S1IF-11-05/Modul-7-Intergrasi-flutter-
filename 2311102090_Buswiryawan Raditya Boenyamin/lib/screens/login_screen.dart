// 2311102090-Buswiryawan Raditya Boenyamin
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../widgets/monochrome_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final success = await _authService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        if (success && mounted) {
          Navigator.of(context).pushReplacementNamed('/tasks');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('LOGIN_FAILED::${e.toString().toUpperCase()}', 
                style: GoogleFonts.jetBrainsMono(color: Colors.white, fontSize: 12)),
              backgroundColor: Colors.black,
              behavior: SnackBarBehavior.floating,
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Logo
                const MonochromeLogo(size: 60),
                const SizedBox(height: 32),
                Text(
                  'TASK\nMANAGEMENT',
                  style: theme.textTheme.displayLarge?.copyWith(
                    height: 0.9,
                    letterSpacing: -2,
                  ),
                ),

                const SizedBox(height: 12),
                Text(
                  'SECURE_LOGIN_REQUIRED',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    color: theme.colorScheme.primary.withOpacity(0.5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 60),
                
                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('EMAIL_ADDRESS'),
                      TextFormField(
                        controller: _emailController,
                        style: GoogleFonts.jetBrainsMono(fontSize: 15),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => (v == null || !v.contains('@')) ? 'ERR_INVALID_EMAIL' : null,
                        decoration: const InputDecoration(hintText: 'user@system.io'),
                      ),
                      const SizedBox(height: 24),
                      _buildLabel('ACCESS_TOKEN'),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: GoogleFonts.jetBrainsMono(fontSize: 15),
                        validator: (v) => (v == null || v.length < 6) ? 'ERR_TOKEN_TOO_SHORT' : null,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.lock_outline : Icons.lock_open),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          child: _isLoading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('INITIALIZE_SESSION'),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Register Link
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pushNamed('/register'),
                          child: Text(
                            'CREATE_NEW_ACCOUNT_INDEX',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              color: theme.colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
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
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(
        text,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
        ),
      ),
    );
  }
}
