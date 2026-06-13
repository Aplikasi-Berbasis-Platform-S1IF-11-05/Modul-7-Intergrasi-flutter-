// Reza Alvonzo - 2311102026 
import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import '../services/notification_service.dart';

class EditRecipeScreen extends StatefulWidget {
  final Recipe recipe;

  const EditRecipeScreen({super.key, required this.recipe});

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaController;
  late final TextEditingController _bahanController;
  late final TextEditingController _langkahController;
  late final TextEditingController _waktuController;
  final _recipeService = RecipeService();
  late String _selectedKategori;
  bool _isLoading = false;

  final List<String> _kategoriList = [
    'Makanan',
    'Minuman',
    'Dessert',
    'Snack',
    'Sarapan',
  ];

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.recipe.namaMasakan);
    _bahanController = TextEditingController(text: widget.recipe.bahan);
    _langkahController = TextEditingController(text: widget.recipe.langkah);
    _waktuController = TextEditingController(text: widget.recipe.waktuMemasak);
    _selectedKategori = widget.recipe.kategori;
    if (!_kategoriList.contains(_selectedKategori)) {
      _selectedKategori = 'Makanan';
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _bahanController.dispose();
    _langkahController.dispose();
    _waktuController.dispose();
    super.dispose();
  }

  Future<void> _updateRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedRecipe = Recipe(
        id: widget.recipe.id,
        namaMasakan: _namaController.text.trim(),
        bahan: _bahanController.text.trim(),
        langkah: _langkahController.text.trim(),
        kategori: _selectedKategori,
        waktuMemasak: _waktuController.text.trim(),
        userId: widget.recipe.userId,
        createdAt: widget.recipe.createdAt,
      );

      await _recipeService.updateRecipe(widget.recipe.id!, updatedRecipe);
      await NotificationService.showNotification(
        title: 'RecipeHub',
        body: 'Resep berhasil diperbarui',
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui resep: ${e.toString()}'),
            backgroundColor: Colors.red,
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
      appBar: AppBar(
        title: const Text('Edit Resep'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nama Masakan
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Masakan',
                  prefixIcon: Icon(Icons.restaurant_menu),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama masakan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Kategori
              DropdownButtonFormField<String>(
                value: _selectedKategori,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  prefixIcon: Icon(Icons.category),
                ),
                items: _kategoriList.map((kategori) {
                  return DropdownMenuItem(
                    value: kategori,
                    child: Text(kategori),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedKategori = value!);
                },
              ),
              const SizedBox(height: 16),

              // Waktu Memasak
              TextFormField(
                controller: _waktuController,
                decoration: const InputDecoration(
                  labelText: 'Waktu Memasak (contoh: 30 menit)',
                  prefixIcon: Icon(Icons.access_time),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Waktu memasak tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Bahan
              TextFormField(
                controller: _bahanController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Bahan-bahan',
                  hintText: 'Masukkan bahan satu per baris',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 80),
                    child: Icon(Icons.shopping_basket),
                  ),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bahan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Langkah
              TextFormField(
                controller: _langkahController,
                maxLines: 7,
                decoration: const InputDecoration(
                  labelText: 'Langkah-langkah',
                  hintText: 'Masukkan langkah satu per baris',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 120),
                    child: Icon(Icons.format_list_numbered),
                  ),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Langkah tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Update button
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _updateRecipe,
                  icon: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.update),
                  label: Text(
                    _isLoading ? 'Memperbarui...' : 'Perbarui Resep',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
