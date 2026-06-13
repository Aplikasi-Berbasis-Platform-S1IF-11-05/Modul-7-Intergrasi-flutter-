// Retha Anggreani 2311102265 IF-11-05
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/book_model.dart';
import '../../services/auth_service.dart';
import '../../services/book_service.dart';
import '../../services/notification_service.dart';
import '../book/book_form_screen.dart';
import '../book/book_detail_screen.dart';
import '../../widgets/book_card.dart';
import '../../widgets/stats_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _bookService = BookService();
  final _searchController = TextEditingController();

  String _searchQuery = '';
  StatusBaca? _filterStatus;

  static const primaryBrown = Color(0xFF5C3317);
  static const cream = Color(0xFFF5F0E8);
  static const darkCream = Color(0xFFE8DCC8);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Keluar',
            style: GoogleFonts.merriweather(
                color: primaryBrown, fontWeight: FontWeight.bold)),
        content: Text('Apakah kamu yakin ingin keluar?',
            style: GoogleFonts.lato(color: primaryBrown)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal',
                style: GoogleFonts.lato(color: const Color(0xFF8B5E3C))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.logout();
    }
  }

  Future<void> _deleteBook(Book book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus Buku',
            style: GoogleFonts.merriweather(
                color: primaryBrown, fontWeight: FontWeight.bold)),
        content: Text(
          'Hapus "${book.judul}"?\nTindakan ini tidak dapat dibatalkan.',
          style: GoogleFonts.lato(color: primaryBrown),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal',
                style: GoogleFonts.lato(color: const Color(0xFF8B5E3C))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _bookService.deleteBook(book.id);
      await NotificationService.showBookNotification(
        title: 'Buku Dihapus',
        body: '"${book.judul}" telah dihapus dari koleksimu.',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${book.judul}" berhasil dihapus'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: primaryBrown,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  List<Book> _filterBooks(List<Book> books) {
    return books.where((b) {
      final matchQuery = _searchQuery.isEmpty ||
          b.judul.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          b.penulis.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          b.kategori.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchStatus =
          _filterStatus == null || b.statusBaca == _filterStatus;
      return matchQuery && matchStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildFilterChips(),
            _buildStatsBar(),
            Expanded(child: _buildBookList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BookFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: Text('Tambah Buku', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: primaryBrown,
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 20),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cream,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.menu_book_rounded,
                color: primaryBrown, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BookShelf',
                  style: GoogleFonts.merriweather(
                    color: cream,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Halo, ${_authService.displayName}!',
                  style: GoogleFonts.lato(
                    color: cream.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: cream),
            tooltip: 'Keluar',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: primaryBrown,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: GoogleFonts.lato(color: primaryBrown),
        decoration: InputDecoration(
          hintText: 'Cari judul, penulis, atau kategori...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          fillColor: cream,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    const options = [null, StatusBaca.belumDibaca, StatusBaca.sedangDibaca, StatusBaca.sudahDibaca];
    const labels = ['Semua', 'Belum Dibaca', 'Sedang Dibaca', 'Sudah Dibaca'];

    return Container(
      height: 48,
      color: darkCream,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: options.length,
        separatorBuilder: (context, i) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final isSelected = _filterStatus == options[i];
          return FilterChip(
            label: Text(labels[i],
                style: GoogleFonts.lato(
                  color: isSelected ? cream : primaryBrown,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                )),
            selected: isSelected,
            onSelected: (_) => setState(() => _filterStatus = options[i]),
            backgroundColor: cream,
            selectedColor: primaryBrown,
            checkmarkColor: cream,
            side: BorderSide(
              color: isSelected ? primaryBrown : const Color(0xFF8B5E3C).withOpacity(0.4),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          );
        },
      ),
    );
  }

  Widget _buildStatsBar() {
    return FutureBuilder<Map<StatusBaca, int>>(
      future: _bookService.getBookStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        return StatsBar(stats: snapshot.data!);
      },
    );
  }

  Widget _buildBookList() {
    return StreamBuilder<List<Book>>(
      stream: _bookService.getBooksStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: primaryBrown),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Terjadi kesalahan: ${snapshot.error}',
                style: GoogleFonts.lato(color: primaryBrown)),
          );
        }

        final allBooks = snapshot.data ?? [];
        final books = _filterBooks(allBooks);

        if (allBooks.isEmpty) {
          return _buildEmptyState(
            icon: Icons.library_books_outlined,
            title: 'Koleksimu kosong',
            subtitle: 'Mulai tambahkan buku pertamamu!',
          );
        }

        if (books.isEmpty) {
          return _buildEmptyState(
            icon: Icons.search_off_rounded,
            title: 'Tidak ditemukan',
            subtitle: 'Coba kata kunci atau filter lain',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 100),
          itemCount: books.length,
          itemBuilder: (context, index) {
            return BookCard(
              book: books[index],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookDetailScreen(book: books[index]),
                ),
              ),
              onEdit: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookFormScreen(book: books[index]),
                ),
              ),
              onDelete: () => _deleteBook(books[index]),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: primaryBrown.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.merriweather(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryBrown.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.lato(
                fontSize: 14,
                color: const Color(0xFF8B5E3C).withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
