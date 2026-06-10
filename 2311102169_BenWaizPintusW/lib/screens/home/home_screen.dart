//Ben Waiz Pintus W.
//2311102169
//IF-11-05
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/transaction_service.dart';
import '../../models/transaction_model.dart';
import '../../utils/formatters.dart';
import '../../utils/notification_helper.dart';
import '../transaction/add_edit_transaction_screen.dart';
import '../../widgets/summary_card.dart';
import '../../widgets/transaction_list_item.dart';
import '../../widgets/chart_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _transactionService = TransactionService();
  int _selectedIndex = 0;

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _authService.logout();
    }
  }

  Future<void> _deleteTransaction(TransactionModel transaction) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Transaksi'),
        content: Text(
          'Hapus transaksi ${transaction.kategori} sebesar '
          '${Formatters.formatCurrency(transaction.nominal)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _transactionService.deleteTransaction(transaction.id);
      if (mounted) NotificationHelper.showDeleteNotification(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = _authService.currentUser!.uid;
    final userEmail = _authService.currentUser!.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.account_balance_wallet_rounded, size: 22),
            const SizedBox(width: 8),
            const Text(
              'SmartExpense',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Keluar',
            onPressed: _logout,
          ),
        ],
      ),
      body: StreamBuilder<List<TransactionModel>>(
        stream: _transactionService.getTransactions(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
            );
          }

          final transactions = snapshot.data ?? [];
          final totalPemasukan =
              _transactionService.getTotalPemasukan(transactions);
          final totalPengeluaran =
              _transactionService.getTotalPengeluaran(transactions);
          final saldo = _transactionService.getSaldo(transactions);

          // Render hanya tab yang aktif (lazy) — tidak render semua sekaligus
          return switch (_selectedIndex) {
            0 => _buildDashboard(
                transactions: transactions,
                totalPemasukan: totalPemasukan,
                totalPengeluaran: totalPengeluaran,
                saldo: saldo,
                userId: userId,
              ),
            1 => _buildTransactionList(transactions, userId),
            2 => ChartSection(
                transactions: transactions,
                totalPemasukan: totalPemasukan,
                totalPengeluaran: totalPengeluaran,
              ),
            3 => _buildProfile(userEmail),
            _ => const SizedBox.shrink(),
          };
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF2E7D32).withValues(alpha: 0.1),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Color(0xFF2E7D32)),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt, color: Color(0xFF2E7D32)),
            label: 'Transaksi',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart, color: Color(0xFF2E7D32)),
            label: 'Grafik',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Color(0xFF2E7D32)),
            label: 'Profil',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final nav = Navigator.of(context);
          final scaffoldCtx = ScaffoldMessenger.of(context);
          final result = await nav.push(
            MaterialPageRoute(
              builder: (_) => AddEditTransactionScreen(userId: userId),
            ),
          );
          if (!mounted) return;
          if (result is TransactionModel) {
            NotificationHelper.showCreateNotificationOnMessenger(
                scaffoldCtx, result);
          }
        },
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }

  Widget _buildDashboard({
    required List<TransactionModel> transactions,
    required double totalPemasukan,
    required double totalPengeluaran,
    required double saldo,
    required String userId,
  }) {
    final recent = transactions.take(5).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Saldo Card
          SummaryCard(
            saldo: saldo,
            totalPemasukan: totalPemasukan,
            totalPengeluaran: totalPengeluaran,
          ),
          const SizedBox(height: 24),

          // Recent Transactions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Transaksi Terbaru',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _selectedIndex = 1),
                child: const Text('Lihat Semua',
                    style: TextStyle(color: Color(0xFF2E7D32))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (transactions.isEmpty)
            _buildEmptyState()
          else
            ...recent.map(
              (t) => TransactionListItem(
                transaction: t,
                onEdit: () async {
                  final nav = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);
                  final result = await nav.push(
                    MaterialPageRoute(
                      builder: (_) => AddEditTransactionScreen(
                        userId: userId,
                        transaction: t,
                      ),
                    ),
                  );
                  if (!mounted) return;
                  if (result == 'updated') {
                    NotificationHelper.showUpdateNotificationOnMessenger(
                        messenger);
                  }
                },
                onDelete: () => _deleteTransaction(t),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(
      List<TransactionModel> transactions, String userId) {
    return transactions.isEmpty
        ? _buildEmptyState()
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            itemBuilder: (ctx, i) => TransactionListItem(
              transaction: transactions[i],
              onEdit: () async {
                final nav = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                final result = await nav.push(
                  MaterialPageRoute(
                    builder: (_) => AddEditTransactionScreen(
                      userId: userId,
                      transaction: transactions[i],
                    ),
                  ),
                );
                if (!mounted) return;
                if (result == 'updated') {
                  NotificationHelper.showUpdateNotificationOnMessenger(
                      messenger);
                }
              },
              onDelete: () => _deleteTransaction(transactions[i]),
            ),
          );
  }

  Widget _buildProfile(String email) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 48, color: Color(0xFF2E7D32)),
                ),
                const SizedBox(height: 12),
                Text(
                  email,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFFC62828)),
              title: const Text('Keluar',
                  style: TextStyle(color: Color(0xFFC62828))),
              onTap: _logout,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 64, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'Belum ada transaksi',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap + untuk menambah transaksi',
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
