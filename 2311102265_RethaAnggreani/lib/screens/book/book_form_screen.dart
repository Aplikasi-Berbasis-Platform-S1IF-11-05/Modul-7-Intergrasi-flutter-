// Retha Anggreani 2311102265 IF-11-05
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/book_model.dart';
import '../../services/book_service.dart';
import '../../services/notification_service.dart';

class BookFormScreen extends StatefulWidget {
  final Book? book; // null = tambah, non-null = edit

  const BookFormScreen({super.key, this.book});

  @override
  State<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bookService = BookService();

  late final TextEditingController _judulController;
  late final TextEditingController _penulisController;
  late final TextEditingController _kategoriController;
  late final TextEditingController _tahunController;

  StatusBaca _statusBaca = StatusBaca.belumDibaca;
  bool _isLoading = false;

  bool get _isEditing => widget.book != null;

  static const primaryBrown = Color(0xFF5C3317);
  static const cream = Color(0xFFF5F0E8);

  final List<String> _kategoriSuggestions = [
    'Fiksi',
    'Non-Fiksi',
    'Sains',
    'Teknologi',
    'Sejarah',
    'Biografi',
    'Bisnis',
    'Motivasi',
    'Agama',
    'Sastra',
    'Filsafat',
    'Psikologi',
    'Pendidikan',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    final b = widget.book;
    _judulController = TextEditingController(text: b?.judul ?? '');
    _penulisController = TextEditingController(text: b?.penulis ?? '');
    _kategoriController = TextEditingController(text: b?.kategori ?? '');
    _tahunController =
        TextEditingController(text: b != null ? b.tahunTerbit.toString() : '');
    _statusBaca = b?.statusBaca ?? StatusBaca.belumDibaca;
  }

  @override
  void dispose() {
    _judulController.dispose();
    _penulisController.dispose();
    _kategoriController.dispose();
    _tahunController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final tahun = int.tryParse(_tahunController.text) ?? 0;

      if (_isEditing) {
        final updated = widget.book!.copyWith(
          judul: _judulController.text.trim(),
          penulis: _penulisController.text.trim(),
          kategori: _kategoriController.text.trim(),
          tahunTerbit: tahun,
          statusBaca: _statusBaca,
        );
        await _bookService.updateBook(updated);
        await NotificationService.showBookNotification(
          title: 'Buku Diperbarui',
          body: '"${updated.judul}" berhasil diperbarui.',
        );
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"${updated.judul}" berhasil diperbarui'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: primaryBrown,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } else {
        final newBook = Book(
          id: '',
          judul: _judulController.text.trim(),
          penulis: _penulisController.text.trim(),
          kategori: _kategoriController.text.trim(),
          tahunTerbit: tahun,
          statusBaca: _statusBaca,
          userId: userId,
          createdAt: DateTime.now(),
        );
        await _bookService.addBook(newBook);
        await NotificationService.showBookNotification(
          title: 'Buku Ditambahkan',
          body: '"${newBook.judul}" berhasil ditambahkan ke koleksimu.',
        );
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"${newBook.judul}" berhasil ditambahkan'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: primaryBrown,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Buku' : 'Tambah Buku'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Book icon header
            Center(
              child: Container(
                width: 72,
                height: 72,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: primaryBrown.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.auto_stories_outlined,
                  size: 40,
                  color: primaryBrown,
                ),
              ),
            ),

            _buildSectionLabel('Informasi Buku'),
            const SizedBox(height: 12),

            // Judul
            TextFormField(
              controller: _judulController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Judul Buku',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Judul tidak boleh kosong';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Penulis
            TextFormField(
              controller: _penulisController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Penulis',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Penulis tidak boleh kosong';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Kategori with autocomplete
            Autocomplete<String>(
              initialValue: TextEditingValue(text: _kategoriController.text),
              optionsBuilder: (textEditingValue) {
                if (textEditingValue.text.isEmpty) return _kategoriSuggestions;
                return _kategoriSuggestions.where((k) => k
                    .toLowerCase()
                    .contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: (v) => _kategoriController.text = v,
              fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                // sync with our controller
                controller.text = _kategoriController.text;
                controller.addListener(() {
                  _kategoriController.text = controller.text;
                });
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Kategori tidak boleh kosong';
                    }
                    return null;
                  },
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        color: cream,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (context, i) {
                          final opt = options.elementAt(i);
                          return ListTile(
                            title: Text(opt,
                                style: GoogleFonts.lato(color: primaryBrown)),
                            onTap: () => onSelected(opt),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),

            // Tahun Terbit
            TextFormField(
              controller: _tahunController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Tahun Terbit',
                prefixIcon: Icon(Icons.calendar_today_outlined),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Tahun tidak boleh kosong';
                final y = int.tryParse(v);
                if (y == null) return 'Masukkan angka tahun yang valid';
                if (y < 1000 || y > DateTime.now().year + 5) {
                  return 'Tahun tidak valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            _buildSectionLabel('Status Baca'),
            const SizedBox(height: 12),

            // Status baca selector
            ..._buildStatusOptions(),

            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submit,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Icon(_isEditing ? Icons.save_outlined : Icons.add),
                label: Text(_isEditing ? 'Simpan Perubahan' : 'Tambah Buku'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.merriweather(
        color: primaryBrown,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  List<Widget> _buildStatusOptions() {
    final options = [
      (StatusBaca.belumDibaca, Icons.bookmark_border, const Color(0xFF9E9E9E)),
      (StatusBaca.sedangDibaca, Icons.menu_book, const Color(0xFF1976D2)),
      (StatusBaca.sudahDibaca, Icons.check_circle_outline, const Color(0xFF388E3C)),
    ];

    return options.map((entry) {
      final (status, icon, color) = entry;
      final isSelected = _statusBaca == status;
      return GestureDetector(
        onTap: () => setState(() => _statusBaca = status),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryBrown.withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? primaryBrown : const Color(0xFF8B5E3C).withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? primaryBrown : const Color(0xFF8B5E3C),
                    width: 2,
                  ),
                  color: isSelected ? primaryBrown : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(Icons.circle, color: Colors.white, size: 10)
                    : null,
              ),
              const SizedBox(width: 12),
              Icon(icon, color: isSelected ? primaryBrown : color, size: 20),
              const SizedBox(width: 10),
              Text(
                status.label,
                style: GoogleFonts.lato(
                  color: primaryBrown,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
