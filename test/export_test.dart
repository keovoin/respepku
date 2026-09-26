// Data exporter for the web build — runs in flutter test VM,
// writes fitmeal-web/js/data.js.
// NOTE: values may be single- OR double-quoted (Dart), and may contain
// \uXXXX escapes for Khmer — decode all of them, the web app needs real
// characters (jsonEncode re-encodes them, which is safe on the JS side).
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sastra_fitmeal/data/local_db.dart';
import 'package:sastra_fitmeal/data/meal_i18n.dart';
import 'package:sastra_fitmeal/models/meal.dart';

String _un(String s) {
  // Dart escapes: \uXXXX \n \t \' \" \\
  final buf = StringBuffer();
  var i = 0;
  while (i < s.length) {
    final c = s[i];
    if (c == r'\' && i + 1 < s.length) {
      final n = s[i + 1];
      if (n == 'u') {
        buf.write(String.fromCharCode(int.parse(s.substring(i + 2, i + 6), radix: 16)));
        i += 6;
        continue;
      }
      if (n == 'n') {
        buf.write('\n');
        i += 2;
        continue;
      }
      if (n == 't') {
        buf.write('\t');
        i += 2;
        continue;
      }
      if (n == '\\') {
        buf.write(r'\');
        i += 2;
        continue;
      }
      // \' or \"
      buf.write(n);
      i += 2;
      continue;
    }
    buf.write(c);
    i++;
  }
  return buf.toString();
}

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

    // UI strings: kh:{...} and en:{...} blocks paired by key.
    // Accepts single- or double-quoted values, decodes Dart escapes.
    final ui = <String, List<String>>{};
    final src = File('lib/i18n/localizations.dart').readAsStringSync();
    final khS = src.indexOf('kh: {', src.indexOf('_tr')) + 5;
    final enS = src.indexOf('en: {', khS) + 5;
    final endS = src.indexOf('\n  };', enS);
    final kv = RegExp(
        "'([a-z0-9_]+)'\\s*:\\s*(?:'((?:[^'\\\\]|\\\\.)*)'|\"((?:[^\"\\\\]|\\\\.)*)\")");
    Map<String, String> parseMap(String seg) {
      final m = <String, String>{};
      for (final mt in kv.allMatches(seg)) {
        m[mt.group(1)!] =
            _un(mt.group(2) ?? mt.group(3) ?? '');
      }
      return m;
    }
    final khMap = parseMap(src.substring(khS, enS));
    final enMap = parseMap(src.substring(enS, endS));
    khMap.forEach((k, v) {
      if (enMap.containsKey(k)) ui[k] = [v, enMap[k]!];
    });
    final lbl = RegExp(r"_label\s*=\s*\{\s*kph?:\s*'((?:[^'\\]|\\.)*)'").firstMatch(src);

    final out = File(r'C:\Users\KEOVOIN-DESKTOP\fitmeal-web\js\data.js');
    out.parent.createSync(recursive: true);
    out.writeAsStringSync('const DATA=' + jsonEncode({
      'recipes': recipes, 'km': km, 'ui': ui,
      'khLabel': lbl != null ? _un(lbl.group(1)!) : '',
    }) + ';', encoding: utf8);
    stderr.writeln('EXPORTED recipes=${recipes.length} km=${km.length} ui=${ui.length}');
  });
}
