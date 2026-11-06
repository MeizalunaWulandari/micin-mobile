import 'package:flutter/foundation.dart';
import '../models/task_model.dart';

/// ViewModel untuk Home Screen yang menangani business logic & state
class HomeViewModel extends ChangeNotifier {
  final List<TaskModel> _tasks = [];
  bool _isLoading = false;

  List<TaskModel> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;

  HomeViewModel() {
    _initDefaultTasks();
  }

  void _initDefaultTasks() {
    _tasks.addAll([
      TaskModel(
        id: '1',
        title: 'Project Setup & Package Configuration',
        description: 'Inisialisasi Flutter dengan com.micinproject.app',
        isCompleted: true,
        createdAt: DateTime.now(),
      ),
      TaskModel(
        id: '2',
        title: 'MVVM Architecture & Folder Structure',
        description: 'Struktur lib: core, models, viewmodels, views',
        isCompleted: true,
        createdAt: DateTime.now(),
      ),
      TaskModel(
        id: '3',
        title: 'Always Dark Mode Theme',
        description: 'Tampilan tema gelap terkunci dengan AppTheme.darkTheme',
        isCompleted: true,
        createdAt: DateTime.now(),
      ),
    ]);
    notifyListeners();
  }

  void toggleTaskStatus(String id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      final task = _tasks[index];
      _tasks[index] = task.copyWith(isCompleted: !task.isCompleted);
      notifyListeners();
    }
  }

  Future<void> addNewTask(String title, String description) async {
    if (title.trim().isEmpty) return;

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 250));

    _tasks.insert(
      0,
      TaskModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        createdAt: DateTime.now(),
      ),
    );

    _isLoading = false;
    notifyListeners();
  }
}

