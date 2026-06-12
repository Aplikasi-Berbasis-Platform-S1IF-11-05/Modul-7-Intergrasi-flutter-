// Retha Anggreani 2311102265 IF-11-05
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/book_model.dart';

class StatsBar extends StatelessWidget {
  final Map<StatusBaca, int> stats;

  const StatsBar({super.key, required this.stats});

  static const primaryBrown = Color(0xFF5C3317);
  static const cream = Color(0xFFF5F0E8);
  static const darkCream = Color(0xFFE8DCC8);

  int get _total =>
      (stats[StatusBaca.belumDibaca] ?? 0) +
      (stats[StatusBaca.sedangDibaca] ?? 0) +
      (stats[StatusBaca.sudahDibaca] ?? 0);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: darkCream,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _buildStatItem(
            label: 'Total',
            value: _total.toString(),
            color: primaryBrown,
            icon: Icons.library_books_outlined,
          ),
          _buildDivider(),
          _buildStatItem(
            label: 'Belum',
            value: (stats[StatusBaca.belumDibaca] ?? 0).toString(),
            color: const Color(0xFF9E9E9E),
            icon: Icons.bookmark_border,
          ),
          _buildDivider(),
          _buildStatItem(
            label: 'Dibaca',
            value: (stats[StatusBaca.sedangDibaca] ?? 0).toString(),
            color: const Color(0xFF1976D2),
            icon: Icons.menu_book,
          ),
          _buildDivider(),
          _buildStatItem(
            label: 'Selesai',
            value: (stats[StatusBaca.sudahDibaca] ?? 0).toString(),
            color: const Color(0xFF388E3C),
            icon: Icons.check_circle_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                value,
                style: GoogleFonts.merriweather(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.lato(
              color: primaryBrown.withOpacity(0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 28,
      width: 1,
      color: primaryBrown.withOpacity(0.15),
    );
  }
}
