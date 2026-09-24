import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight in-app i18n: Khmer (default), English.
///
/// `t('key')` resolves in the active locale, English as fallback.
/// Placeholders: `{n}`, `{a}`, `{b}`.
class I18N extends ChangeNotifier {
  I18N({this.locale = kh});

  static const kh = 'kh';
  static const en = 'en';

  static const _label = {kh: 'ភាសាខ្មែរ', en: 'English'};

  String locale;

  Future<void> init() async {
    try {
      final p = await SharedPreferences.getInstance();
      final s = p.getString('locale');
      if (s != null && _label.containsKey(s)) {
        locale = s;
        notifyListeners();
      }
    } catch (_) {
      // headless / test env without plugin — keep default
    }
  }

  void setLocale(String l) {
    if (!_label.containsKey(l) || l == locale) return;
    locale = l;
    notifyListeners();
    SharedPreferences.getInstance()
        .then((p) => p.setString('locale', l))
        .catchError((_) => false);
  }

  String label(String l) => _label[l] ?? l;

  static const List<String> locales = [kh, en];

  String t(String key, {String? n, String? a, String? b}) {
    final d = _tr[locale] ?? _tr[en]!;
    var s = d[key] ?? _tr[en]![key] ?? key;
    if (n != null) s = s.replaceAll('{n}', n);
    if (a != null) s = s.replaceAll('{a}', a);
    if (b != null) s = s.replaceAll('{b}', b);
    return s;
  }

