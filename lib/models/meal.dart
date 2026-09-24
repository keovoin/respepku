import 'package:flutter/material.dart';

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

  /// Steps: TheMealDB instructions split into lines/sentences.
  List<String> get steps {
    final raw = instructions;
    if (raw == null || raw.trim().isEmpty) {
      return const [
        'Persiapkan semua bahan sesuai daftar di atas.',
        'Masak sesuai metode resep (tumis, rebus, panggang, atau goreng).',
        'Sajikan selagi hangat bersama nasi dan pelengkap favoritmu.',
      ];
    }
    return splitInstructions(raw);
  }

  /// Builds a Meal from a TheMealDB lookup/search result.
  factory Meal.fromApi(Map<String, dynamic> j) {
    final ing = <Ingredient>[];
    for (var i = 0; i < 20; i++) {
      final name = (j['strIngredients$i'] ?? '').toString().trim();
      if (name.isEmpty) continue;
      final measure = (j['strMeasure$i'] ?? '').toString().trim();
      ing.add(Ingredient(name, measure));
    }
    // Split first 50% of ingredients into "bahan" and rest into "bumbu"
    // when there's no explicit spice marker — simple heuristic.
    return Meal(
      id: (j['idMeal'] ?? '').toString(),
      name: (j['strMeal'] ?? 'Resep').toString(),
      image: (j['strMealThumb'] ?? '').toString(),
      area: (j['strArea'] ?? 'Indonesia').toString(),
      category: (j['strCategory'] ?? 'Masakan').toString(),
      tags: (j['strTags'] ?? null)?.toString(),
      youtube: (j['strYoutube'] ?? null)?.toString(),
      source: (j['strSource'] ?? null)?.toString(),
      ingredients: ing,
      instructions: (j['strInstructions'] ?? '').toString().isEmpty
          ? null
          : (j['strInstructions'] as String),
      isMock: false,
    );
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
