// Retha Anggreani 2311102265 IF-11-05
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/book_model.dart';

class BookService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  CollectionReference<Map<String, dynamic>> get _booksCollection =>
      _db.collection('books');

  /// Stream all books for current user, ordered by createdAt desc
  Stream<List<Book>> getBooksStream() {
    return _booksCollection
        .where('userId', isEqualTo: _userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Book.fromFirestore(doc)).toList());
  }

  /// Add a new book
  Future<void> addBook(Book book) async {
    await _booksCollection.add(book.toFirestore());
  }

  /// Update an existing book
  Future<void> updateBook(Book book) async {
    await _booksCollection.doc(book.id).update({
      'judul': book.judul,
      'penulis': book.penulis,
      'kategori': book.kategori,
      'tahunTerbit': book.tahunTerbit,
      'statusBaca': book.statusBaca.label,
    });
  }

  /// Delete a book
  Future<void> deleteBook(String bookId) async {
    await _booksCollection.doc(bookId).delete();
  }

  /// Get books count by status
  Future<Map<StatusBaca, int>> getBookStats() async {
    final snap = await _booksCollection
        .where('userId', isEqualTo: _userId)
        .get();

    final books = snap.docs.map((doc) => Book.fromFirestore(doc)).toList();

    return {
      StatusBaca.belumDibaca:
          books.where((b) => b.statusBaca == StatusBaca.belumDibaca).length,
      StatusBaca.sedangDibaca:
          books.where((b) => b.statusBaca == StatusBaca.sedangDibaca).length,
      StatusBaca.sudahDibaca:
          books.where((b) => b.statusBaca == StatusBaca.sudahDibaca).length,
    };
  }
}
