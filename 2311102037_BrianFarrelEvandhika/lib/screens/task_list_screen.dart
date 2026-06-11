import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import '../theme/app_theme.dart';
import '../widgets/task_form_dialog.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showEditTaskDialog(Task task) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (_) => TaskFormDialog(userId: auth.userId!, task: task),
    );
  }

  Future<void> _toggleTaskCompletion(TaskProvider provider, Task task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    final success = await provider.updateTask(updatedTask);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Gagal memperbarui status tugas'),
          backgroundColor: AppTheme.priorityHigh,
        ),
      );
    }
  }

  Future<void> _deleteTask(TaskProvider provider, String taskId) async {
    final success = await provider.deleteTask(taskId);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Gagal menghapus tugas'),
          backgroundColor: AppTheme.priorityHigh,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final tasksData = Provider.of<TaskProvider>(context);
    final filteredList = tasksData.filteredTasks;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Daftar Tugas', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => tasksData.setSearchQuery(val),
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Cari tugas...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: AppTheme.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          tasksData.setSearchQuery('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // Filters Block (Horizontal lists)
          _buildFilters(tasksData),

          // Task List view
          Expanded(
            child: tasksData.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.accentCyan))
                : filteredList.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () => tasksData.fetchTasks(auth.userId!),
                        color: AppTheme.accentCyan,
                        backgroundColor: AppTheme.cardColor,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          itemCount: filteredList.length,
                          itemBuilder: (ctx, index) {
                            final task = filteredList[index];
                            return _buildTaskCard(tasksData, task);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(TaskProvider provider) {
    final categories = ['All', 'Work', 'Personal', 'Shopping', 'Health'];
    final priorities = ['All', 'High', 'Medium', 'Low'];
    final statuses = ['All', 'Pending', 'Completed'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Category filters row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: categories.map((cat) {
              final isSelected = provider.selectedCategory.toLowerCase() == cat.toLowerCase();
              final catColor = cat == 'All' ? AppTheme.accentCyan : AppTheme.getCategoryColor(cat);
              final displayName = cat == 'All'
                  ? 'Semua Kategori'
                  : cat == 'Work'
                      ? 'Pekerjaan'
                      : cat == 'Personal'
                          ? 'Pribadi'
                          : cat == 'Shopping'
                              ? 'Belanja'
                              : 'Kesehatan';

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: FilterChip(
                  label: Text(
                    displayName,
                    style: TextStyle(
                      color: isSelected ? AppTheme.backgroundColor : AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (_) => provider.setCategoryFilter(cat),
                  backgroundColor: AppTheme.cardColor,
                  selectedColor: catColor,
                  checkmarkColor: AppTheme.backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: isSelected ? Colors.transparent : AppTheme.borderLight),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Priority and Status filters row combined or stacked
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: Row(
            children: [
              // Priorities Filter Icons
              const Text('  Prioritas: ', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              ...priorities.map((pri) {
                final isSelected = provider.selectedPriority.toLowerCase() == pri.toLowerCase();
                final displayName = pri == 'All'
                    ? 'Semua'
                    : pri == 'High'
                        ? 'Tinggi'
                        : pri == 'Medium'
                            ? 'Sedang'
                            : 'Rendah';

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: ChoiceChip(
                    label: Text(displayName, style: const TextStyle(fontSize: 11)),
                    selected: isSelected,
                    onSelected: (_) => provider.setPriorityFilter(pri),
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.backgroundColor : AppTheme.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                    selectedColor: AppTheme.accentPurple,
                    backgroundColor: AppTheme.cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: isSelected ? Colors.transparent : AppTheme.borderLight),
                    ),
                  ),
                );
              }),
              
              const SizedBox(width: 12),
              // Status filters ChoiceChips
              const Text('Status: ', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              ...statuses.map((stat) {
                final isSelected = provider.statusFilter.toLowerCase() == stat.toLowerCase();
                final displayName = stat == 'All'
                    ? 'Semua'
                    : stat == 'Pending'
                        ? 'Tertunda'
                        : 'Selesai';

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: ChoiceChip(
                    label: Text(displayName, style: const TextStyle(fontSize: 11)),
                    selected: isSelected,
                    onSelected: (_) => provider.setStatusFilter(stat),
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.backgroundColor : AppTheme.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                    selectedColor: AppTheme.accentCyan,
                    backgroundColor: AppTheme.cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: isSelected ? Colors.transparent : AppTheme.borderLight),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in_outlined, size: 72, color: AppTheme.textSecondary.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text(
              'Tidak ada tugas ditemukan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cobalah mengubah filter pencarian Anda atau buat tugas baru.',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(TaskProvider provider, Task task) {
    final priColor = AppTheme.getPriorityColor(task.priority);
    final catColor = AppTheme.getCategoryColor(task.category);
    final catIcon = AppTheme.getCategoryIcon(task.category);
    final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(task.dueDate);

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: AppTheme.priorityHigh.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Hapus Tugas'),
            content: Text('Apakah Anda yakin ingin menghapus tugas "${task.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Batal', style: TextStyle(color: AppTheme.textSecondary)),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Hapus', style: TextStyle(color: AppTheme.priorityHigh)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => _deleteTask(provider, task.id),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: priColor, width: 5),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row: Category Badge + Options Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Category Tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: catColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(catIcon, color: catColor, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              task.category.toUpperCase(),
                              style: TextStyle(
                                color: catColor,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Action Buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.textSecondary),
                            onPressed: () => _showEditTaskDialog(task),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppTheme.textSecondary),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Hapus Tugas'),
                                  content: Text('Apakah Anda yakin ingin menghapus tugas "${task.title}"?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(false),
                                      child: const Text('Batal', style: TextStyle(color: AppTheme.textSecondary)),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(true),
                                      child: const Text('Hapus', style: TextStyle(color: AppTheme.priorityHigh)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                _deleteTask(provider, task.id);
                              }
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Task Title and Description
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Checkbox completed trigger
                      Transform.scale(
                        scale: 1.1,
                        child: Checkbox(
                          value: task.isCompleted,
                          onChanged: (_) => _toggleTaskCompletion(provider, task),
                          activeColor: AppTheme.accentCyan,
                          checkColor: AppTheme.backgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      
                      // Text Title & description
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: task.isCompleted ? AppTheme.textSecondary : AppTheme.textPrimary,
                                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            if (task.description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                task.description,
                                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: AppTheme.borderLight, height: 1),
                  const SizedBox(height: 8),

                  // Footer: Due Date and Priority badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Due Date indicator
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, color: AppTheme.textSecondary, size: 13),
                          const SizedBox(width: 6),
                          Text(
                            formattedDate,
                            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      
                      // Priority Label
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(color: priColor, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            task.priority.toUpperCase(),
                            style: TextStyle(
                              color: priColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
