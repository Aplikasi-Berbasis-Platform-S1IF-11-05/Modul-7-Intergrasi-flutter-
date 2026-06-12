// Retha Anggreani 2311102265 IF-11-05
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/book_model.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  static const primaryBrown = Color(0xFF5C3317);
  static const lightBrown = Color(0xFF8B5E3C);
  static const cream = Color(0xFFF5F0E8);
  static const darkCream = Color(0xFFE8DCC8);

  Color get _statusColor {
    switch (book.statusBaca) {
      case StatusBaca.belumDibaca:
        return const Color(0xFF9E9E9E);
      case StatusBaca.sedangDibaca:
        return const Color(0xFF1976D2);
      case StatusBaca.sudahDibaca:
        return const Color(0xFF388E3C);
    }
  }

  IconData get _statusIcon {
    switch (book.statusBaca) {
      case StatusBaca.belumDibaca:
        return Icons.bookmark_border;
      case StatusBaca.sedangDibaca:
        return Icons.menu_book;
      case StatusBaca.sudahDibaca:
        return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book cover placeholder
              Container(
                width: 52,
                height: 68,
                decoration: BoxDecoration(
                  color: primaryBrown.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: primaryBrown.withOpacity(0.2),
                  ),
                ),
                child: Center(
                  child: Text(
                    book.judul.isNotEmpty
                        ? book.judul[0].toUpperCase()
                        : '?',
                    style: GoogleFonts.merriweather(
                      color: primaryBrown,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.judul,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.merriweather(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: primaryBrown,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.penulis,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        color: lightBrown,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        // Kategori chip
                        _buildChip(
                          label: book.kategori,
                          icon: Icons.category_outlined,
                          color: primaryBrown,
                        ),
                        // Tahun chip
                        _buildChip(
                          label: book.tahunTerbit.toString(),
                          icon: Icons.calendar_today_outlined,
                          color: lightBrown,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Status badge
                    Row(
                      children: [
                        Icon(_statusIcon, size: 14, color: _statusColor),
                        const SizedBox(width: 4),
                        Text(
                          book.statusBaca.label,
                          style: GoogleFonts.lato(
                            color: _statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              Column(
                children: [
                  _buildActionButton(
                    icon: Icons.edit_outlined,
                    color: primaryBrown,
                    onTap: onEdit,
                    tooltip: 'Edit',
                  ),
                  const SizedBox(height: 4),
                  _buildActionButton(
                    icon: Icons.delete_outline,
                    color: const Color(0xFFB00020),
                    onTap: onDelete,
                    tooltip: 'Hapus',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.lato(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}
