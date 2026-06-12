//Geranada Saputra Priambudi 2311102008
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';
import 'task_form_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();

  void _logout(BuildContext context) async {
    await _firebaseService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  void _deleteTask(BuildContext context, String taskId) async {
    try {
      await _firebaseService.deleteTask(taskId);
      NotificationService.showNotification(
        id: DateTime.now().millisecond,
        title: 'Task Deleted',
        body: 'Your task was successfully deleted.',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete task: $e')),
      );
    }
  }

  void _toggleTaskStatus(BuildContext context, String taskId, bool currentStatus) async {
    try {
      await _firebaseService.updateTaskStatus(taskId, !currentStatus);
      if (!currentStatus) {
        NotificationService.showNotification(
          id: DateTime.now().millisecond,
          title: 'Task Completed 🎉',
          body: 'Great job completing your task!',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update task: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('My Tasks', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firebaseService.getTasksStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No tasks yet. Add some!',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          final tasks = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final doc = tasks[index];
              final data = doc.data() as Map<String, dynamic>;
              final title = data['title'] ?? '';
              final description = data['description'] ?? '';
              final isCompleted = data['isCompleted'] ?? false;

              return Card(
                margin: EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Checkbox(
                    value: isCompleted,
                    onChanged: (_) => _toggleTaskStatus(context, doc.id, isCompleted),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  title: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                      color: isCompleted ? Colors.grey : Colors.black87,
                    ),
                  ),
                  subtitle: description.isNotEmpty
                      ? Text(
                          description,
                          style: TextStyle(
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        )
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TaskFormScreen(
                                taskId: doc.id,
                                initialTitle: title,
                                initialDescription: description,
                                initialIsCompleted: isCompleted,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTask(context, doc.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TaskFormScreen()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
