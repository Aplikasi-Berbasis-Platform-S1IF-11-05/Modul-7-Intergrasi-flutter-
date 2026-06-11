import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final email = TextEditingController();
  final password = TextEditingController();

  Future register() async {
    try {
      await Supabase.instance.client.auth.signUp(
        email: email.text,
        password: password.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Register berhasil"))
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: email,
              decoration: const InputDecoration(
                labelText: "Email",
              ),
            ),

            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: register,
              child: const Text("Register"),
            )
          ],
        ),
      ),
    );
  }
}