import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:respepku/i18n/localizations.dart';
import 'package:respepku/main.dart';
import 'package:respepku/models/meal.dart';
import 'package:respepku/state/app_state.dart';

Future<void> boot(WidgetTester tester) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  final i18n = I18N();
  final app = AppState();
  await i18n.init();
  await app.init();
  await tester.pumpWidget(ResepKuApp(i18n: i18n, app: app));
  await tester.pump(const Duration(seconds: 2));
}

void main() {
  testWidgets('boots with Khmer UI and 5-tab nav', (tester) async {
    await boot(tester);

    // Khmer greeting + today's featured title
    expect(find.text('ជំរាបសួរ 👋'), findsOneWidget);
    expect(find.text('🔥 រូបមន្តពិសេសថ្ងៃនេះ'), findsOneWidget);
    // 5-tab bottom navigation in Khmer
    expect(find.text('ទំព័រដើម'), findsOneWidget);
    expect(find.text('ស្វែងរក'), findsOneWidget);
    expect(find.text('ចូលចិត្ត'), findsOneWidget);
    expect(find.text('គណនី'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('switching to English re-localizes the UI', (tester) async {
    await boot(tester);

    // Switch locale the same way the Account tab does.
    final ctx = tester.element(find.text('ជំរាបសួរ 👋'));
    ctx.read<I18N>().setLocale(I18N.en);
    await tester.pump();

    expect(find.text('Welcome 👋'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
    // Khmer strings are gone
    expect(find.text('ជំរាបសួរ 👋'), findsNothing);
  });

  test('favorites + shopping list persist across restarts', () async {
    SharedPreferences.setMockInitialValues({});
    final meal = Meal(
      id: '52772',
      name: 'Mie Goreng Spesial',
      image: 'https://example.com/x.jpg',
      ingredients: const [Ingredient('Noodles', '200 g')],
      isMock: true,
    );

    // Session 1: favorite + add recipe to shopping list, check one item.
    final a1 = AppState();
    await a1.init();
    a1.toggleFavorite(meal);
    a1.addRecipe(meal);
    final key = '52772|Noodles|200 g';
    a1.toggleChecked(key);
    await Future<void>.delayed(Duration.zero); // let _save finish
    final prefs = await SharedPreferences.getInstance();

    // Session 2: fresh state, restore from the same store.
    final a2 = AppState();
    await a2.init();
    expect(a2.favoriteCount, 1);
    expect(a2.isFavorite('52772'), isTrue);
    expect(a2.favoriteMeals.first.name, 'Mie Goreng Spesial');
    expect(a2.favoriteMeals.first.ingredients.length, 1);
    expect(a2.isRecipeListed('52772'), isTrue);
    expect(a2.isChecked(key), isTrue);
    expect(a2.shoppingItems.first.name, 'Noodles');
    expect(a2.shoppingItems.first.mealName, 'Mie Goreng Spesial');
    expect(prefs, isNotNull);
  });

  test('locale persists across restarts', () async {
    SharedPreferences.setMockInitialValues({});
    final i1 = I18N();
    await i1.init();
    expect(i1.locale, I18N.kh); // default
    i1.setLocale(I18N.en);
    await Future<void>.delayed(Duration.zero);

    final i2 = I18N();
    await i2.init();
    expect(i2.locale, I18N.en);
  });
}
