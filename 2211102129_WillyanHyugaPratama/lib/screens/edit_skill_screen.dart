//Willyan Hyuga Pratama 2211102129
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/skill_model.dart';
import '../services/firestore_service.dart';
import '../widgets/notification_overlay.dart';

class EditSkillScreen extends StatefulWidget {
  final SkillModel skill;

  const EditSkillScreen({super.key, required this.skill});

  @override
  State<EditSkillScreen> createState() => _EditSkillScreenState();
}

class _EditSkillScreenState extends State<EditSkillScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _sertifikatUrlController;
  final _firestoreService = FirestoreService();

  late String _selectedLevel;
  late DateTime _selectedDate;
  bool _isLoading = false;

  final List<String> _levels = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Expert',
  ];

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.skill.namaSkill);
    _sertifikatUrlController =
        TextEditingController(text: widget.skill.sertifikatUrl);
    _selectedLevel = widget.skill.level;
    _selectedDate = widget.skill.tanggalDiperoleh;
  }

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

  Future<void> _updateSkill() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedSkill = SkillModel(
        id: widget.skill.id,
        namaSkill: _namaController.text.trim(),
        level: _selectedLevel,
        sertifikatUrl: _sertifikatUrlController.text.trim(),
        tanggalDiperoleh: _selectedDate,
        userId: widget.skill.userId,
      );

      await _firestoreService.updateSkill(widget.skill.id!, updatedSkill);

      if (mounted) {
        showTopNotification(context, 'Skill berhasil diperbarui');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showTopNotification(context, 'Gagal memperbarui skill: $e',
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
        title: const Text('Edit Skill'),
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
              // Header
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
                    Icon(Icons.edit_note, size: 48, color: Colors.cyan.shade700),
                    const SizedBox(height: 8),
                    Text(
                      'Perbarui data skill Anda',
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

              // Update Button
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _updateSkill,
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
                label:
                    Text(_isLoading ? 'Menyimpan...' : 'Perbarui Skill'),
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
