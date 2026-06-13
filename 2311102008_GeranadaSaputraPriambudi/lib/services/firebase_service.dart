//Geranada Saputra Priambudi 2311102008
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> registerWithEmailPassword(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> loginWithEmailPassword(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  CollectionReference _getUserTasksCollection() {
    if (currentUser == null) throw Exception("User not logged in");
    return _firestore.collection('users').doc(currentUser!.uid).collection('tasks');
  }

  Future<void> addTask(String title, String description) async {
    await _getUserTasksCollection().add({
      'title': title,
      'description': description,
      'isCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getTasksStream() {
    return _getUserTasksCollection()
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> updateTask(String taskId, String title, String description, bool isCompleted) async {
    await _getUserTasksCollection().doc(taskId).update({
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
    });
  }

  Future<void> updateTaskStatus(String taskId, bool isCompleted) async {
    await _getUserTasksCollection().doc(taskId).update({
      'isCompleted': isCompleted,
    });
  }

  Future<void> deleteTask(String taskId) async {
    await _getUserTasksCollection().doc(taskId).delete();
  }
}
