//Kartika Pringgo Hutomo
//2311102196
//IF-11-05
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  
  String email = '';
  String password = '';
  String error = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('FitTrack - Register', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: loading 
          ? Center(child: CircularProgressIndicator(color: Colors.orange))
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 40.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.person_add_alt_1, size: 80, color: Colors.orange),
                      SizedBox(height: 40.0),
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.orange, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.orange, width: 2.0),
                          ),
                        ),
                        validator: (val) => val!.isEmpty ? 'Masukkan email' : null,
                        onChanged: (val) {
                          setState(() => email = val);
                        },
                      ),
                      SizedBox(height: 20.0),
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.orange, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.orange, width: 2.0),
                          ),
                        ),
                        obscureText: true,
                        validator: (val) => val!.length < 6 ? 'Password minimal 6 karakter' : null,
                        onChanged: (val) {
                          setState(() => password = val);
                        },
                      ),
                      SizedBox(height: 30.0),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: Text('Register', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => loading = true);
                              try {
                                dynamic result = await _authService.registerWithEmailAndPassword(email, password);
                                if (result != null) {
                                  Navigator.pushReplacement(
                                    context, 
                                    MaterialPageRoute(builder: (context) => HomeScreen())
                                  );
                                }
                              } catch (e) {
                                setState(() {
                                  error = 'Gagal register. Pastikan format email benar.';
                                  loading = false;
                                });
                              }
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        error,
                        style: TextStyle(color: Colors.red, fontSize: 14.0),
                      ),
                      TextButton(
                        child: Text('Sudah punya akun? Login di sini', style: TextStyle(color: Colors.orange)),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen())
                          );
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
