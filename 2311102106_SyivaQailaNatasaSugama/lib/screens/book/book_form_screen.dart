//Syiva Qaila Natasa Sugama 2311102106 IF-11-05
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book_model.dart';
import '../../providers/book_provider.dart';

class BookFormScreen extends StatefulWidget {
  final String userId;
  final BookModel? book; // null = tambah baru, tidak null = edit

  const BookFormScreen({
    super.key,
    required this.userId,
    this.book,
  });

  @override
  State<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _yearController = TextEditingController();

  String _selectedGenre = 'Fiksi';
  double _rating = 3.0;
  bool _isLoading = false;

  final List<String> _genres = [
    'Fiksi',
    'Non-Fiksi',
    'Sains & Teknologi',
    'Sejarah',
    'Biografi',
    'Pengembangan Diri',
    'Misteri & Thriller',
    'Romansa',
    'Fantasi',
    'Sains Fiksi',
    'Anak-Anak',
    'Pendidikan',
    'Agama & Spiritualitas',
    'Seni & Budaya',
    'Lainnya',
  ];

  bool get _isEditing => widget.book != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.book!.title;
      _authorController.text = widget.book!.author;
      _descriptionController.text = widget.book!.description;
      _yearController.text = widget.book!.year.toString();
      _selectedGenre = _genres.contains(widget.book!.genre)
          ? widget.book!.genre
          : 'Lainnya';
      _rating = widget.book!.rating;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final book = BookModel(
      id: widget.book?.id,
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      genre: _selectedGenre,
      description: _descriptionController.text.trim(),
      rating: _rating,
      year: int.tryParse(_yearController.text) ?? 0,
      userId: widget.userId,
      createdAt: widget.book?.createdAt ?? DateTime.now(),
    );

    final bookProvider = context.read<BookProvider>();
    bool success;

    if (_isEditing) {
      success = await bookProvider.updateBook(book);
    } else {
      success = await bookProvider.addBook(book);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Buku berhasil diperbarui!'
                : 'Buku berhasil ditambahkan!',
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            bookProvider.errorMessage ??
                (_isEditing
                    ? 'Gagal memperbarui buku.'
                    : 'Gagal menambahkan buku.'),
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Buku' : 'Tambah Buku'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              _buildSectionLabel('Judul Buku *'),
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'Masukkan judul buku',
                  prefixIcon: Icon(Icons.book_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Judul buku tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Author
              _buildSectionLabel('Pengarang *'),
              TextFormField(
                controller: _authorController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'Masukkan nama pengarang',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Nama pengarang tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Genre
              _buildSectionLabel('Genre *'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedGenre,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: _genres
                        .map((genre) => DropdownMenuItem(
                              value: genre,
                              child: Text(genre),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedGenre = value);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Year
              _buildSectionLabel('Tahun Terbit'),
              TextFormField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Contoh: 2023',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                validator: (v) {
                  if (v != null && v.isNotEmpty) {
                    final year = int.tryParse(v);
                    if (year == null) return 'Tahun harus berupa angka';
                    if (year < 1000 || year > DateTime.now().year + 5) {
                      return 'Tahun tidak valid';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Rating
              _buildSectionLabel('Rating: ${_rating.toStringAsFixed(1)} ⭐'),
              Slider(
                value: _rating,
                min: 0,
                max: 5,
                divisions: 10,
                activeColor: const Color(0xFF6C63FF),
                label: _rating.toStringAsFixed(1),
                onChanged: (value) {
                  setState(() => _rating = value);
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('0',
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 12)),
                  Text('5',
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 16),

              // Description
              _buildSectionLabel('Deskripsi'),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Tulis deskripsi atau catatan tentang buku ini...',
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 60),
                    child: Icon(Icons.notes_outlined),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Submit button
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _isEditing ? 'Simpan Perubahan' : 'Tambahkan Buku',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Color(0xFF2D3748),
        ),
      ),
    );
  }
}
