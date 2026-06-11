import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CollectionReference tasks = FirebaseFirestore.instance.collection(
    'tasks',
  );
  final TextEditingController taskController = TextEditingController();

  String selectedDeadline = "-";
  String userName = "";

  @override
  void initState() {
    super.initState();
    _getUserName();
  }

  Future<void> _getUserName() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();
    if (doc.exists && mounted) {
      setState(() => userName = doc["name"]);
    }
  }

  Future<void> _addTask() async {
    if (taskController.text.trim().isEmpty) return;

    final title = taskController.text.trim();

    await tasks.add({
      'title': title,
      'deadline': selectedDeadline,
      'isDone': false,
      'createdAt': Timestamp.now(),
    });

    await showNotif('Tugas Ditambahkan', '"$title" berhasil ditambahkan.');

    taskController.clear();
    selectedDeadline = "-";
  }

  Future<void> _deleteTask(String id, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFE53935),
              size: 26,
            ),
            SizedBox(width: 8),
            Text(
              "Hapus Tugas?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          'Tugas "$title" akan dihapus secara permanen.',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await tasks.doc(id).delete();
      await showNotif('🗑️ Tugas Dihapus', '"$title" telah dihapus.');
    }
  }

  Future<void> _editTask(String id, String oldTitle, String oldDeadline) async {
    final editController = TextEditingController(text: oldTitle);
    String deadline = oldDeadline;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Edit Tugas",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogTextField(
                editController,
                "Nama Tugas",
                Icons.edit_outlined,
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: Color(0xFF6A3DE8),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        deadline,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF6A3DE8),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: ctx,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            deadline =
                                "${picked.day}/${picked.month}/${picked.year}";
                          });
                        }
                      },
                      child: const Text(
                        "Ubah",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                final newTitle = editController.text.trim();
                await tasks.doc(id).update({
                  'title': newTitle,
                  'deadline': deadline,
                });
                await showNotif(
                  'Tugas Diperbarui',
                  '"$newTitle" berhasil diperbarui.',
                );
                if (mounted) Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A3DE8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Simpan",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog() {
    taskController.clear();
    selectedDeadline = "-";

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Tambah Tugas",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogTextField(
                taskController,
                "Nama Tugas",
                Icons.assignment_outlined,
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: Color(0xFF6A3DE8),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        selectedDeadline,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF6A3DE8),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: ctx,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            selectedDeadline =
                                "${picked.day}/${picked.month}/${picked.year}";
                          });
                        }
                      },
                      child: const Text(
                        "Pilih",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _addTask();
                if (mounted) Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A3DE8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Tambah",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Keluar?",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text("Kamu akan keluar dari akun Study Planner kamu."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A3DE8),
              foregroundColor: Colors.white,
            ),
            child: const Text("Keluar"),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) Navigator.pop(context);
    }
  }

  Widget _dialogTextField(
    TextEditingController ctrl,
    String hint,
    IconData icon,
  ) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
        filled: true,
        fillColor: const Color(0xFFF5F3FF),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6A3DE8), width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6A3DE8), Color(0xFF9B6DFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.auto_stories_rounded,
                              color: Colors.white70,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Study Planner",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Halo, $userName",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Semangat menyelesaikan tugasmu!",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _logout,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: tasks
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF6A3DE8),
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs;
                  final total = docs.length;
                  final done = docs.where((e) => e['isDone'] == true).length;
                  final percent = total > 0 ? done / total : 0.0;

                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF6A3DE8,
                                      ).withOpacity(0.08),
                                      blurRadius: 20,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _statChip(
                                            "Total",
                                            total.toString(),
                                            Icons.list_alt_rounded,
                                            const Color(0xFF6A3DE8),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _statChip(
                                            "Selesai",
                                            done.toString(),
                                            Icons.check_circle_rounded,
                                            const Color(0xFF43A047),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _statChip(
                                            "Sisa",
                                            (total - done).toString(),
                                            Icons.pending_rounded,
                                            const Color(0xFFFF8F00),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Progress",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade500,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          "${(percent * 100).toStringAsFixed(0)}%",
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF6A3DE8),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: LinearProgressIndicator(
                                        value: percent,
                                        minHeight: 8,
                                        backgroundColor: const Color(
                                          0xFFF0EBFF,
                                        ),
                                        valueColor:
                                            const AlwaysStoppedAnimation(
                                              Color(0xFF6A3DE8),
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  const Text(
                                    "Daftar Tugas",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1A1A2E),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    "${docs.length} tugas",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                      docs.isEmpty
                          ? SliverFillRemaining(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.inbox_rounded,
                                      size: 64,
                                      color: Colors.grey.shade300,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "Belum ada tugas",
                                      style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Tap tombol + untuk menambahkan",
                                      style: TextStyle(
                                        color: Colors.grey.shade300,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : SliverPadding(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                0,
                                20,
                                100,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate((
                                  context,
                                  index,
                                ) {
                                  final task = docs[index];
                                  final isDone = task['isDone'] == true;
                                  return _TaskCard(
                                    task: task,
                                    isDone: isDone,
                                    onToggle: (val) async {
                                      await tasks.doc(task.id).update({
                                        'isDone': val,
                                      });
                                      if (val == true) {
                                        await showNotif(
                                          'Tugas Selesai!',
                                          '"${task['title']}" berhasil diselesaikan.',
                                        );
                                      }
                                    },
                                    onEdit: () => _editTask(
                                      task.id,
                                      task['title'],
                                      task['deadline'],
                                    ),
                                    onDelete: () =>
                                        _deleteTask(task.id, task['title']),
                                  );
                                }, childCount: docs.length),
                              ),
                            ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFF6A3DE8),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          "Tambah Tugas",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _statChip(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final QueryDocumentSnapshot task;
  final bool isDone;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TaskCard({
    required this.task,
    required this.isDone,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDone ? const Color(0xFFF9F9F9) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDone
              ? Colors.grey.shade200
              : const Color(0xFF6A3DE8).withOpacity(0.12),
          width: 1.2,
        ),
        boxShadow: isDone
            ? []
            : [
                BoxShadow(
                  color: const Color(0xFF6A3DE8).withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Transform.scale(
          scale: 1.1,
          child: Checkbox(
            value: isDone,
            onChanged: onToggle,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            activeColor: const Color(0xFF43A047),
            side: const BorderSide(color: Color(0xFF9B6DFF), width: 1.5),
          ),
        ),
        title: Text(
          task['title'],
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: isDone ? Colors.grey.shade400 : const Color(0xFF1A1A2E),
            decoration: isDone
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            decorationColor: Colors.grey.shade400,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 12,
                color: Colors.grey.shade400,
              ),
              const SizedBox(width: 4),
              Text(
                task['deadline'],
                style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _iconBtn(Icons.edit_outlined, const Color(0xFF6A3DE8), onEdit),
            const SizedBox(width: 4),
            _iconBtn(
              Icons.delete_outline_rounded,
              const Color(0xFFE53935),
              onDelete,
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
