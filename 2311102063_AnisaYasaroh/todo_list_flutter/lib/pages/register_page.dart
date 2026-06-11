import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  bool isObscure = true;

  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      _showSnack("Semua field wajib diisi", isError: true);
      return;
    }
    try {
      setState(() => isLoading = true);
      UserCredential cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
      await FirebaseFirestore.instance
          .collection("users")
          .doc(cred.user!.uid)
          .set({
            "name": nameController.text.trim(),
            "email": emailController.text.trim(),
            "createdAt": Timestamp.now(),
          });
      if (!mounted) return;
      _showSnack("Registrasi berhasil! Silakan masuk.");
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String msg = "Terjadi kesalahan";
      if (e.code == "email-already-in-use")
        msg = "Email sudah digunakan";
      else if (e.code == "weak-password")
        msg = "Password minimal 6 karakter";
      else if (e.code == "invalid-email")
        msg = "Format email tidak valid";
      else
        msg = e.message ?? msg;
      _showSnack(msg, isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: isError
            ? const Color(0xFFE53935)
            : const Color(0xFF43A047),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A3DE8), Color(0xFF9B6DFF), Color(0xFFD4ADFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      "Buat Akun Baru",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: FadeTransition(
                      opacity: _fadeIn,
                      child: SlideTransition(
                        position: _slideUp,
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white38,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.person_add_alt_1_rounded,
                                size: 38,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF6A3DE8,
                                    ).withOpacity(0.18),
                                    blurRadius: 32,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  _buildTextField(
                                    controller: nameController,
                                    hint: "Nama Lengkap",
                                    icon: Icons.person_outline_rounded,
                                  ),
                                  const SizedBox(height: 14),
                                  _buildTextField(
                                    controller: emailController,
                                    hint: "Email",
                                    icon: Icons.email_outlined,
                                    type: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: 14),
                                  _buildTextField(
                                    controller: passwordController,
                                    hint: "Password (min. 6 karakter)",
                                    icon: Icons.lock_outline,
                                    obscure: isObscure,
                                    suffix: IconButton(
                                      icon: Icon(
                                        isObscure
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: Colors.grey.shade400,
                                        size: 20,
                                      ),
                                      onPressed: () => setState(
                                        () => isObscure = !isObscure,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 54,
                                    child: ElevatedButton(
                                      onPressed: isLoading ? null : register,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF6A3DE8,
                                        ),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                      ),
                                      child: isLoading
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.5,
                                              ),
                                            )
                                          : const Text(
                                              "Buat Akun",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType type = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      obscureText: obscure,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF5F3FF),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF6A3DE8), width: 1.5),
        ),
      ),
    );
  }
}
