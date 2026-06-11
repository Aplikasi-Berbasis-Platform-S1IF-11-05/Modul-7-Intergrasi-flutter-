import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Pengembang')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_circle, size: 100, color: Colors.purple),
            const SizedBox(height: 20),
            const Text('Aplikasi Manajemen Lumubi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('NIM: 2311102026', style: TextStyle(fontSize: 16)),
            const Text('Program Studi: Teknik Informatika', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => logout(context),
            )
          ],
        ),
      ),
    );
  }
}