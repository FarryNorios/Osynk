import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sync_log.dart';

class SyncLogRepository extends ChangeNotifier {
  static const int _maxStoredLogs = 500;

  final List<SyncLogEntry> _logs = [];
  List<SyncLogEntry> get logs => _logs;

  Timer? _saveTimer;

  void append(SyncLogEntry entry) {
    _logs.add(entry);
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 2), _save);
    notifyListeners();
  }

  void clear() {
    _logs.clear();
    _save();
    notifyListeners();
  }

  // ─── Persistence ───

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('SyncLogs');
      if (json != null && json.isNotEmpty) {
        final list = jsonDecode(json) as List;
        _logs.clear();
        _logs.addAll(list.map((e) => SyncLogEntry.fromJson(e as Map<String, dynamic>)));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load logs: $e');
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_logs.isEmpty) {
        await prefs.remove('SyncLogs');
      } else {
        final toSave = _logs.length > _maxStoredLogs
            ? _logs.sublist(_logs.length - _maxStoredLogs)
            : _logs;
        final json = jsonEncode(toSave.map((e) => e.toJson()).toList());
        await prefs.setString('SyncLogs', json);
      }
    } catch (e) {
      debugPrint('Failed to save logs: $e');
    }
  }

  void flushSave() {
    _saveTimer?.cancel();
    if (_logs.isNotEmpty) _save();
  }
}
