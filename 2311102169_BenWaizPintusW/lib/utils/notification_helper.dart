import 'package:flutter/material.dart';
import '../utils/formatters.dart';
import '../models/transaction_model.dart';

/// Helper untuk menampilkan notifikasi CRUD dalam bentuk SnackBar bergaya SmartExpense
class NotificationHelper {
  // ─── Convenience methods menerima BuildContext ───────────────────────────

  static void showSuccess(BuildContext context, String message) {
    _show(
      ScaffoldMessenger.of(context),
      message,
      const Color(0xFF2E7D32),
      Icons.check_circle_outline,
    );
  }

  static void showError(BuildContext context, String message) {
    _show(
      ScaffoldMessenger.of(context),
      message,
      const Color(0xFFC62828),
      Icons.error_outline,
    );
  }

  static void showCreateNotification(
    BuildContext context,
    TransactionModel transaction,
  ) {
    showCreateNotificationOnMessenger(
        ScaffoldMessenger.of(context), transaction);
  }

  static void showUpdateNotification(BuildContext context) {
    showUpdateNotificationOnMessenger(ScaffoldMessenger.of(context));
  }

  static void showDeleteNotification(BuildContext context) {
    showDeleteNotificationOnMessenger(ScaffoldMessenger.of(context));
  }

  // ─── Safe methods menerima ScaffoldMessengerState (gunakan setelah await) ─

  static void showCreateNotificationOnMessenger(
    ScaffoldMessengerState messenger,
    TransactionModel transaction,
  ) {
    final tipe = transaction.tipe == TransactionType.pemasukan
        ? 'Pemasukan'
        : 'Pengeluaran';
    final nominal = Formatters.formatCurrency(transaction.nominal);
    _showOn(
      messenger,
      title: 'SmartExpense',
      message: 'Transaksi $tipe $nominal berhasil disimpan',
      icon: Icons.add_circle_outline,
      color: transaction.tipe == TransactionType.pemasukan
          ? const Color(0xFF2E7D32)
          : const Color(0xFFD32F2F),
    );
  }

  static void showUpdateNotificationOnMessenger(
      ScaffoldMessengerState messenger) {
    _showOn(
      messenger,
      title: 'SmartExpense',
      message: 'Data transaksi berhasil diperbarui.',
      icon: Icons.edit_outlined,
      color: const Color(0xFF1565C0),
    );
  }

  static void showDeleteNotificationOnMessenger(
      ScaffoldMessengerState messenger) {
    _showOn(
      messenger,
      title: 'SmartExpense',
      message: 'Transaksi berhasil dihapus.',
      icon: Icons.delete_outline,
      color: const Color(0xFF6D4C41),
    );
  }

  // ─── Internal helpers ────────────────────────────────────────────────────

  static void _showOn(
    ScaffoldMessengerState messenger, {
    required String title,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      message,
                      style: const TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _show(
    ScaffoldMessengerState messenger,
    String message,
    Color color,
    IconData icon,
  ) {
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
