//Willyan Hyuga Pratama 2211102129
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/skill_model.dart';
import '../services/firestore_service.dart';
import '../widgets/notification_overlay.dart';

class AddSkillScreen extends StatefulWidget {
  const AddSkillScreen({super.key});

  @override
  State<AddSkillScreen> createState() => _AddSkillScreenState();
}

class _AddSkillScreenState extends State<AddSkillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _sertifikatUrlController = TextEditingController();
  final _firestoreService = FirestoreService();

  String _selectedLevel = 'Beginner';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  final List<String> _levels = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Expert',
  ];

  @override
  void dispose() {
    _namaController.dispose();
    _sertifikatUrlController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.cyan.shade600,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveSkill() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final skill = SkillModel(
        namaSkill: _namaController.text.trim(),
        level: _selectedLevel,
        sertifikatUrl: _sertifikatUrlController.text.trim(),
        tanggalDiperoleh: _selectedDate,
        userId: user.uid,
      );

      await _firestoreService.addSkill(skill);

      if (mounted) {
        showTopNotification(context, 'Skill berhasil ditambahkan');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showTopNotification(context, 'Gagal menambahkan skill: $e',
            isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Skill Baru'),
        backgroundColor: Colors.cyan.shade600,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header illustration
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.cyan.shade100, Colors.cyan.shade50],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(Icons.add_task, size: 48, color: Colors.cyan.shade700),
                    const SizedBox(height: 8),
                    Text(
                      'Catat skill baru Anda',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.cyan.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Nama Skill
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Skill',
                  prefixIcon: Icon(Icons.code),
                  hintText: 'Contoh: Flutter, Python, UI/UX',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama skill tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Level Dropdown
              DropdownButtonFormField<String>(
                value: _selectedLevel,
                decoration: const InputDecoration(
                  labelText: 'Level',
                  prefixIcon: Icon(Icons.trending_up),
                ),
                items: _levels.map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child: Row(
                      children: [
                        _buildLevelDot(level),
                        const SizedBox(width: 8),
                        Text(level),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedLevel = value!);
                },
              ),
              const SizedBox(height: 16),

              // Sertifikat URL
              TextFormField(
                controller: _sertifikatUrlController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Link Sertifikat (opsional)',
                  prefixIcon: Icon(Icons.link),
                  hintText: 'https://...',
                ),
              ),
              const SizedBox(height: 16),

              // Tanggal
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Diperoleh',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    DateFormat('dd MMMM yyyy', 'id').format(_selectedDate),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveSkill,
                icon: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(_isLoading ? 'Menyimpan...' : 'Simpan Skill'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelDot(String level) {
    Color color;
    switch (level) {
      case 'Beginner':
        color = Colors.green;
        break;
      case 'Intermediate':
        color = Colors.orange;
        break;
      case 'Advanced':
        color = Colors.blue;
        break;
      case 'Expert':
        color = Colors.purple;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
