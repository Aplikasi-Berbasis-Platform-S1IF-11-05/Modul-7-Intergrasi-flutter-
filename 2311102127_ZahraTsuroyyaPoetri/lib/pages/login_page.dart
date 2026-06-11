import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() =>
      _LoginPageState();
}

class _LoginPageState
    extends State<LoginPage> {
  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  final AuthService authService =
      AuthService();

  bool isLoading = false;

  Future<void> login() async {
    try {
      setState(() {
        isLoading = true;
      });

      await authService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomePage(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Login gagal\n$e",
          ),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffFAFAFA),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: Color(0xffE60023),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.push_pin,
                    color: Colors.white,
                    size: 50,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Pinspiration",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight:
                        FontWeight.bold,
                    color: Color(
                        0xffE60023),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Temukan dan simpan inspirasi terbaikmu",
                  textAlign:
                      TextAlign.center,
                ),

                const SizedBox(height: 40),

                Card(
                  elevation: 4,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                            20),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.all(
                            20),
                    child: Column(
                      children: [
                        TextField(
                          controller:
                              emailController,
                          decoration:
                              InputDecoration(
                            labelText:
                                "Email",
                            prefixIcon:
                                const Icon(
                              Icons.email,
                            ),
                            border:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          12),
                            ),
                          ),
                        ),

                        const SizedBox(
                            height: 15),

                        TextField(
                          controller:
                              passwordController,
                          obscureText:
                              true,
                          decoration:
                              InputDecoration(
                            labelText:
                                "Password",
                            prefixIcon:
                                const Icon(
                              Icons.lock,
                            ),
                            border:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          12),
                            ),
                          ),
                        ),

                        const SizedBox(
                            height: 20),

                        SizedBox(
                          width:
                              double.infinity,
                          height: 55,
                          child:
                              ElevatedButton(
                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  const Color(
                                      0xffE60023),
                              foregroundColor:
                                  Colors.white,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            15),
                              ),
                            ),
                            onPressed:
                                isLoading
                                    ? null
                                    : login,
                            child:
                                isLoading
                                    ? const CircularProgressIndicator(
                                        color:
                                            Colors
                                                .white,
                                      )
                                    : const Text(
                                        "LOGIN",
                                      ),
                          ),
                        ),

                        const SizedBox(
                            height: 10),

                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const RegisterPage(),
                              ),
                            );
                          },
                          child: const Text(
                            "Belum punya akun? Register",
                            style:
                                TextStyle(
                              color: Color(
                                  0xffE60023),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}