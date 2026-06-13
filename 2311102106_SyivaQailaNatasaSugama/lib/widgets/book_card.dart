import 'package:flutter/material.dart';
import '../models/book_model.dart';

class BookCard extends StatelessWidget {
  final BookModel book;
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

  Color _getGenreColor(String genre) {
    final colors = {
      'Fiksi': Colors.blue,
      'Non-Fiksi': Colors.green,
      'Sains & Teknologi': Colors.teal,
      'Sejarah': Colors.brown,
      'Biografi': Colors.orange,
      'Pengembangan Diri': Colors.purple,
      'Misteri & Thriller': Colors.indigo,
      'Romansa': Colors.pink,
      'Fantasi': Colors.deepPurple,
      'Sains Fiksi': Colors.cyan,
      'Anak-Anak': Colors.amber,
      'Pendidikan': Colors.lime,
      'Agama & Spiritualitas': Colors.deepOrange,
      'Seni & Budaya': Colors.red,
    };
    return colors[genre] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final genreColor = _getGenreColor(book.genre);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Book cover placeholder
              Container(
                width: 60,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      genreColor.withAlpha(178),
                      genreColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.menu_book,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 14),
              // Book info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF2D3748),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: genreColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: genreColor.withAlpha(76)),
                          ),
                          child: Text(
                            book.genre,
                            style: TextStyle(
                              fontSize: 11,
                              color: genreColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (book.year > 0) ...[
                          const SizedBox(width: 6),
                          Text(
                            book.year.toString(),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        ...List.generate(5, (i) => Icon(
                          i < book.rating.floor()
                              ? Icons.star
                              : i < book.rating
                                  ? Icons.star_half
                                  : Icons.star_border,
                          color: Colors.amber,
                          size: 14,
                        )),
                        const SizedBox(width: 4),
                        Text(
                          book.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Action buttons
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        color: Color(0xFF6C63FF), size: 20),
                    onPressed: onEdit,
                    tooltip: 'Edit',
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline,
                        color: Colors.red.shade400, size: 20),
                    onPressed: onDelete,
                    tooltip: 'Hapus',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
