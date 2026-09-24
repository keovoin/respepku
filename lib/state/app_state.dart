import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/meal.dart';

const kApiBase = 'https://www.themealdb.com/api/json/v1/1';

const List<AppCategory> kCategories = [
  AppCategory('Aneka Nasi', '🍚', Color(0xFFE8842C), '#FDF0E3', query: 'rice'),
  AppCategory('Mie & Pasta', '🍜', Color(0xFFD96C2C), '#FBEDE4', query: 'noodle'),
  AppCategory('Aneka Ayam', '🍗', Color(0xFFC25A2A), '#F9E8E0', query: 'chicken'),
  AppCategory('Aneka Seafood', '🦐', Color(0xFF2E9CA6), '#E4F4F6', query: 'seafood'),
  AppCategory('Aneka Ikan', '🐟', Color(0xFF3E7CB1), '#E8F1FA', query: 'fish'),
  AppCategory('Kue & Pencuci Mulut', '🍰', Color(0xFFB06AB3), '#F4EAF7', query: 'dessert'),
  AppCategory('Sayur & Salad', '🥗', Color(0xFF2F9E63), '#E7F5EC', query: 'vegetable'),
  AppCategory('Minuman', '🥤', Color(0xFF8C8279), '#F0EBE5', query: 'drink'),
];

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

/// TheMealDB API client (free, no key).
class MealApi {
  static Future<List<Meal>> search(String query) async {
    final r = await http.get(
        Uri.parse('$kApiBase/search.php?s=${Uri.encodeComponent(query)}'));
    if (r.statusCode != 200) return const [];
    final j = jsonDecode(r.body) as Map<String, dynamic>;
    final meals = j['meals'];
    if (meals == null) return const [];
    return (meals as List)
        .map((m) => Meal.fromApi(m as Map<String, dynamic>))
        .toList();
  }

  static Future<Meal?> lookup(String id) async {
    final r = await http.get(Uri.parse('$kApiBase/lookup.php?i=$id'));
    if (r.statusCode != 200) return null;
    final j = jsonDecode(r.body) as Map<String, dynamic>;
    final meals = j['meals'];
    if (meals is List && meals.isNotEmpty) {
      return Meal.fromApi(meals.first as Map<String, dynamic>);
    }
    return null;
  }
}
