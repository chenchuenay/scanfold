import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class HistoryItem {
  final String title;
  final String type;
  final String path;
  final DateTime createdAt;

  const HistoryItem({
    required this.title,
    required this.type,
    required this.path,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'type': type,
    'path': path,
    'createdAt': createdAt.toIso8601String(),
  };

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
    title: json['title'] as String? ?? 'File',
    type: json['type'] as String? ?? 'file',
    path: json['path'] as String? ?? '',
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
  );
}

abstract final class HistoryService {
  static const _key = 'scanfold_history';

  static Future<List<HistoryItem>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? const [];
    return raw
        .map((item) {
          try {
            return HistoryItem.fromJson(
              jsonDecode(item) as Map<String, dynamic>,
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<HistoryItem>()
        .toList();
  }

  static Future<void> add(HistoryItem item) async {
    final items = await load();
    items.removeWhere((old) => old.path == item.path);
    items.insert(0, item);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      items.take(40).map((value) => jsonEncode(value.toJson())).toList(),
    );
  }

  static Future<void> remove(String path) async {
    final items = await load();
    items.removeWhere((old) => old.path == path);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      items.take(40).map((value) => jsonEncode(value.toJson())).toList(),
    );
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
