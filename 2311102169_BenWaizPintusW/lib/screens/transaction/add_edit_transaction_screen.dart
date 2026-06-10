//Ben Waiz Pintus W.
//2311102169
//IF-11-05
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/transaction_model.dart';
import '../../services/transaction_service.dart';
import '../../utils/notification_helper.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final String userId;
  final TransactionModel? transaction;

  const AddEditTransactionScreen({
    super.key,
    required this.userId,
    this.transaction,
  });

  @override
  State<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nominalController = TextEditingController();
  final _keteranganController = TextEditingController();
  final _transactionService = TransactionService();

  TransactionType _tipe = TransactionType.pengeluaran;
  String _kategori = 'Makanan & Minuman';
  DateTime _tanggal = DateTime.now();
  bool _isLoading = false;

  bool get _isEditing => widget.transaction != null;

  static const List<String> _kategoriPemasukan = [
    'Gaji',
    'Freelance',
    'Bisnis',
    'Investasi',
    'Hadiah',
    'Lainnya',
  ];

  static const List<String> _kategoriPengeluaran = [
    'Makanan & Minuman',
    'Transportasi',
    'Belanja',
    'Tagihan',
    'Kesehatan',
    'Hiburan',
    'Pendidikan',
    'Lainnya',
  ];

  List<String> get _currentKategoriList =>
      _tipe == TransactionType.pemasukan
          ? _kategoriPemasukan
          : _kategoriPengeluaran;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final t = widget.transaction!;
      _tipe = t.tipe;
      _kategori = t.kategori;
      _tanggal = t.tanggal;
      _nominalController.text = t.nominal.toStringAsFixed(0);
      _keteranganController.text = t.keterangan;
    } else {
      _kategori = _kategoriPengeluaran.first;
    }
  }

  @override
  void dispose() {
    _nominalController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF2E7D32),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _tanggal = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final nominal = double.parse(
        _nominalController.text.replaceAll(RegExp(r'[^\d.]'), ''),
      );

      final transaction = TransactionModel(
        id: _isEditing ? widget.transaction!.id : const Uuid().v4(),
        kategori: _kategori,
        nominal: nominal,
        keterangan: _keteranganController.text.trim(),
        tanggal: _tanggal,
        tipe: _tipe,
        userId: widget.userId,
      );

      if (_isEditing) {
        await _transactionService.updateTransaction(transaction);
        if (mounted) {
          Navigator.pop(context, 'updated');
        }
      } else {
        await _transactionService.addTransaction(transaction);
        if (mounted) {
          Navigator.pop(context, transaction);
        }
      }
    } catch (e, stack) {
      debugPrint('ERROR _save: $e');
      debugPrint('STACK: $stack');
      if (mounted) {
        NotificationHelper.showError(
          context,
          e.toString().contains('permission-denied')
              ? 'Akses ditolak. Cek Firestore Rules di Firebase Console.'
              : 'Gagal menyimpan: $e',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Transaksi' : 'Tambah Transaksi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tipe Toggle
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTipeButton(
                        label: 'Pengeluaran',
                        icon: Icons.arrow_upward_rounded,
                        tipe: TransactionType.pengeluaran,
                        activeColor: const Color(0xFFD32F2F),
                      ),
                    ),
                    Expanded(
                      child: _buildTipeButton(
                        label: 'Pemasukan',
                        icon: Icons.arrow_downward_rounded,
                        tipe: TransactionType.pemasukan,
                        activeColor: const Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Nominal
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nominal',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1B5E20))),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nominalController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          prefixText: 'Rp ',
                          prefixStyle: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32)),
                          border: InputBorder.none,
                          fillColor: Colors.transparent,
                          hintText: '0',
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Nominal wajib diisi';
                          final n = double.tryParse(
                              v.replaceAll(RegExp(r'[^\d.]'), ''));
                          if (n == null || n <= 0) return 'Nominal harus lebih dari 0';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Kategori
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Kategori',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1B5E20))),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        // ignore: deprecated_member_use
                        value: _currentKategoriList.contains(_kategori)
                            ? _kategori
                            : _currentKategoriList.first,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.category_outlined,
                              color: Color(0xFF2E7D32)),
                        ),
                        items: _currentKategoriList
                            .map((k) => DropdownMenuItem(
                                  value: k,
                                  child: Text(k),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _kategori = v!),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Keterangan
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Keterangan',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1B5E20))),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _keteranganController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'Tambahkan keterangan...',
                          prefixIcon: Icon(Icons.notes_outlined,
                              color: Color(0xFF2E7D32)),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Keterangan wajib diisi';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Tanggal
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tanggal',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1B5E20))),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: const Color(0xFF2E7D32)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined,
                                  color: Color(0xFF2E7D32), size: 20),
                              const SizedBox(width: 12),
                              Text(
                                DateFormat('dd MMMM yyyy', 'id_ID')
                                    .format(_tanggal),
                                style: const TextStyle(fontSize: 15),
                              ),
                              const Spacer(),
                              const Icon(Icons.arrow_drop_down,
                                  color: Color(0xFF2E7D32)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _save,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Icon(_isEditing ? Icons.save : Icons.add_circle_outline),
                  label: Text(
                    _isEditing ? 'Simpan Perubahan' : 'Tambah Transaksi',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipeButton({
    required String label,
    required IconData icon,
    required TransactionType tipe,
    required Color activeColor,
  }) {
    final isActive = _tipe == tipe;
    return GestureDetector(
      onTap: () => setState(() {
        _tipe = tipe;
        _kategori = tipe == TransactionType.pemasukan
            ? _kategoriPemasukan.first
            : _kategoriPengeluaran.first;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isActive ? Colors.white : Colors.grey, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
