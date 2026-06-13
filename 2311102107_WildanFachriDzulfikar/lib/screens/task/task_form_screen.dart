//Wildan Fachri Dzulfikar
//2311102107
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/task_model.dart';
import '../../services/auth_service.dart';
import '../../services/task_service.dart';
import '../../widgets/app_notification.dart';

class TaskFormScreen extends StatefulWidget {
  final TaskModel? task;

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _authService = AuthService();
  final _taskService = TaskService();

  DateTime _selectedDeadline = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = TimeOfDay.now();
  TaskStatus _selectedStatus = TaskStatus.belumSelesai;
  bool _isLoading = false;

  bool get _isEditMode => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final task = widget.task!;
      _judulController.text = task.judul;
      _deskripsiController.text = task.deskripsi;
      _selectedDeadline = task.deadline;
      _selectedTime = TimeOfDay.fromDateTime(task.deadline);
      _selectedStatus = task.status;
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1565C0),
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDeadline = DateTime(
            picked.year,
            picked.month,
            picked.day,
            _selectedTime.hour,
            _selectedTime.minute,
          ));
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1565C0),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _selectedDeadline = DateTime(
          _selectedDeadline.year,
          _selectedDeadline.month,
          _selectedDeadline.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      if (_isEditMode) {
        final updatedTask = widget.task!.copyWith(
          judul: _judulController.text.trim(),
          deskripsi: _deskripsiController.text.trim(),
          deadline: _selectedDeadline,
          status: _selectedStatus,
        );
        await _taskService.updateTask(updatedTask);
        if (mounted) {
          AppNotification.success(
            context,
            'Tugas berhasil diperbarui',
            title: 'Tugas Diperbarui ✏️',
          );
          Navigator.pop(context);
        }
      } else {
        final newTask = TaskModel(
          id: '',
          judul: _judulController.text.trim(),
          deskripsi: _deskripsiController.text.trim(),
          deadline: _selectedDeadline,
          status: _selectedStatus,
          createdAt: DateTime.now(),
          userId: _authService.currentUser!.uid,
        );
        await _taskService.addTask(newTask);
        if (mounted) {
          AppNotification.success(
            context,
            'Tugas berhasil ditambahkan',
            title: 'Tugas Ditambahkan ✅',
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        AppNotification.error(
          context,
          _isEditMode
              ? 'Gagal memperbarui tugas. Coba lagi.'
              : 'Gagal menambahkan tugas. Coba lagi.',
          title: 'Terjadi Kesalahan',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Tugas' : 'Tambah Tugas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card Form
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel('Informasi Tugas'),
                      const SizedBox(height: 12),
                      // Judul
                      TextFormField(
                        controller: _judulController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Judul Tugas',
                          hintText: 'Contoh: Tugas Pemrograman Mobile',
                          prefixIcon: Icon(Icons.title,
                              color: Color(0xFF1565C0)),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Judul tidak boleh kosong';
                          }
                          if (v.trim().length < 3) {
                            return 'Judul minimal 3 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Deskripsi
                      TextFormField(
                        controller: _deskripsiController,
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi (opsional)',
                          hintText: 'Tambahkan deskripsi tugas...',
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(bottom: 48),
                            child: Icon(Icons.description_outlined,
                                color: Color(0xFF1565C0)),
                          ),
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Card Deadline
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel('Deadline'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Tanggal
                          Expanded(
                            child: _buildPickerButton(
                              icon: Icons.calendar_today_outlined,
                              label: 'Tanggal',
                              value: DateFormat('dd MMM yyyy', 'id_ID')
                                  .format(_selectedDeadline),
                              onTap: _pickDate,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Waktu
                          Expanded(
                            child: _buildPickerButton(
                              icon: Icons.access_time_outlined,
                              label: 'Waktu',
                              value: _selectedTime.format(context),
                              onTap: _pickTime,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline,
                                size: 16, color: Color(0xFF1565C0)),
                            const SizedBox(width: 8),
                            Text(
                              'Deadline: ${DateFormat('EEEE, dd MMMM yyyy · HH:mm', 'id_ID').format(_selectedDeadline)} WIB',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1565C0),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Card Status (hanya muncul saat edit)
                if (_isEditMode) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionLabel('Status Tugas'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildStatusOption(
                              label: 'Belum Selesai',
                              status: TaskStatus.belumSelesai,
                              color: const Color(0xFF1565C0),
                              icon: Icons.pending_actions_outlined,
                            ),
                            const SizedBox(width: 12),
                            _buildStatusOption(
                              label: 'Selesai',
                              status: TaskStatus.selesai,
                              color: const Color(0xFF2E7D32),
                              icon: Icons.check_circle_outline,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Tombol Submit
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _submit,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Icon(_isEditMode ? Icons.save_outlined : Icons.add),
                    label: Text(
                      _isLoading
                          ? 'Menyimpan...'
                          : _isEditMode
                              ? 'Simpan Perubahan'
                              : 'Tambah Tugas',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1565C0),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildPickerButton({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFBBDEFB)),
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFFF8FBFF),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF1565C0)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF1A237E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_drop_down,
                color: Color(0xFF1565C0), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption({
    required String label,
    required TaskStatus status,
    required Color color,
    required IconData icon,
  }) {
    final isSelected = _selectedStatus == status;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedStatus = status),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? color : Colors.grey, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : Colors.grey,
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
