// Temporary data exporter for the web rewrite — runs in flutter test VM,
// writes fitmeal-web/js/data.js, then gets deleted.
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sastra_fitmeal/data/local_db.dart';
import 'package:sastra_fitmeal/data/meal_i18n.dart';
import 'package:sastra_fitmeal/models/meal.dart';

void main() {
  test('export catalog + khmer + ui strings', () {
    final recipes = <Map<String, dynamic>>[];
    for (final m in localMeals) {
      recipes.add({
        'id': m.id, 'name': m.name, 'area': m.area, 'category': m.category,
        'tags': m.tags ?? '', 'rating': m.rating, 'ratings': m.ratingsCount,
        'minutes': m.minutes, 'difficulty': m.difficulty ?? '',
        'servings': m.servings,
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

    // UI strings: kh:{...} and en:{...} blocks paired by key order
    final ui = <String, List<String>>{};
    final src = File('lib/i18n/localizations.dart').readAsStringSync();
    final khS = src.indexOf('kh: {', src.indexOf('_tr'));
    final enS = src.indexOf('en: {', khS);
    final endS = src.indexOf('\n  };', enS);
    final kv = RegExp(r"'([a-z0-9_]+)':\s*'((?:[^'\\]|\\.)*)'");
    final khMap = <String, String>{};
    final enMap = <String, String>{};
    for (final mt in kv.allMatches(src.substring(khS + 5, enS))) {
      khMap[mt.group(1)!] = mt.group(2)!;
    }
    for (final mt in kv.allMatches(src.substring(enS + 5, endS))) {
      enMap[mt.group(1)!] = mt.group(2)!;
    }
    String un(String s) => s.replaceAll("\\'", "'").replaceAll(r'\n', '\n').replaceAll(r'$', r'$');
    khMap.forEach((k, v) {
      if (enMap.containsKey(k)) ui[k] = [un(v), un(enMap[k]!)];
    });
    final lbl = RegExp(r"_label\s*=\s*\{\s*kph?:\s*'((?:[^'\\]|\\.)*)'").firstMatch(src) ??
        RegExp(r"kh:\s*'((?:[^'\\]|\\.)*)',\s*en:\s*'English'").firstMatch(src);

    final out = File(r'C:\Users\KEOVOIN-DESKTOP\fitmeal-web\js\data.js');
    out.parent.createSync(recursive: true);
    out.writeAsStringSync('const DATA=' + jsonEncode({
      'recipes': recipes, 'km': km, 'ui': ui,
      'khLabel': lbl?.group(1) ?? '',
    }) + ';', encoding: utf8);
    stderr.writeln('EXPORTED recipes=${recipes.length} km=${km.length} ui=${ui.length}');
  });
}