  static const _tr = <String, Map<String, String>>{
    // ---------------- Khmer ----------------
    kh: {
      'nav_home': 'ទំព័រដើម',
      'nav_search': 'ស្វែងរក',
      'nav_fav': 'ចូលចិត្ត',
      'nav_shop': 'ទិញ',
      'nav_acc': 'គណនី',
      'greeting': 'ជំរាបសួរ 👋',
      'hi': 'សួស្តី',
      'search_hint': 'ចង់ចម្អិនអ្វីថ្ងៃនេះ?',
      'featured_badge': '🔥 រូបមន្តពិសេសថ្ងៃនេះ',
      'cook_now': 'ចម្អិនឥឡូវនេះ',
      'featured_name': 'អាម៉ុកត្រី',
      'category': 'ប្រភេទ',
      'popular_today': 'ពេញនិយមថ្ងៃនេះ',
      'continue_cooking': 'បន្តចម្អិន',
      'step_of': 'ជំហានទី {a} ពី {b}',
      'loading': 'កំពុងផ្ទុករូបមន្ត…',
      'load_failed':
          'មិនអាចផ្ទុករូបមន្តបាន។ សូមពិនិត្យការតភ្ជាប់ រួចសាកល្បងម្តងទៀត។',
      'no_notifications': 'មិនទាន់មានជូនដំណឹង',
      'see_all': 'មើលទាំងអស់',
      'min_short': 'នាទី {n}',
      'search': 'ស្វែងរក',
      'search_results': 'លទ្ធផលស្វែងរក',
      'search_ph': 'អាហារ គ្រឿងផ្សំ ប្រភេទ…',
      'empty_search':
          'វាយឈ្មោះអាហារ គ្រឿងផ្សំ ឬប្រភេទ។\nឧទាហរណ៍: ត្រី អង្ករ នំ…',
      'no_results': 'គ្មានលទ្ធផលសម្រាប់',
      'favorites': 'ចូលចិត្ត',
      'fav_sub': 'រូបមន្តដែលអ្នករក្សាទុក',
      'all': 'ទាំងអស់',
      'easy': 'ងាយស្រួល',
      'medium': 'មធ្យម',
      'spicy': 'ខ្លីញ',
      'fav_empty_t': 'មិនទាន់មានរូបមន្តចូលចិត្ត',
      'fav_empty_s': 'ចុចសញ្ញាបេះដូងលើរូបមន្ត\nដើម្បីរក្សាទុកនៅទីនេះ។',
      'review_count': '({n} ការវាយតម្លៃ)',
      'minutes': '{n} នាទី',
      'servings': 'សម្រាប់ {n} នាក់',
      'kcal': 'កាឡូរី',
      'carb': 'កាបូអ៊ីដ្រាត',
      'protein': 'ប្រូតេអ៊ីន',
      'fat': 'ខ្លាញ់',
      'tab_ing': 'គ្រឿងផ្សំ',
      'tab_steps': 'ជំហានចម្អិន',
      'tab_nutri': 'សារៈប្រាណ',
      'tab_reviews': 'ការវាយតម្លៃ',
      'ingredients': 'គ្រឿងផ្សំ',
      'spices': 'គ្រឿងទេស',
      'nut_kcal': 'កាឡូរី',
      'nut_carb': 'កាបូអ៊ីដ្រាត',
      'nut_prot': 'ប្រូតេអ៊ីន',
      'nut_fat': 'ខ្លាញ់',
      'nut_per': '* ប្រហែល ក្នុងមួយចំណែក។',
      'added_snack': 'បានបន្ថែមគ្រឿងផ្សំទៅក្នុងបញ្ជីទិញ 🛒',
      'add_shop': '+ ទិញ',
      'shopping': 'បញ្ជីទិញ',
      'done_all': 'បញ្ចប់ទាំងអស់',
      'shop_empty_t': 'បញ្ជីទិញទទេ',
      'shop_empty_s':
          'បន្ថែមគ្រឿងផ្សំពីទំព័ររូបមន្ត\nដោយប៊ូតុង «+ ទិញ»។',
      'shop_sub': 'ទិញគ្រឿងផ្សំសម្រាប់ថ្ងៃនេះ',
      'account': 'គណនីរបស់ខ្ញុំ',
      'stat_recipes': 'រូបមន្ត',
      'stat_shop': 'ទិញ',
      'stat_goal': 'គោលដៅ',
      'weekly': 'វឌ្ឍនភាពប្រចាំសប្តាហ៍',
      'weekly_sub': 'ចម្អិន 4 ពី 6 រូបមន្តមានសុខភាពសប្តាហ៍នេះ',
      'm_notif': 'ការជូនដំណឹង',
      'm_history': 'ប្រវត្តិចម្អិន',
      'm_downloads': 'ការទាញយក',
      'm_help': 'ជំនួយ និងគាំទ្រ',
      'm_privacy': 'ឯកជនភាព និងគោលការណ៍',
      'm_rate': 'វាយតម្លៃកម្មវិធី',
      'm_logout': 'ចាកចេញពីគណនី',
      'coming_soon': 'នឹងមានឆាប់ពេល',
      'days_ago': '2 ថ្ងៃមុន',
      'week_ago': '1 សប្តាហ៍មុន',
      'weeks_ago': '2 សប្តាហ៍មុន',
      'rev_1':
          'ឆ្ងាញ់ណាស់! គ្រឿងទេសត្រូវតម្លៃ កូនខ្ញុំហូរសារម្ដងហើយម្ដងទៀត។ រូបមន្តងាយធ្វើ ល្អសម្រាប់អ្នកចាប់ផ្តើម។',
      'rev_2':
          'លទ្ធផលដូចភោជនីយដ្ឋាន។ គន្លឹះភ្លើងតិចពេលចម្អិន ពិតជាមានប្រសើរ។ ឥឡូវក្លាយជារូបមន្តចូលចិត្តគ្រួសារ។',
      'rev_3':
          'ក្លិនខ្ទឹមសឆ្ងាញ់ណាស់។ ខ្ញុំបន្ថែមបិមភេទក្រហមមួយបន្តិច — ខ្លីញផ្អែម។ ណែនាំខ្លាំង!',
      'lang_title': 'ភាសា',
      'cat_rice': 'មុខម្ហូបអង្ករ',
      'cat_noodle': 'មី និងប៉ាស្តា',
      'cat_chicken': 'មុខម្ហូបមាន់',
      'cat_seafood': 'ម្ហូបសមុទ្រ',
      'cat_fish': 'មុខម្ហូបត្រី',
      'cat_dessert': 'អាហារផ្អែម',
      'cat_veg': 'បន្លែ',
      'cat_drink': 'ភេសជ្ជៈ',
      'cat_khmer': 'មុខម្ហូបខ្មែរ',
    },
    // ---------------- English ----------------
    en: {
      'nav_home': 'Home',
      'nav_search': 'Search',
      'nav_fav': 'Favorites',
      'nav_shop': 'Shopping',
      'nav_acc': 'Account',
      'greeting': 'Welcome 👋',
      'hi': 'Hi',
      'search_hint': 'What would you like to cook today?',
      'featured_badge': '🔥 Special Recipe Today',
      'cook_now': 'Cook Now',
      'featured_name': 'Amok Trey',
      'category': 'Categories',
      'popular_today': 'Popular Today',
      'continue_cooking': 'Continue Cooking',
      'step_of': 'Step {a} of {b}',
      'loading': 'Loading recipes…',
      'load_failed': "Couldn't load recipes. Check your connection and retry.",
      'no_notifications': 'No notifications yet',
      'see_all': 'See All',
      'min_short': '{n} min',
      'search': 'Search',
      'search_results': 'Search Results',
      'search_ph': 'Food, ingredient, category…',
      'empty_search':
          'Type a food, ingredient, or category.\nE.g.: amok, fish, rice…',
      'no_results': 'No results for',
      'favorites': 'Favorites',
      'fav_sub': 'Your saved recipes',
      'all': 'All',
      'easy': 'Easy',
      'medium': 'Medium',
      'spicy': 'Spicy',
      'fav_empty_t': 'No favorite recipes yet',
      'fav_empty_s': 'Tap the heart icon on a recipe\nto save it here.',
      'review_count': '({n} reviews)',
      'minutes': '{n} min',
      'servings': '{n} servings',
      'kcal': 'kcal',
      'carb': 'carbs',
      'protein': 'protein',
      'fat': 'fat',
      'tab_ing': 'Ingredients',
      'tab_steps': 'Cooking Steps',
      'tab_nutri': 'Nutrition',
      'tab_reviews': 'Reviews',
      'ingredients': 'Ingredients',
      'spices': 'Spices',
      'nut_kcal': 'Calories',
      'nut_carb': 'Carbohydrates',
      'nut_prot': 'Protein',
      'nut_fat': 'Fat',
      'nut_per': '* Per serving, approximate.',
      'added_snack': 'Ingredients added to Shopping List 🛒',
      'add_shop': '+ Shop',
      'shopping': 'Shopping List',
      'done_all': 'Mark All Done',
      'shop_empty_t': 'Shopping list is empty',
      'shop_empty_s':
          "Add ingredients from a recipe page\nwith the \"+ Shop\" button.",
      'shop_sub': "Let's shop today's ingredients",
      'account': 'My Account',
      'stat_recipes': 'Recipes',
      'stat_shop': 'Shopping',
      'stat_goal': 'Goal',
      'weekly': 'Weekly Progress',
      'weekly_sub': 'Cooked 4 of 6 healthy recipes this week',
      'm_notif': 'Notifications',
      'm_history': 'Cooking History',
      'm_downloads': 'Downloads',
      'm_help': 'Help & Support',
      'm_privacy': 'Privacy & Policy',
      'm_rate': 'Rate the App',
      'm_logout': 'Sign Out',
      'coming_soon': 'coming soon',
      'days_ago': '2 days ago',
      'week_ago': '1 week ago',
      'weeks_ago': '2 weeks ago',
      'rev_1':
          'So delicious! The spices are just right, my kids kept asking for more. Easy to follow, great for beginners.',
      'rev_2':
          'Restaurant-quality result. The low-heat cooking tip really helps. Now a family favorite.',
      'rev_3':
          'The garlic aroma is amazing. I added a few red chilies — spicy-sweet. Highly recommend!',
      'lang_title': 'Language',
      'cat_rice': 'Rice Dishes',
      'cat_noodle': 'Noodles & Pasta',
      'cat_chicken': 'Chicken Dishes',
      'cat_seafood': 'Seafood',
      'cat_fish': 'Fish Dishes',
      'cat_dessert': 'Desserts',
      'cat_veg': 'Vegetables',
      'cat_drink': 'Drinks',
      'cat_khmer': 'Khmer Food',
    },  };
}

/// Convenience: `context.t('key')`.
extension I18NContext on BuildContext {
  String t(String key, {String? n, String? a, String? b}) {
    final i18n = Provider.of<I18N>(this, listen: true);
    return i18n.t(key, n: n, a: a, b: b);
  }
}
