
import 'dart:convert';
import 'package:sastra_fitmeal/data/local_db.dart';
import 'package:sastra_fitmeal/data/meal_i18n.dart';
import 'package:sastra_fitmeal/i18n/localizations.dart';
import 'package:sastra_fitmeal/models/meal.dart';
void main() {
  final recipes = <Map<String, dynamic>>[];
  for (final m in localMeals) {
    recipes.add({
      'id': m.id, 'name': m.name, 'area': m.area, 'category': m.category,
      'tags': m.tags ?? '', 'rating': m.rating, 'ratings': m.ratingsCount,
      'minutes': m.minutes, 'difficulty': m.difficulty ?? '', 'servings': m.servings,
      'kcal': m.kcal, 'carb': m.carb, 'protein': m.protein, 'fat': m.fat,
      'img': m.isAssetImage ? ('assets/food/' + m.id + '.jpg') : m.image,
      'ings': [for (final i in m.ingredients) [i.name, i.measure]],
      'steps_en': m.steps,
    });
  }
  final km = <String, Map<String, dynamic>>{};
  mealKh.forEach((id, l) {
    km[id] = {'name': l.name, 'ings': l.ingredients, 'steps': l.steps};
  });
  print('@@@' + jsonEncode({'recipes': recipes, 'km': km}));
}
