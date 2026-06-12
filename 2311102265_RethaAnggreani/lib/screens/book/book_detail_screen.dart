// Retha Anggreani 2311102265 IF-11-05
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/book_model.dart';
import '../../services/book_service.dart';
import '../../services/notification_service.dart';
import 'book_form_screen.dart';

class BookDetailScreen extends StatelessWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  static const primaryBrown = Color(0xFF5C3317);
  static const lightBrown = Color(0xFF8B5E3C);
  static const cream = Color(0xFFF5F0E8);
  static const darkCream = Color(0xFFE8DCC8);

  Color _statusColor(StatusBaca status) {
    switch (status) {
      case StatusBaca.belumDibaca:
        return const Color(0xFF9E9E9E);
      case StatusBaca.sedangDibaca:
        return const Color(0xFF1976D2);
      case StatusBaca.sudahDibaca:
        return const Color(0xFF388E3C);
    }
  }

  IconData _statusIcon(StatusBaca status) {
    switch (status) {
      case StatusBaca.belumDibaca:
        return Icons.bookmark_border;
      case StatusBaca.sedangDibaca:
        return Icons.menu_book;
      case StatusBaca.sudahDibaca:
        return Icons.check_circle_outline;
    }
  }

  Future<void> _deleteBook(BuildContext context) async {
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
            child:
                Text('Batal', style: GoogleFonts.lato(color: lightBrown)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await BookService().deleteBook(book.id);
      await NotificationService.showBookNotification(
        title: 'Buku Dihapus',
        body: '"${book.judul}" telah dihapus dari koleksimu.',
      );
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(book.statusBaca);

    return Scaffold(
      backgroundColor: cream,
      body: CustomScrollView(
        slivers: [
          // Custom app bar
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: primaryBrown,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: cream),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: cream),
                tooltip: 'Edit',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => BookFormScreen(book: book)),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: cream),
                tooltip: 'Hapus',
                onPressed: () => _deleteBook(context),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: primaryBrown,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Container(
                      width: 80,
                      height: 100,
                      decoration: BoxDecoration(
                        color: cream,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          book.judul.isNotEmpty
                              ? book.judul[0].toUpperCase()
                              : '?',
                          style: GoogleFonts.merriweather(
                            color: primaryBrown,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    book.judul,
                    style: GoogleFonts.merriweather(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryBrown,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'oleh ${book.penulis}',
                    style: GoogleFonts.lato(
                        fontSize: 15, color: lightBrown),
                  ),
                  const SizedBox(height: 16),

                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_statusIcon(book.statusBaca),
                            color: statusColor, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          book.statusBaca.label,
                          style: GoogleFonts.lato(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Detail info cards
                  _buildInfoCard([
                    _buildInfoRow(
                        Icons.category_outlined, 'Kategori', book.kategori),
                    _buildDivider(),
                    _buildInfoRow(Icons.calendar_today_outlined, 'Tahun Terbit',
                        book.tahunTerbit.toString()),
                    if (book.createdAt != null) ...[
                      _buildDivider(),
                      _buildInfoRow(
                        Icons.access_time,
                        'Ditambahkan',
                        '${book.createdAt!.day}/${book.createdAt!.month}/${book.createdAt!.year}',
                      ),
                    ],
                  ]),

                  const SizedBox(height: 32),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => BookFormScreen(book: book)),
                          ),
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryBrown,
                            side: const BorderSide(color: primaryBrown),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _deleteBook(context),
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Hapus'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.error,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryBrown.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: lightBrown),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.lato(
                      fontSize: 11, color: lightBrown)),
              const SizedBox(height: 2),
              Text(value,
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: primaryBrown,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 52,
      color: const Color(0xFF8B5E3C).withOpacity(0.15),
    );
  }
}
