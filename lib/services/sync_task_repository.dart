import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sync_task.dart';

class SyncTaskRepository extends ChangeNotifier {
  List<SyncTask> _tasks = [];
  List<SyncTask> get tasks => _tasks;

  void add(SyncTask task) {
    _tasks = [..._tasks, task];
    _save();
    notifyListeners();
  }

  void delete(int index) {
    _tasks = [..._tasks]..removeAt(index);
    _save();
    notifyListeners();
  }

  void update(int index, SyncTask task) {
    _tasks = [..._tasks];
    _tasks[index] = task;
    _save();
    notifyListeners();
  }

  // ─── Persistence ───

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('SyncTasks');
      if (json != null && json.isNotEmpty) {
        final list = jsonDecode(json) as List;
        _tasks = list.map((t) => SyncTask.fromJson(t as Map<String, dynamic>)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to parse syncTasks: $e');
      _tasks = [];
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_tasks.isEmpty) {
        await prefs.remove('SyncTasks');
      } else {
        final json = jsonEncode(_tasks.map((t) => t.toJson()).toList());
        await prefs.setString('SyncTasks', json);
      }
    } catch (e) {
      debugPrint('Failed to save syncTasks: $e');
    }
  }
}
