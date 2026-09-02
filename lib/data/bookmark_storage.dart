import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:study/features/student/data/models/bookmark_model.dart';

abstract class BookmarkStorage {
  Future<List<BookmarkModel>> getAll();
  Future<void> save(BookmarkModel bookmark);
  Future<void> remove(String id);
  Future<void> clear();
}

class SharedPreferencesBookmarkStorage implements BookmarkStorage {
  SharedPreferencesBookmarkStorage(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'bookmarks';

  @override
  Future<List<BookmarkModel>> getAll() async {
    final json = _prefs.getString(_key);
    if (json == null || json.isEmpty) return [];
    final list = jsonDecode(json) as List;
    return list.map((e) => BookmarkModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> save(BookmarkModel bookmark) async {
    final all = await getAll();
    // Remove if exists, then add
    all.removeWhere((b) => b.id == bookmark.id);
    all.add(bookmark);
    await _prefs.setString(_key, jsonEncode(all.map((e) => e.toJson()).toList()));
  }

  @override
  Future<void> remove(String id) async {
    final all = await getAll();
    all.removeWhere((b) => b.id == id);
    await _prefs.setString(_key, jsonEncode(all.map((e) => e.toJson()).toList()));
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_key);
  }
}
