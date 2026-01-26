import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/shopping_list.dart';

class StorageService {
  static const String _listsKey = 'shopping_lists_v1';

  Future<List<ShoppingList>> getAllLists() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_listsKey);
    if (raw == null || raw.isEmpty) return [];
    final List<dynamic> decoded = json.decode(raw) as List<dynamic>;
    return decoded
        .map((e) => ShoppingList.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveAllLists(List<ShoppingList> lists) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(lists.map((e) => e.toMap()).toList());
    await prefs.setString(_listsKey, encoded);
  }

  Future<void> addList(ShoppingList list) async {
    final lists = await getAllLists();
    lists.add(list);
    await _saveAllLists(lists);
  }

  Future<void> deleteList(String id) async {
    final lists = await getAllLists();
    lists.removeWhere((l) => l.id == id);
    await _saveAllLists(lists);
  }

  Future<void> renameList(String id, String newName) async {
    final lists = await getAllLists();
    for (final l in lists) {
      if (l.id == id) {
        l.name = newName;
        break;
      }
    }
    await _saveAllLists(lists);
  }

  Future<void> updateList(ShoppingList updated) async {
    final lists = await getAllLists();
    final index = lists.indexWhere((l) => l.id == updated.id);
    if (index >= 0) {
      lists[index] = updated;
      await _saveAllLists(lists);
    }
  }

  Future<ShoppingList?> getById(String id) async {
    final lists = await getAllLists();
    try {
      return lists.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }
}
