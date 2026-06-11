import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../utils/formatters.dart';

class TransactionListItem extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
  });

  static const Map<String, IconData> _kategoriIcons = {
    'Gaji': Icons.work_outline,
    'Freelance': Icons.laptop_outlined,
    'Bisnis': Icons.business_outlined,
    'Investasi': Icons.trending_up,
    'Hadiah': Icons.card_giftcard_outlined,
    'Makanan & Minuman': Icons.restaurant_outlined,
    'Transportasi': Icons.directions_car_outlined,
    'Belanja': Icons.shopping_bag_outlined,
    'Tagihan': Icons.receipt_outlined,
    'Kesehatan': Icons.medical_services_outlined,
    'Hiburan': Icons.movie_outlined,
    'Pendidikan': Icons.school_outlined,
    'Lainnya': Icons.more_horiz,
  };

  @override
  Widget build(BuildContext context) {
    final isPemasukan = transaction.tipe == TransactionType.pemasukan;
    final color =
        isPemasukan ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F);
    final icon =
        _kategoriIcons[transaction.kategori] ?? Icons.payment_outlined;

    // RepaintBoundary: isolasi repaint tiap item saat scroll agar tidak
    // memicu repaint item lain yang tidak berubah
    return RepaintBoundary(
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Icon kategori
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),

              // Info transaksi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.kategori,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      transaction.keterangan,
                      style:
                          TextStyle(color: Colors.grey[600], fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.formatDate(transaction.tanggal),
                      style:
                          TextStyle(color: Colors.grey[400], fontSize: 11),
                    ),
                  ],
                ),
              ),

              // Nominal + tombol aksi
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isPemasukan ? '+' : '-'} ${Formatters.formatCurrency(transaction.nominal)}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: onEdit,
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(Icons.edit_outlined,
                              size: 18, color: Colors.blue[600]),
                        ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: onDelete,
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(Icons.delete_outline,
                              size: 18, color: Colors.red[600]),
                        ),
                      ),
                    ],
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
