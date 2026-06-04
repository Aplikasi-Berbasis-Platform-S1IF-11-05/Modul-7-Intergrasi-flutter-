import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Menampilkan antarmuka autentikasi pengguna.
///
/// Halaman ini menyediakan formulir bagi pengguna untuk
/// masuk ke akun yang sudah ada atau mendaftar akun baru.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _loginOrRegister() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        try {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );
        } catch (ex) {
          debugPrint('Register Error: $ex');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Masuk ke Rawat.in', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black, letterSpacing: -0.5)),
              const SizedBox(height: 8),
              const Text('Silakan masuk atau daftar untuk melanjutkan.', style: TextStyle(color: Colors.black54, fontSize: 14)),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.black, fontSize: 16),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.black54),
                  filled: true,
                  fillColor: Color(0xFFF9F9F9),
                  border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Colors.black)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.black, fontSize: 16),
                decoration: const InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.black54),
                  filled: true,
                  fillColor: Color(0xFFF9F9F9),
                  border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Colors.black)),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  onPressed: _loginOrRegister,
                  child: const Text('Login / Register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 48),
              const Opacity(
                opacity: 0.3,
                child: Text(
                  'NIM: 2311102293 - Nama: Rozhak',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
