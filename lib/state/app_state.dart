import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/local_db.dart';
import '../models/meal.dart';

/// Search a local, offline category from the bundled catalog.
const kKhmerQuery = 'khmer';

class ShoppingItem {
  final String key;
  final String name;
  final String measure;
  final String mealName;
  final bool checked;

  ShoppingItem({
    required this.key,
    required this.name,
    required this.measure,
    required this.mealName,
    required this.checked,
  });

  /// Key format: `mealId|ingredientName|measure`
  static ShoppingItem parse(String key, String mealName, bool checked) {
    final parts = key.split('|');
    return ShoppingItem(
      key: key,
      name: parts.length > 1 && parts[1].isNotEmpty ? parts[1] : 'Resep',
      measure: parts.length > 2 ? parts[2] : '',
      mealName: mealName,
      checked: checked,
    );
  }
}

class AppState extends ChangeNotifier {
  final Map<String, Meal> _favorites = {};
  final Set<String> _listed = {};
  final Set<String> _checked = {};
  final Map<String, String> _mealNames = {};

  SharedPreferences? _prefs;

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (_) {
      _prefs = null; // test/headless — in-memory only
    }
    _restore();
    notifyListeners();
  }

  void _restore() {
    final p = _prefs;
    if (p == null) return;
    try {
      final favRaw = p.getString('favorites');
      if (favRaw != null) {
        final list = jsonDecode(favRaw) as List;
        for (final m in list) {
          final meal = Meal.fromJson(m as Map<String, dynamic>);
          _favorites[meal.id] = meal;
        }
      }
      final listedRaw = p.getString('shopping_listed');
      if (listedRaw != null) {
        for (final k in (jsonDecode(listedRaw) as List)) {
          _listed.add(k.toString());
        }
      }
      final checkedRaw = p.getString('shopping_checked');
      if (checkedRaw != null) {
        for (final k in (jsonDecode(checkedRaw) as List)) {
          _checked.add(k.toString());
        }
      }
      final namesRaw = p.getString('shopping_names');
      if (namesRaw != null) {
        _mealNames.addAll(
            (jsonDecode(namesRaw) as Map<String, dynamic>).map(
                (k, v) => MapEntry(k, v.toString())));
      }
    } catch (_) {
      // corrupt data — start fresh
      _favorites.clear();
      _listed.clear();
      _checked.clear();
    }
  }

  Future<void> _save() async {
    final p = _prefs;
    if (p == null) return;
    try {
      await p.setString(
          'favorites',
          jsonEncode([for (final m in _favorites.values) m.toJson()]));
      await p.setString('shopping_listed', jsonEncode(_listed.toList()));
      await p.setString('shopping_checked', jsonEncode(_checked.toList()));
      await p.setString('shopping_names', jsonEncode(_mealNames));
    } catch (_) {
      // storage failure — keep working in memory
    }
  }

  double get progress => 0.62; // weekly goal (mock, phase 1)

  // ---------- favorites ----------
  bool isFavorite(String id) => _favorites.containsKey(id);
  int get favoriteCount => _favorites.length;
  List<Meal> get favoriteMeals => _favorites.values.toList();

  void toggleFavorite(Meal m) {
    if (!_favorites.containsKey(m.id)) {
      _favorites[m.id] = m;
    } else {
      _favorites.remove(m.id);
    }
    notifyListeners();
    _save();
  }

  // ---------- shopping list ----------
  bool isListed(String key) => _listed.contains(key);
  bool isChecked(String key) => _checked.contains(key);
  int get listCount => _listed.length;
  bool isRecipeListed(String mealId) =>
      _listed.any((k) => k.startsWith('$mealId|'));

  List<ShoppingItem> get shoppingItems => [
        for (final k in _listed)
          ShoppingItem.parse(
              k, _mealNames[k.split('|').first] ?? '', isChecked(k)),
      ];

  void addIngredient(Meal m, Ingredient i) {
    final key = '${m.id}|${i.name}|${i.measure}';
    _mealNames[m.id] = m.name;
    _listed.add(key);
    notifyListeners();
    _save();
  }

  void removeIngredient(String key) {
    _listed.remove(key);
    _checked.remove(key);
    notifyListeners();
    _save();
  }

  void addRecipe(Meal m) {
    if (m.allIngredients.isEmpty) {
      _listed.add('${m.id}||');
    } else {
      for (final i in m.allIngredients) {
        addIngredient(m, i);
      }
    }
  }

  void toggleChecked(String key) {
    if (!_checked.add(key)) _checked.remove(key);
    notifyListeners();
    _save();
  }

  void checkAll() {
    _checked.addAll(_listed);
    notifyListeners();
    _save();
  }

  void clearDone() {
    _listed.removeWhere((k) => _checked.contains(k));
    _checked.removeWhere((k) => !_listed.contains(k));
    notifyListeners();
    _save();
  }
}

/// Local recipe catalog reader.
///
/// Everything ships inside the app: 28 real recipes (9 Khmer + world
/// favorites) with photos in assets/food/. Zero network — the app runs
/// fully offline. `search` filters the bundled catalog in memory.
class MealApi {
  static final Map<String, Meal> _byId =
      {for (final m in localMeals) m.id: m};

  /// All bundled recipes.
  static List<Meal> all() => List<Meal>.unmodifiable(localMeals);

  /// Khmer dishes from the bundled catalog.
  static List<Meal> khmer() => all()
      .where((m) =>
          m.area == 'Cambodia' ||
          (m.tags?.toLowerCase().contains('khmer') ?? false) ||
          m.name.contains('Khmer') ||
          m.name.contains('Cambodian'))
      .toList();

  /// In-memory search over name, category, area, tags and ingredients.
  static List<Meal> search(String rawQuery) {
    final q = rawQuery.trim().toLowerCase();
    if (q.isEmpty) return all();
    final tokens = q.split(RegExp(r'\s+'));
    return all().where((m) {
      final hay = [
        m.name,
        m.category,
        m.area,
        m.tags ?? '',
        for (final i in m.allIngredients) i.name,
      ].join(' ').toLowerCase();
      return tokens.every(hay.contains);
    }).toList();
  }

  /// Fetch one bundled recipe by id (local, never touches the network).
  static Meal? lookup(String id) => _byId[id];
}
