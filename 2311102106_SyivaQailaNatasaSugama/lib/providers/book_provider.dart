import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../services/book_service.dart';
import '../services/notification_service.dart';

enum BookStatus { initial, loading, loaded, error }

class BookProvider extends ChangeNotifier {
  final BookService _bookService = BookService();
  final NotificationService _notificationService = NotificationService();

  List<BookModel> _books = [];
  BookStatus _status = BookStatus.initial;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedGenre = 'Semua';

  List<BookModel> get books => _filteredBooks;
  BookStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedGenre => _selectedGenre;

  List<String> get genres {
    final genreSet = <String>{'Semua'};
    for (final book in _books) {
      if (book.genre.isNotEmpty) genreSet.add(book.genre);
    }
    return genreSet.toList()..sort();
  }

  List<BookModel> get _filteredBooks {
    return _books.where((book) {
      final matchesSearch = _searchQuery.isEmpty ||
          book.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          book.author.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesGenre =
          _selectedGenre == 'Semua' || book.genre == _selectedGenre;
      return matchesSearch && matchesGenre;
    }).toList();
  }

  void listenToBooks(String userId) {
    _status = BookStatus.loading;
    notifyListeners();

    _bookService.getBooksStream(userId).listen(
      (books) {
        _books = books;
        _status = BookStatus.loaded;
        notifyListeners();
      },
      onError: (error) {
        _status = BookStatus.error;
        // Tampilkan pesan spesifik berdasarkan jenis error
        final errStr = error.toString();
        if (errStr.contains('permission-denied') ||
            errStr.contains('PERMISSION_DENIED')) {
          _errorMessage =
              'Akses ditolak. Periksa Firestore Rules di Firebase Console.\n'
              'Set rules ke: allow read, write: if request.auth != null;';
        } else if (errStr.contains('index') ||
            errStr.contains('requires an index')) {
          _errorMessage =
              'Firestore index belum dibuat. Cek console untuk link pembuatan index.';
        } else if (errStr.contains('network') ||
            errStr.contains('unavailable')) {
          _errorMessage = 'Koneksi gagal. Periksa internet Anda.';
        } else {
          _errorMessage = 'Gagal memuat data buku.\nError: $errStr';
        }
        notifyListeners();
      },
    );
  }

  Future<bool> addBook(BookModel book) async {
    try {
      await _bookService.addBook(book);
      await _notificationService.showAddNotification(book.title);
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menambahkan buku.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBook(BookModel book) async {
    try {
      await _bookService.updateBook(book);
      await _notificationService.showUpdateNotification(book.title);
      return true;
    } catch (e) {
      _errorMessage = 'Gagal memperbarui buku.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBook(String bookId, String bookTitle) async {
    try {
      await _bookService.deleteBook(bookId);
      await _notificationService.showDeleteNotification(bookTitle);
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menghapus buku.';
      notifyListeners();
      return false;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setGenreFilter(String genre) {
    _selectedGenre = genre;
    notifyListeners();
  }

  void clearBooks() {
    _books = [];
    _status = BookStatus.initial;
    _searchQuery = '';
    _selectedGenre = 'Semua';
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
