import 'package:flutter/material.dart';
import '../config/supabase_config.dart';
import '../models/task_model.dart';
import '../services/database_service.dart';
import '../services/supabase_database_service.dart';
import '../services/local_database_service.dart';
import '../services/notification_service.dart';

class TaskProvider extends ChangeNotifier {
  final DatabaseService _dbService = SupabaseConfig.isConfigured
      ? SupabaseDatabaseService()
      : LocalDatabaseService();

  final NotificationService _notificationService = NotificationService();

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Filters & Search
  String _selectedCategory = 'All';
  String _selectedPriority = 'All';
  String _searchQuery = '';
  String _statusFilter = 'All'; // 'All' | 'Pending' | 'Completed'

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get selectedCategory => _selectedCategory;
  String get selectedPriority => _selectedPriority;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;

  // Setters for search and filters
  void setCategoryFilter(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setPriorityFilter(String priority) {
    _selectedPriority = priority;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _statusFilter = status;
    notifyListeners();
  }

  // Filtered tasks getter
  List<Task> get filteredTasks {
    return _tasks.where((task) {
      final matchesCategory = _selectedCategory == 'All' ||
          task.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesPriority = _selectedPriority == 'All' ||
          task.priority.toLowerCase() == _selectedPriority.toLowerCase();
      final matchesStatus = _statusFilter == 'All' ||
          (_statusFilter == 'Completed' && task.isCompleted) ||
          (_statusFilter == 'Pending' && !task.isCompleted);
      final matchesSearch = task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          task.description.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesCategory && matchesPriority && matchesStatus && matchesSearch;
    }).toList();
  }

  // Dashboard Stats
  int get totalTasksCount => _tasks.length;
  int get completedTasksCount => _tasks.where((t) => t.isCompleted).length;
  int get pendingTasksCount => _tasks.where((t) => !t.isCompleted).length;
  double get completionRate =>
      totalTasksCount == 0 ? 0.0 : completedTasksCount / totalTasksCount;

  int getPriorityCount(String priority) {
    return _tasks.where((t) => t.priority.toLowerCase() == priority.toLowerCase()).length;
  }

  int getCategoryCount(String category) {
    return _tasks.where((t) => t.category.toLowerCase() == category.toLowerCase()).length;
  }

  // CRUD: READ Tasks
  Future<void> fetchTasks(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await _dbService.getTasks(userId);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // CRUD: CREATE Task
  Future<bool> addTask(Task task) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final createdTask = await _dbService.createTask(task);
      _tasks.insert(0, createdTask);
      
      // Notify CRUD Creation
      await _notificationService.showNotification(
        title: 'Tugas Baru Dibuat 📝',
        message: 'Tugas "${createdTask.title}" berhasil dibuat.',
        type: 'create',
      );
      
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // CRUD: UPDATE Task
  Future<bool> updateTask(Task task) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedTask = await _dbService.updateTask(task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        // Check if completion status changed to trigger special notification
        final wasCompleted = _tasks[index].isCompleted;
        _tasks[index] = updatedTask;

        if (!wasCompleted && updatedTask.isCompleted) {
          await _notificationService.showNotification(
            title: 'Tugas Selesai! 🎉',
            message: 'Kerja bagus! Tugas "${updatedTask.title}" telah diselesaikan.',
            type: 'complete',
          );
        } else {
          await _notificationService.showNotification(
            title: 'Tugas Diperbarui ⚙️',
            message: 'Tugas "${updatedTask.title}" berhasil diperbarui.',
            type: 'update',
          );
        }
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // CRUD: DELETE Task
  Future<bool> deleteTask(String taskId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final index = _tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        final taskTitle = _tasks[index].title;
        await _dbService.deleteTask(taskId);
        _tasks.removeAt(index);

        // Notify CRUD Deletion
        await _notificationService.showNotification(
          title: 'Tugas Dihapus 🗑️',
          message: 'Tugas "$taskTitle" telah dihapus.',
          type: 'delete',
        );
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
