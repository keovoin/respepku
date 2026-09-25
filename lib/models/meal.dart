import 'package:flutter/material.dart';

import '../data/meal_i18n.dart';

/// Domain models for recipes, ingredients, categories.
class Ingredient {
  final String name;
  final String measure;
  const Ingredient(this.name, this.measure);

  String get label => measure.trim().isEmpty ? name : '$measure $name';
}

class Meal {
  final String id;
  final String name;
  final String image;
  final String area;
  final String category;
  final String? tags;
  final String? youtube;
  final String? source;
  final List<Ingredient> ingredients;
  final String? instructions;
  final double? rating;
  final int? ratingsCount;
  final int? minutes;
  final String? difficulty;
  final int? servings;

  // Nutrition (per serving) — from TheMealDB v2 or mock.
  final int? kcal;
  final int? carb;
  final int? protein;
  final int? fat;

  /// Extra "Bumbu" (spices) section for Indonesian-style recipes.
  final List<Ingredient> bumbu;
  final bool isMock;

  const Meal({
    required this.id,
    required this.name,
    required this.image,
    this.area = 'Indonesia',
    this.category = 'Masakan',
    this.tags,
    this.youtube,
    this.source,
    this.ingredients = const [],
    this.instructions,
    this.rating,
    this.ratingsCount,
    this.minutes,
    this.difficulty,
    this.servings,
    this.kcal,
    this.carb,
    this.protein,
    this.fat,
    this.bumbu = const [],
    this.isMock = false,
  });

  List<Ingredient> get allIngredients =>
      [...ingredients, ...bumbu];

  // ---------- Khmer locale (from meal_i18n.dart) ----------

  /// Khmer rendering of this meal, if bundled.
  MealLocale? get localeData => mealKh[id];

  /// Display name in the requested language (Khmer falls back to English).
  String nameIn(bool useKhmer) {
    if (useKhmer) {
      final l = localeData;
      if (l != null) return l.name;
    }
    return name;
  }

  /// Ingredients in the requested language (1:1 with the English list).
  List<Ingredient> ingredientsIn(bool useKhmer) {
    if (useKhmer) {
      final l = localeData;
      if (l != null) {
        return [for (final p in l.ingredients) Ingredient(p[0], p[1])];
      }
    }
    return allIngredients;
  }

  /// Cooking steps in the requested language.
  List<String> stepsIn(bool useKhmer) {
    if (useKhmer) {
      final l = localeData;
      if (l != null && l.steps.isNotEmpty) return l.steps;
    }
    return steps;
  }

  /// Ingredient name in the requested language (1:1 index/name match).
  String ingNameIn(bool useKhmer, Ingredient ing) {
    if (useKhmer) {
      final l = localeData;
      if (l != null) {
        final i = ingredients.indexWhere(
            (e) => e.name == ing.name && e.measure == ing.measure);
        if (i != -1 && i < l.ingredients.length) return l.ingredients[i][0];
      }
    }
    return ing.name;
  }

  /// True when the photo ships inside the app (assets/food/*.jpg).
  bool get isAssetImage => image.startsWith('assets/');

  /// Steps: TheMealDB instructions split into lines/sentences.
  List<String> get steps {
    final raw = instructions;
    if (raw == null || raw.trim().isEmpty) {
      return const [
        'Prepare all the ingredients from the list above.',
        'Cook following the recipe method (stir-fry, boil, bake or fry).',
        'Serve warm with rice and your favourite sides.',
      ];
    }
    return splitInstructions(raw);
  }

  // ---------- persistence (shared_preferences) ----------
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image': image,
        'area': area,
        'category': category,
        'tags': tags,
        'youtube': youtube,
        'source': source,
        'ingredients':
            [for (final i in ingredients) [i.name, i.measure]],
        'instructions': instructions,
        'rating': rating,
        'ratingsCount': ratingsCount,
        'minutes': minutes,
        'difficulty': difficulty,
        'servings': servings,
        'kcal': kcal,
        'carb': carb,
        'protein': protein,
        'fat': fat,
        'bumbu': [for (final i in bumbu) [i.name, i.measure]],
        'isMock': isMock,
      };

  factory Meal.fromJson(Map<String, dynamic> j) => Meal(
        id: (j['id'] ?? '').toString(),
        name: (j['name'] ?? 'Resep').toString(),
        image: (j['image'] ?? '').toString(),
        area: (j['area'] ?? 'Indonesia').toString(),
        category: (j['category'] ?? 'Masakan').toString(),
        tags: j['tags']?.toString(),
        youtube: j['youtube']?.toString(),
        source: j['source']?.toString(),
        ingredients: _ingList(j['ingredients']),
        instructions: j['instructions']?.toString().isEmpty == true
            ? null
            : j['instructions']?.toString(),
        rating: (j['rating'] as num?)?.toDouble(),
        ratingsCount: j['ratingsCount'] as int?,
        minutes: j['minutes'] as int?,
        difficulty: j['difficulty']?.toString(),
        servings: j['servings'] as int?,
        kcal: j['kcal'] as int?,
        carb: j['carb'] as int?,
        protein: j['protein'] as int?,
        fat: j['fat'] as int?,
        bumbu: _ingList(j['bumbu']),
        isMock: (j['isMock'] as bool?) ?? false,
      );

  static List<Ingredient> _ingList(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<List>()
        .where((p) => p.length >= 2)
        .map((p) =>
            Ingredient(p[0].toString(), (p[1] ?? '').toString()))
        .toList();
  }
}

/// Splits raw TheMealDB instructions into numbered steps.
List<String> splitInstructions(String raw) {
  final text = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n').trim();
  if (text.isEmpty) return const [];
  final parts = text.split(RegExp(r'\n+')).where((p) => p.trim().isNotEmpty);
  final steps = <String>[];
  for (final part in parts) {
    // TheMealDB sometimes prefixes "1. " / "Step 1:"
    final cleaned =
        part.replaceFirst(RegExp(r'^\s*\d+[.\)]\s*'), '').trim();
    if (cleaned.isNotEmpty) steps.add(cleaned);
  }
  if (steps.length <= 1) {
    // single blob -> split on sentence-ish boundaries
    return text
        .split(RegExp(r'(?<=[.!?])\s+(?=[A-Z])'))
        .where((s) => s.trim().isNotEmpty)
        .map((s) => s.trim())
        .toList();
  }
  return steps;
}

class AppCategory {
  final String name;
  final String emoji;
  final Color color;
  final String soft;
  /// What to send to the search API (query word) — null = show grid only.
  final String? query;
  const AppCategory(this.name, this.emoji, this.color, this.soft,
      {this.query});
}
