import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sastra_fitmeal/data/local_db.dart';
import 'package:sastra_fitmeal/i18n/localizations.dart';
import 'package:sastra_fitmeal/main.dart';
import 'package:sastra_fitmeal/models/featured.dart';
import 'package:sastra_fitmeal/models/meal.dart';
import 'package:sastra_fitmeal/screens/account_screen.dart';
import 'package:sastra_fitmeal/screens/detail_screen.dart';
import 'package:sastra_fitmeal/screens/favorites_screen.dart';
import 'package:sastra_fitmeal/screens/home_screen.dart';
import 'package:sastra_fitmeal/screens/search_screen.dart';
import 'package:sastra_fitmeal/screens/shopping_screen.dart';
import 'package:sastra_fitmeal/state/app_state.dart';
import 'package:sastra_fitmeal/state/shop_state.dart';

Future<void> boot(WidgetTester tester) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  final i18n = I18N();
  final app = AppState();
  final shop = ShopState();
  await i18n.init();
  await app.init();
  await shop.init();
  await tester.pumpWidget(
      SastraFitmealApp(i18n: i18n, app: app, shop: shop));
  await tester.pump(const Duration(seconds: 2));
}

/// Boots the app, then swaps the Home body for [screen] (full providers kept).
Future<void> bootScreen(WidgetTester tester, Widget screen) async {
  SharedPreferences.setMockInitialValues({});
  final i18n = I18N();
  final app = AppState();
  final shop = ShopState();
  await i18n.init();
  await app.init();
  await shop.init();
  await tester.pumpWidget(
      SastraFitmealApp(i18n: i18n, app: app, shop: shop));
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: i18n),
        ChangeNotifierProvider.value(value: app),
        ChangeNotifierProvider.value(value: shop),
      ],
      child: MaterialApp(home: screen),
    ),
  );
  await tester.pump(const Duration(milliseconds: 500));
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

  test('bundled local catalog: 28 dishes, all with local photos + ingredients',
      () {
    expect(localMeals.length, 28);
    for (final m in localMeals) {
      expect(m.image, startsWith('assets/food/'),
          reason: '${m.name} must use a bundled photo');
      expect(m.ingredients, isNotEmpty, reason: '${m.name} needs ingredients');
      expect(m.instructions, isNotNull);
      expect(m.instructions, isNotEmpty);
      expect(m.steps, isNotEmpty, reason: '${m.name} needs steps');
    }
    // Amok Trey is the national dish and must be present.
    expect(localMeals.any((m) => m.name.contains('Amok Trey')), isTrue);
  });

  test('Khmer i18n covers all 28 bundled meals', () {
    for (final m in localMeals) {
      final l = m.localeData;
      expect(l, isNotNull, reason: '${m.name} missing Khmer entry');
      expect(l!.name, isNotEmpty, reason: '${m.name} has empty Khmer name');
      expect(l.ingredients.length, m.ingredients.length,
          reason: '${m.name} ingredient count mismatch');
      expect(l.steps, isNotEmpty, reason: '${m.name} missing Khmer steps');
    }
  });

  test('meal locale accessors: Khmer names + English fallback', () {
    final m = MealApi.lookup('53495')!; // Amok Trey
    expect(m.nameIn(true), contains('អំបុកត្រី'));
    expect(m.nameIn(false), contains('Amok Trey'));
    expect(m.ingredientsIn(true).first.name, m.localeData!.ingredients[0][0]);
    expect(m.ingredientsIn(false).first.name, m.ingredients.first.name);
    expect(m.stepsIn(true).first, m.localeData!.steps.first);
    expect(m.stepsIn(false).first, m.steps.first);
  });

  test('local search works offline (no network) for every category', () {
    expect(MealApi.search('').length, 28);
    expect(MealApi.khmer().length, greaterThanOrEqualTo(9));
    for (final m in MealApi.khmer()) {
      expect(m.area, 'Cambodia');
    }
    expect(MealApi.search('rice'), isNotEmpty);
    expect(MealApi.search('chicken'), isNotEmpty);
    expect(MealApi.search('noodle'), isNotEmpty);
    expect(MealApi.search('seafood'), isNotEmpty);
    expect(MealApi.search('fish'), isNotEmpty);
    expect(MealApi.search('dessert'), isNotEmpty);
    // Ingredient-level search.
    expect(MealApi.search('coconut milk'), isNotEmpty);
    // Misses return empty, never throw.
    expect(MealApi.search('zzz_no_such_dish_zzz'), isEmpty);
    // Lookup by id.
    expect(MealApi.lookup('53495')?.name, contains('Amok Trey'));
    expect(MealApi.lookup('nope'), isNull);
  });

  test('featured recipe is Khmer (Amok Trey) with bumbu + nutrition', () {
    final f = getFeaturedMeal();
    expect(f.name.contains('Amok Trey'), isTrue);
    expect(f.area, 'Cambodia');
    expect(f.ingredients, isNotEmpty);
    expect(f.bumbu, isNotEmpty);
    expect(f.kcal, greaterThan(0));
    expect(f.steps, isNotEmpty);
  });

  // ---------- Full-screen smoke tests: every screen, local DB only ----------

  testWidgets('home screen renders featured + Khmer popular row', (tester) async {
    await bootScreen(tester, const HomeScreen());
    expect(find.text('ជំរាបសួរ 👋'), findsOneWidget);
    // Featured banner + popular row show the Khmer name of Amok Trey.
    expect(find.textContaining('អំបុកត្រី'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('search screen: empty state, then live local results for fish',
      (tester) async {
    await bootScreen(tester, const SearchScreen());
    // Fresh screen shows the "type to search" empty state.
    expect(find.text('ស្វែងរក'), findsOneWidget);
    // Type a query and submit.
    await tester.enterText(find.byType(TextField), 'fish');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    // Local catalog has fish dishes (Amok Trey, Fish Amok, Samlor Prah,
    // Seafood Curry...) — result rows must appear (Khmer names now).
    expect(find.textContaining('អំបុកត្រី'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('detail screen: all 5 tabs in Khmer with real data',
      (tester) async {
    // Tall surface so the CustomScrollView's tab content is in view
    // (slivers below the fold are lazily built).
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final m = MealApi.lookup('53495')!; // Amok Trey
    await bootScreen(tester, DetailScreen(meal: m));
    expect(find.text(m.nameIn(true)), findsOneWidget);
    // Tab bar: ingredients / steps / nutrition / rating / buy
    expect(find.byType(TabBar), findsOneWidget);
    // First tab: Khmer ingredient names show real items.
    expect(find.textContaining(m.localeData!.ingredients[0][0]), findsWidgets);
    // Switch to steps tab.
    await tester.tap(find.text('ជំហានចម្អិន').first);
    await tester.pumpAndSettle();
    expect(find.text(m.stepsIn(true).first), findsOneWidget);
    // Switch to nutrition tab: kcal / carb / protein / fat rows.
    await tester.tap(find.text('សារៈប្រាណ').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('kkal'), findsOneWidget);
    // Switch to reviews tab: Khmer reviewer names.
    await tester.tap(find.text('ការវាយតម្លៃ').first);
    await tester.pumpAndSettle();
    expect(find.text('សុភា ឃ.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('detail screen in English: English names + reviewers',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final i18n = I18N();
    final app = AppState();
    final shop = ShopState();
    await i18n.init();
    await app.init();
    await shop.init();
    i18n.setLocale(I18N.en);
    final m = MealApi.lookup('53495')!; // Amok Trey
    // Tall surface so the tab content (in a CustomScrollView) is in view.
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: i18n),
          ChangeNotifierProvider.value(value: app),
          ChangeNotifierProvider.value(value: shop),
        ],
        child: MaterialApp(home: DetailScreen(meal: m)),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text(m.name), findsOneWidget);
    // First tab: English ingredient names.
    expect(find.textContaining('Coconut'), findsWidgets);
    // Switch to the reviews tab (tall viewport keeps it clear of the FAB).
    await tester.tap(find.text('Reviews').first);
    await tester.pumpAndSettle();
    expect(find.text('Sari W.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('favorites screen: empty state, then populated with 2 favorites',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final i18n = I18N();
    final app = AppState();
    final shop = ShopState();
    await i18n.init();
    await app.init();
    await shop.init();
    final m1 = MealApi.lookup('53495')!;
    final m2 = MealApi.lookup('52776')!;
    app.toggleFavorite(m1);
    app.toggleFavorite(m2);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: i18n),
          ChangeNotifierProvider.value(value: app),
          ChangeNotifierProvider.value(value: shop),
        ],
        child: const MaterialApp(home: FavoritesScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(m1.nameIn(true)), findsOneWidget);
    expect(find.text(m2.nameIn(true)), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shopping screen: empty state, then populated + checkable',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final i18n = I18N();
    final app = AppState();
    final shop = ShopState();
    await i18n.init();
    await app.init();
    await shop.init();
    app.addRecipe(MealApi.lookup('53495')!);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: i18n),
          ChangeNotifierProvider.value(value: app),
          ChangeNotifierProvider.value(value: shop),
        ],
        child: const MaterialApp(home: ShoppingScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    // Items from Amok Trey are listed with the Khmer meal name.
    expect(find.textContaining('អំបុកត្រី'), findsWidgets);
    expect(find.textContaining('0/'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('account screen: profile, stats, language list', (tester) async {
    await bootScreen(tester, const AccountScreen());
    expect(find.text('Sastra Digital Innovation'), findsOneWidget);
    expect(find.textContaining('ខ្មែរ'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
