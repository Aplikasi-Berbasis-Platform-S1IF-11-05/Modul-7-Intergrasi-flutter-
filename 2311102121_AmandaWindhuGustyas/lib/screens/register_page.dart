// NIM: 2311102121
// Nama: Amanda Windhu Gustyas
import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';
import 'home_page.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AppFirebaseService _firebaseService = AppFirebaseService();
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = false;

  void _register() async {
    setState(() => _isLoading = true);
    try {
      await _firebaseService.registerWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      await _notificationService.showNotification(
        id: 11,
        title: "Registrasi Berhasil! ✨",
        body: "Akun ${_emailController.text.trim()} berhasil dibuat. Selamat bergabung!",
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isPassword = false, TextInputType type = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: type,
          decoration: InputDecoration(
            hintText: "Masukkan $label",
            prefixIcon: Icon(icon),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3F3D56), Color(0xFF6C63FF)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_add_alt_1_rounded, size: 80, color: Colors.white),
                  const SizedBox(height: 20),
                  const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    "Sign up to get started",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Card(
                    color: Colors.white.withValues(alpha: 0.95),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          _buildTextField("Email Address", _emailController, Icons.email_outlined, type: TextInputType.emailAddress),
                          const SizedBox(height: 16),
                          _buildTextField("Password", _passwordController, Icons.lock_outline, isPassword: true),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            child: _isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : ElevatedButton(
                                    onPressed: _register,
                                    child: const Text("REGISTER", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginPage()),
                              );
                            },
                            child: const Text("Already have an account? Login"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Amanda Windhu Gustyas - 2311102121",
                    style: TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
