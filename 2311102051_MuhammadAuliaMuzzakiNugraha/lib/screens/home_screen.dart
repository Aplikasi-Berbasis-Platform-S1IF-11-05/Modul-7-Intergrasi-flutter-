/// NIM: 2311102051
/// Nama: Muhammad Aulia Muzzaki Nugraha
/// Kelas: Praktikum Aplikasi Berbasis Platform

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../widgets/task_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();
  final NotificationService _notifService = NotificationService();

  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _useStream = true; // Use stream by default, fallback to future if stream errors
  List<Task> _fallbackTasks = [];
  bool _isFallbackLoading = false;

  final List<String> _categories = ['All', 'Work', 'Personal', 'Shopping', 'Health', 'General'];

  @override
  void initState() {
    super.initState();
    _loadFallbackTasks();
  }

  // Fallback loader if real-time replication is not enabled in Supabase console
  Future<void> _loadFallbackTasks() async {
    final user = _authService.currentUser;
    if (user == null) return;
    
    setState(() => _isFallbackLoading = true);
    try {
      final tasks = await _dbService.getTasks(user.id);
      setState(() {
        _fallbackTasks = tasks;
        _useStream = false; // Switch to future polling if successful
      });
    } catch (e) {
      // If both fail, keep streaming or show error
      debugPrint("Failed to fetch fallback tasks: $e");
    } finally {
      setState(() => _isFallbackLoading = false);
    }
  }

  void _triggerCrudNotification({
    required int id,
    required String action,
    required String taskTitle,
  }) {
    String title = "";
    String body = "";

    switch (action) {
      case 'create':
        title = "Tugas Dibuat!";
        body = "Tugas '$taskTitle' berhasil ditambahkan online.";
        break;
      case 'update':
        title = "Tugas Diperbarui!";
        body = "Tugas '$taskTitle' telah berhasil diperbarui.";
        break;
      case 'complete':
        title = "Tugas Selesai! ";
        body = "Hebat! Anda telah menyelesaikan tugas '$taskTitle'.";
        break;
      case 'incomplete':
        title = "Tugas Diaktifkan Kembali ";
        body = "Tugas '$taskTitle' diubah menjadi belum selesai.";
        break;
      case 'delete':
        title = "Tugas Dihapus 🗑";
        body = "Tugas '$taskTitle' telah berhasil dihapus dari cloud.";
        break;
    }

    _notifService.showNotification(
      id: id,
      title: title,
      body: body,
    );
  }

  void _showTaskModal([Task? task]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskModal(
        task: task,
        onSave: (savedTask) async {
          try {
            if (task == null) {
              // Create
              await _dbService.createTask(savedTask);
              _triggerCrudNotification(
                id: 1,
                action: 'create',
                taskTitle: savedTask.title,
              );
            } else {
              // Update
              await _dbService.updateTask(savedTask);
              _triggerCrudNotification(
                id: 2,
                action: 'update',
                taskTitle: savedTask.title,
              );
            }
            if (!_useStream) _loadFallbackTasks();
          } catch (e) {
            _showErrorSnackbar("Gagal menyimpan tugas: $e");
          }
        },
      ),
    );
  }

  Future<void> _toggleTaskCompletion(Task task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    try {
      await _dbService.updateTask(updatedTask);
      _triggerCrudNotification(
        id: updatedTask.isCompleted ? 3 : 4,
        action: updatedTask.isCompleted ? 'complete' : 'incomplete',
        taskTitle: task.title,
      );
      if (!_useStream) _loadFallbackTasks();
    } catch (e) {
      _showErrorSnackbar("Gagal memperbarui status tugas: $e");
    }
  }

  Future<void> _deleteTask(Task task) async {
    if (task.id == null) return;
    try {
      await _dbService.deleteTask(task.id!);
      _triggerCrudNotification(
        id: 5,
        action: 'delete',
        taskTitle: task.title,
      );
      if (!_useStream) _loadFallbackTasks();
    } catch (e) {
      _showErrorSnackbar("Gagal menghapus tugas: $e");
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<Task> _filterTasks(List<Task> tasks) {
    return tasks.where((task) {
      final matchesCategory = _selectedCategory == 'All' || task.category == _selectedCategory;
      final matchesSearch = task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          task.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final userEmail = user?.email ?? 'User';
    final userDisplayName = user?.userMetadata?['full_name'] ?? userEmail.split('@')[0];

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17), // Deep Slate
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1D2B),
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.indigoAccent.withOpacity(0.2),
              child: Text(
                userDisplayName[0].toUpperCase(),
                style: GoogleFonts.outfit(
                  color: Colors.indigoAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo,',
                  style: GoogleFonts.outfit(fontSize: 12, color: Colors.white54),
                ),
                Text(
                  userDisplayName,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: () {
              _loadFallbackTasks();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Data diperbarui dari cloud.', style: GoogleFonts.outfit()),
                  backgroundColor: Colors.indigo,
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: () async {
              await _authService.signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Category Headers
          Container(
            color: const Color(0xFF1F1D2B),
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 8),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: GoogleFonts.outfit(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Cari tugas Anda...',
                    hintStyle: GoogleFonts.outfit(color: Colors.white30, fontSize: 14),
                    prefixIcon: const Icon(Icons.search_rounded, color: Colors.white54, size: 20),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.04),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.indigoAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Category Chips
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedCategory = category);
                            }
                          },
                          labelStyle: GoogleFonts.outfit(
                            color: isSelected ? Colors.white : Colors.white60,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13,
                          ),
                          selectedColor: Colors.indigoAccent,
                          backgroundColor: Colors.white.withOpacity(0.04),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.05),
                            ),
                          ),
                          showCheckmark: false,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Main Tasks List
          Expanded(
            child: _useStream
                ? StreamBuilder<List<Task>>(
                    stream: _dbService.getTasksStream(user!.id),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        // Fallback to Future-based fetching if stream fails (e.g. real-time replication config issue)
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          setState(() => _useStream = false);
                        });
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.indigoAccent));
                      }
                      return _buildTaskList(snapshot.data ?? []);
                    },
                  )
                : _isFallbackLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.indigoAccent))
                    : RefreshIndicator(
                        onRefresh: _loadFallbackTasks,
                        color: Colors.indigoAccent,
                        backgroundColor: const Color(0xFF1F1D2B),
                        child: _buildTaskList(_fallbackTasks),
                      ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: FloatingActionButton(
          onPressed: () => _showTaskModal(),
          backgroundColor: Colors.indigoAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.add_rounded, size: 28),
        ),
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    final filtered = _filterTasks(tasks);

    if (filtered.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assignment_turned_in_outlined,
                size: 64,
                color: Colors.white24,
              ),
              const SizedBox(height: 16),
              Text(
                'Tidak ada tugas ditemukan',
                style: GoogleFonts.outfit(color: Colors.white54, fontSize: 16),
              ),
              Text(
                'Mulai produktif dengan menambahkan tugas baru!',
                style: GoogleFonts.outfit(color: Colors.white30, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    // Task stats calculation
    final total = filtered.length;
    final completed = filtered.where((t) => t.isCompleted).length;
    final progress = total > 0 ? completed / total : 0.0;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Stats Card Widget
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.indigo, Color(0xFF6C63FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.indigoAccent.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kemajuan Tugas Anda',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completed dari $total tugas telah diselesaikan',
                      style: GoogleFonts.outfit(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 54,
                    height: 54,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 5,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Text(
          'Daftar Tugas',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),

        ...filtered.map((task) {
          final isOverdue = !task.isCompleted && task.dueDate.isBefore(DateTime.now());
          final dateStr = DateFormat('dd MMM yyyy').format(task.dueDate);

          Color priorityColor = Colors.green;
          if (task.priority == 'High') {
            priorityColor = Colors.redAccent;
          } else if (task.priority == 'Medium') {
            priorityColor = Colors.orangeAccent;
          }

          return Dismissible(
            key: Key(task.id ?? UniqueKey().toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20.0),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 28),
            ),
            onDismissed: (_) => _deleteTask(task),
            child: Card(
              color: const Color(0xFF1F1D2B),
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
              elevation: 0,
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  leading: Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      value: task.isCompleted,
                      onChanged: (_) => _toggleTaskCompletion(task),
                      activeColor: Colors.indigoAccent,
                      checkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                  ),
                  title: Text(
                    task.title,
                    style: GoogleFonts.outfit(
                      color: task.isCompleted ? Colors.white30 : Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: priorityColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          task.priority,
                          style: GoogleFonts.outfit(
                            color: priorityColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateStr,
                        style: GoogleFonts.outfit(
                          color: isOverdue ? Colors.redAccent : Colors.white38,
                          fontSize: 11,
                          fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_note_rounded, color: Colors.indigoAccent, size: 24),
                    onPressed: () => _showTaskModal(task),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Deskripsi:',
                              style: GoogleFonts.outfit(
                                color: Colors.white38,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              task.description.isEmpty ? 'Tidak ada deskripsi.' : task.description,
                              style: GoogleFonts.outfit(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Text(
                                  'Kategori: ',
                                  style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.04),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    task.category,
                                    style: GoogleFonts.outfit(color: Colors.indigoAccent, fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
