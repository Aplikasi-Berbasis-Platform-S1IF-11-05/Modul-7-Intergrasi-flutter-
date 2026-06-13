//Wildan Fachri Dzulfikar
//2311102107
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/task_model.dart';
import '../../services/auth_service.dart';
import '../../services/task_service.dart';
import '../../widgets/app_notification.dart';
import '../../widgets/task_card.dart';
import '../task/task_form_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  final _taskService = TaskService();
  late TabController _tabController;

  // Filter: 0 = Semua, 1 = Belum Selesai, 2 = Selesai
  int _filterIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() => _filterIndex = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  User get _user => _authService.currentUser!;

  List<TaskModel> _filterTasks(List<TaskModel> tasks) {
    switch (_filterIndex) {
      case 1:
        return tasks.where((t) => !t.isSelesai).toList();
      case 2:
        return tasks.where((t) => t.isSelesai).toList();
      default:
        return tasks;
    }
  }

  Future<void> _confirmDelete(BuildContext context, TaskModel task) async {
    final overlay = Overlay.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Tugas?',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A237E),
          ),
        ),
        content: Text(
          'Tugas "${task.judul}" akan dihapus permanen.',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _taskService.deleteTask(task.id);
        AppNotification.showOnOverlay(
          overlay,
          title: 'Tugas Dihapus 🗑️',
          message: '"${task.judul}" telah dihapus',
          type: NotificationType.success,
        );
      } catch (e) {
        AppNotification.showOnOverlay(
          overlay,
          title: 'Terjadi Kesalahan',
          message: 'Gagal menghapus tugas. Coba lagi.',
          type: NotificationType.error,
        );
      }
    }
  }

  Future<void> _toggleStatus(TaskModel task) async {
    try {
      await _taskService.toggleStatus(task);
      if (mounted) {
        if (task.isSelesai) {
          AppNotification.info(
            context,
            '"${task.judul}" ditandai belum selesai',
            title: 'Status Diperbarui',
          );
        } else {
          AppNotification.success(
            context,
            '"${task.judul}" berhasil diselesaikan!',
            title: 'Tugas Selesai 🎉',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppNotification.error(
          context,
          'Gagal memperbarui status tugas.',
          title: 'Terjadi Kesalahan',
        );
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Keluar?',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A237E),
          ),
        ),
        content: const Text(
          'Anda akan keluar dari TaskMaster.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: StreamBuilder<List<TaskModel>>(
        stream: _taskService.getTasksStream(_user.uid),
        builder: (context, snapshot) {
          final allTasks = snapshot.data ?? [];
          final selesaiCount = allTasks.where((t) => t.isSelesai).length;
          final belumSelesaiCount = allTasks.where((t) => !t.isSelesai).length;
          final filteredTasks = _filterTasks(allTasks);

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF1565C0),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: _logout,
                    tooltip: 'Keluar',
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildDashboardHeader(
                      selesaiCount, belumSelesaiCount, allTasks.length),
                ),
                bottom: TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  tabs: [
                    Tab(text: 'Semua (${allTasks.length})'),
                    Tab(text: 'Aktif ($belumSelesaiCount)'),
                    Tab(text: 'Selesai ($selesaiCount)'),
                  ],
                ),
              ),
            ],
            body: snapshot.connectionState == ConnectionState.waiting
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF1565C0)),
                  )
                : filteredTasks.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = filteredTasks[index];
                          return TaskCard(
                            task: task,
                            onEdit: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    TaskFormScreen(task: task),
                              ),
                            ),
                            onDelete: () => _confirmDelete(context, task),
                            onToggleStatus: () => _toggleStatus(task),
                          );
                        },
                      ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TaskFormScreen()),
        ),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Tambah Tugas',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildDashboardHeader(
      int selesai, int belumSelesai, int total) {
    final userName = _user.displayName ?? _user.email ?? 'Mahasiswa';
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white24,
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Halo,',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 13),
                    ),
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Statistik
          Row(
            children: [
              _buildStatCard(
                icon: Icons.list_alt_outlined,
                label: 'Total Tugas',
                value: total,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              _buildStatCard(
                icon: Icons.pending_actions_outlined,
                label: 'Belum Selesai',
                value: belumSelesai,
                color: const Color(0xFFFFCC02),
              ),
              const SizedBox(width: 10),
              _buildStatCard(
                icon: Icons.check_circle_outline,
                label: 'Selesai',
                value: selesai,
                color: const Color(0xFF69F0AE),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required int value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              '$value',
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final messages = [
      ('Tidak ada tugas', 'Tap tombol + untuk menambah\ntugas pertamamu!'),
      ('Tidak ada tugas aktif', 'Semua tugas sudah selesai!\nKerja bagus 🎉'),
      ('Belum ada tugas selesai', 'Yuk selesaikan tugasmu!'),
    ];
    final (title, subtitle) = messages[_filterIndex];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _filterIndex == 2
                  ? Icons.hourglass_empty_outlined
                  : Icons.assignment_outlined,
              size: 52,
              color: const Color(0xFF90CAF9),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
