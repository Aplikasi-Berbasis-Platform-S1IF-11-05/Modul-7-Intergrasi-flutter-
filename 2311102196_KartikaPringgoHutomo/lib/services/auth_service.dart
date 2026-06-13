//Kartika Pringgo Hutomo
//2311102196
//IF-11-05
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Mendapatkan stream status user (login/logout)
  Stream<User?> get user => _auth.authStateChanges();

  // Mendapatkan user yang sedang login
  User? get currentUser => _auth.currentUser;

  // Register dengan Email dan Password
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  // Login dengan Email dan Password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  // Logout
  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }
}
