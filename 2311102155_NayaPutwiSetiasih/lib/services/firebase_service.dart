// NIM: 2311102155
// Nama: Naya Putwi Setiasih
// Modul 7 - Integrasi Flutter Firebase/Supabase (Notes App CRUD)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppFirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> loginWithEmailAndPassword(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }


  Future<void> addNote(String title, String content) async {
    if (currentUser == null) throw Exception("User not logged in");
    
    await _firestore.collection('notes').add({
      'userId': currentUser!.uid,
      'title': title,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getNotesStream() {
    if (currentUser == null) throw Exception("User not logged in");

    return _firestore
        .collection('notes')
        .where('userId', isEqualTo: currentUser!.uid)
        .snapshots();
  }

  Future<void> updateNote(String docId, String newTitle, String newContent) async {
    await _firestore.collection('notes').doc(docId).update({
      'title': newTitle,
      'content': newContent,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteNote(String docId) async {
    await _firestore.collection('notes').doc(docId).delete();
  }
}
