// NIM: 2311102121
// Nama: Amanda Windhu Gustyas
// Modul 7 - Integrasi Flutter Firebase/Supabase (Mahasiswa CRUD)
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

  // CRUD Mahasiswa
  Future<void> addMahasiswa(String nama, String nim, String jurusan) async {
    if (currentUser == null) throw Exception("User not logged in");
    
    await _firestore.collection('mahasiswa').add({
      'userId': currentUser!.uid,
      'nama': nama,
      'nim': nim,
      'jurusan': jurusan,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getMahasiswaStream() {
    if (currentUser == null) throw Exception("User not logged in");

    return _firestore
        .collection('mahasiswa')
        .where('userId', isEqualTo: currentUser!.uid)
        .snapshots();
  }

  Future<void> updateMahasiswa(String docId, String newNama, String newNim, String newJurusan) async {
    await _firestore.collection('mahasiswa').doc(docId).update({
      'nama': newNama,
      'nim': newNim,
      'jurusan': newJurusan,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteMahasiswa(String docId) async {
    await _firestore.collection('mahasiswa').doc(docId).delete();
  }
}
