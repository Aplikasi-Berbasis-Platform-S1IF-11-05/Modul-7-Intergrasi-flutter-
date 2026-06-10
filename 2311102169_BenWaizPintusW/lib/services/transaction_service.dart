import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class TransactionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = 'transactions';

  /// Stream semua transaksi milik user, diurutkan dari terbaru.
  /// Sort dilakukan di client-side agar tidak perlu Composite Index Firestore.
  Stream<List<TransactionModel>> getTransactions(String userId) {
    return _db
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => TransactionModel.fromFirestore(doc))
              .toList();
          list.sort((a, b) => b.tanggal.compareTo(a.tanggal));
          return list;
        });
  }

  /// Tambah transaksi baru
  Future<void> addTransaction(TransactionModel transaction) async {
    await _db.collection(_collection).add(transaction.toFirestore());
  }

  /// Update transaksi
  Future<void> updateTransaction(TransactionModel transaction) async {
    await _db
        .collection(_collection)
        .doc(transaction.id)
        .update(transaction.toFirestore());
  }

  /// Hapus transaksi
  Future<void> deleteTransaction(String transactionId) async {
    await _db.collection(_collection).doc(transactionId).delete();
  }

  /// Hitung total pemasukan
  double getTotalPemasukan(List<TransactionModel> transactions) {
    return transactions
        .where((t) => t.tipe == TransactionType.pemasukan)
        .fold(0.0, (acc, t) => acc + t.nominal);
  }

  /// Hitung total pengeluaran
  double getTotalPengeluaran(List<TransactionModel> transactions) {
    return transactions
        .where((t) => t.tipe == TransactionType.pengeluaran)
        .fold(0.0, (acc, t) => acc + t.nominal);
  }

  /// Hitung saldo bersih
  double getSaldo(List<TransactionModel> transactions) {
    return getTotalPemasukan(transactions) - getTotalPengeluaran(transactions);
  }
}
