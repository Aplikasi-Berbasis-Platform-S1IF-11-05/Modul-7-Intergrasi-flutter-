import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';

class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'books';

  // Stream books untuk user tertentu (real-time)
  // Sorting dilakukan di client untuk menghindari kebutuhan composite index Firestore
  Stream<List<BookModel>> getBooksStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final books = snapshot.docs
          .map((doc) => BookModel.fromMap(doc.data(), doc.id))
          .toList();
      // Sort by createdAt descending di client side
      books.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return books;
    });
  }

  // Tambah buku baru
  Future<String> addBook(BookModel book) async {
    final docRef =
        await _firestore.collection(_collection).add(book.toMap());
    return docRef.id;
  }

  // Update buku
  Future<void> updateBook(BookModel book) async {
    await _firestore
        .collection(_collection)
        .doc(book.id)
        .update(book.toMap());
  }

  // Hapus buku
  Future<void> deleteBook(String bookId) async {
    await _firestore.collection(_collection).doc(bookId).delete();
  }

  // Ambil buku berdasarkan ID
  Future<BookModel?> getBookById(String bookId) async {
    final doc =
        await _firestore.collection(_collection).doc(bookId).get();
    if (doc.exists) {
      return BookModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }
}
