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
      'step_of': 'ជំហានទី {a} នៃ {b}',
      'loading': 'កំពុងផ្ទុករូបមន្ត…',
      'load_failed': 'មិនអាចផ្ទុករូបមន្តបានទេ។ សូមពិនិត្យការតភ្ជាប់ រួចសាកល្បងម្តងទៀត។',
      'no_notifications': 'មិនទាន់មានការជូនដំណឹង',
      'see_all': 'មើលទាំងអាស់',
      'min_short': 'នាទី {n}',
      'search': 'ស្វែងរក',
      'search_results': 'លទ្ធផលស្វែងរក',
      'search_ph': 'អាហារ គ្រឿងផ្សំ ប្រភេទ…',
      'empty_search': 'វាយឈ្មោះអាហារ គ្រឿងផ្សំ ឬប្រភេទ។\nឧទាហរណ៍: ត្រី អង្ករ នំ…',
      'no_results': 'គ្មានលទ្ធផលសម្រាប់',
      'favorites': 'ចូលចិត្ត',
      'fav_sub': 'រូបមន្តដេលអ្នករក្សាទុក',
      'all': 'ទាំងអាស់',
      'easy': 'ងាយស្រួល',
      'medium': 'មធ្យម',
      'spicy': 'ហិរ',
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
      'tab_nutri': 'គុណតម្លៃអាហារ',
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
      'done_all': 'បញ្ចប់ទាំងអាស់',
      'shop_empty_t': 'បញ្ជីទិញទទេ',
      'shop_empty_s': 'បន្ថែមគ្រឿងផ្សំ ពីទំព័ររូបមន្ត\nដោយប៊ូតុង «+ ទិញ»។',
      'shop_sub': 'ទិញគ្រឿងផ្សំសម្រាប់ថ្ងៃនេះ',
      'account': 'គណនីរបាស់ខ្ញុំ',
      'stat_recipes': 'រូបមន្ត',
      'stat_shop': 'ទិញ',
      'stat_goal': 'គោលដៅ',
      'weekly': 'វឌ្ឍនភាពប្រចាំសប្តាហ៍',
      'weekly_sub': 'ចម្អិនបាន 4 នៃ 6 រូបមន្តសុខភាព នៅក្នុងសប្តាហ៍នេះ',
      'm_notif': 'ការជូនដំណឹង',
      'm_history': 'ប្រវត្តិចម្អិន',
      'm_downloads': 'ការទាញយក',
      'm_help': 'ជំនួយ និងគាំទ្រ',
      'm_privacy': 'ឯកជនភាព និងគោលការណ៍',
      'm_rate': 'វាយតម្លៃកម្មវិធី',
      'm_logout': 'ចាកចេញ ពីគណនី',
      'coming_soon': 'នឹងមានឆាប់ៗនេះ',
      'days_ago': '2 ថ្ងៃមុន',
      'week_ago': '1 សប្តាហ៍មុន',
      'weeks_ago': '2 សប្តាហ៍មុន',
      'rev_1': 'ឆ្ងាញ់ណាស់! គ្រឿងទេសត្រូវតម្លៃ កូនខ្ញុំសុំម្តងហើយម្តងទៀត។ រូបមន្តងាយធ្វើ ល្អសម្រាប់អ្នកចាប់ផ្តើម។',
      'rev_2': 'លទ្ធផលដូចភោជនីយដ្ឋាន។ គន្លឹះភ្លើងតិចពេលចម្អិន ពិតជាមានប្រសើរ។ ឥឡូវក្លាយជារូបមន្តចូលចិត្តគ្រួសារ។',
      'rev_3': 'ក្លិនខ្ទឹមសឆ្ងាញ់ណាស់។ ខ្ញុំបន្ថែមប៉េងប៉ោះក្រហមមួយបន្តិច — ហិរផ្អែម។ ណែនាំខ្លាំង!',
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
      'cat_other': 'មុខម្ហូបផ្សេងៗ',
      'store_section': 'ហាង Sastra Fitmeal',
      'store_sub': 'ទិញកញ្ចប់គ្រឿងផ្សំសរុប សម្រាប់រូបមន្តណាមួយ',
      'buy_set': 'ទិញ ១ កញ្ចប់',
      'in_cart': 'ក្នុងកន្ត្រក ({n})',
      'cart': 'កន្ត្រកទិញ',
      'cart_empty_t': 'កន្ត្រករបាស់អ្នកទទេ',
      'cart_empty_s': 'ចុច «ទិញ ១ កញ្ចប់» នៅទំព័ររូបមន្ត\nដើម្បីបន្ថែមកញ្ចប់គ្រឿងផ្សំសរុប។',
      'subtotal': 'សរុបរង',
      'promo_code': 'កូដបញ្ចុះតម្លៃ',
      'promo_ph': 'ឧ. FITMEAL15',
      'apply': 'អនុវត្ត',
      'promo_applied': '✓ បានអនុវត្តការបញ្ចុះតម្លៃ',
      'promo_bad': 'កូដមិនត្រឹមត្រូវ ឬផុតកំណត់',
      'discount': 'បញ្ចុះតម្លៃ',
      'total': 'សរុប',
      'checkout': 'បន្តទៅការបង់ប្រាក់',
      'your_info': 'ព័ត៌មានរបាស់អ្នក',
      'full_name': 'ឈ្មោះពេញ',
      'phone': 'លេខទូរស័ព្ទ',
      'address': 'អាសយដ្ឋានដឹកជញ្ជូន',
      'delivery_time': 'ពេលវេលាដឹកជញ្ជូន',
      'dt_asap': 'ឥឡូវនេះ (ASAP)',
      'dt_morning': 'ព្រឹក (8–11)',
      'dt_lunch': 'ថ្ងៃត្រង់ (11–14)',
      'dt_dinner': 'រាត្រី (17–20)',
      'payment': 'វិធីបង់ប្រាក់',
      'pay_cod': 'បង់ប្រាក់ពេលដឹក (COD)',
      'pay_cutluy': 'បង់ដោយ QR (CutLuy)',
      'qr_scan': 'សូមស្កេន QR code នេះដោយកម្មវិធី CutLuy / ABA ឬ e-wallet ណាមួយ ដើម្បីបង់ប្រាក់',
      'qr_wait': 'កំពុងរង់ចាំការបង់ប្រាក់…',
      'paid_ok': '✓ បានបញ្ជាក់ការបង់ប្រាក់!',
      'order_placed': 'ការបញ្ជាទិញរបាស់អ្នកបានចុះបញ្ជី ✓',
      'order_ref': 'លេខកំណត់ការបញ្ជា',
      'cod_note': 'សូមរៀបចំប្រាក់ — អ្នកដឹកនឹងទំនាក់ទំនងអ្នកតាមពេលវេលាកំណត់។',
      'back_home': 'ត្រឡប់ទៅទំព័រដើម',
      'stock_left': 'ស្តុកសល់ {n} កញ្ចប់',
      'sold_out': 'អាស់ស្តុក',
      'err_fill': 'សូមបំពេញឈ្មោះ លេខទូរស័ព្ទ និងអាសយដ្ឋាន',
      'err_server': 'មិនអាចទំនាក់ទំនងហាងបានទេ។ សូមពិនិត្យការតភ្ជាប់។',
      'price_set': 'តម្លៃក្នុងមួយកញ្ចប់',
      'order_success': 'សូមអរគុណ! 🎉',
      'order_success_s': 'ការបញ្ជាទិញរបាស់អ្នក យើងនឹងទំនាក់ទំនងតាមទូរស័ព្ទដើម្បីបញ្ជាក់ការដឹកជញ្ជូន។',
      'tab_buy': 'ទិញ',
      'stock': 'ស្តុក',
      'not_sellable': 'កញ្ចប់រូបមន្តនេះមិនអាចទិញបានឡើយ បច្ចុប្បន្ន។',
      'in_set': 'មានអ្វីខ្លះនៅក្នុងកញ្ចប់នេះ',
      'go_cart': 'ទៅកាន់កន្ត្រក',
      'usd_note': 'ប្រហែលលជាដុល្លារ',
      'guest_note': 'អ្នកទស្សនា — បំពេញព័ត៌មានពេលបញ្ជាទិញ',
      'stat_orders': 'ការបញ្ជាទិញ',
      'weekly_sub_n': 'ចម្អិនបាន {n} នៃ 6 រូបមន្ត នៅក្នុងសប្តាហ៍នេះ',
      'no_orders_yet': 'មិនទាន់មានការបញ្ជាទិញឡើយ\nការបញ្ជាទិញរបាស់អ្នកនឹងបង្ហាញនៅទីនេះ។',
      'help_body': 'ទំនាក់ទំនងផ្នែកជំនួយ Sastra Fitmeal ជានិច្ច ពេល 8:00 ដល់ 20:00\nយើងនឹងឆ្លើយតបក្នុងរយៈពេល 24 ម៉ោង។',
      'privacy_body': 'យើងរក្សាទុកតែព័ត៌មានដេលអ្នកផ្តល់ឱ្យ (ឈ្មោះ ទូរស័ព្ទ អាសយដ្ឋាន)\nសម្រាប់ដឹកជញ្ជូនការបញ្ជាទិញប៉ុណ្ណោះ។ រូបមន្ត ការចូលចិត្ត និង\nបញ្ជីទិញរបាស់អ្នកត្រូវបានរក្សាទុកនៅលើទូរស័ព្ទរបាស់អ្នកតែប៉ុណ្ណោះ។\nយើងមិនចែករំលែកព័ត៌មានជាមួយភាគីទីបីឡើយ។',
      'rate_title': 'វាយតម្លៃ Sastra Fitmeal',
      'rate_sub': 'ការវាយតម្លៃរបាស់អ្នកជួយយើងឱ្យកាន់តែប្រសើរ',
      'rate_thanks': 'អរគុណសម្រាប់ការវាយតម្លៃ!',
      'logout_confirm': 'បញ្ជាក់ការចាកចេញ ពីព័ត៌មានលិបិក្រម?\nរូបមន្តចូលចិត្ត និង្ទបញ្ជីទិញនៅតែមាន។',
      'cancel': 'បោះបង់',
      'logout_done': 'បានចាកចេញដោយសុវត្ថិភាព ✓',
      'mark_cooked': 'សម្គាល់ថាចម្អិនរួចរាល់',
      'cooked_ok': '✓ ចម្អិនរួចរាល់',
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
      'cat_other': 'Other Dishes',
      // ---------------- Store (e-commerce) ----------------
      'store_section': 'Sastra Fitmeal Store',
      'store_sub': 'Buy a full ingredient set for any recipe',
      'buy_set': 'Buy 1 Set',
      'in_cart': 'In cart ({n})',
      'cart': 'Cart',
      'cart_empty_t': 'Your cart is empty',
      'cart_empty_s': 'Tap "Buy 1 Set" on a recipe page\nto add a full ingredient set.',
      'subtotal': 'Subtotal',
      'promo_code': 'Promo code',
      'promo_ph': 'e.g. FITMEAL15',
      'apply': 'Apply',
      'promo_applied': '✓ Discount applied',
      'promo_bad': 'Invalid or expired code',
      'discount': 'Discount',
      'total': 'Total',
      'checkout': 'Proceed to Payment',
      'your_info': 'Your Info',
      'full_name': 'Full name',
      'phone': 'Phone number',
      'address': 'Delivery address',
      'delivery_time': 'Delivery time',
      'dt_asap': 'As soon as possible',
      'dt_morning': 'Morning (8–11)',
      'dt_lunch': 'Lunch (11–14)',
      'dt_dinner': 'Dinner (17–20)',
      'payment': 'Payment Method',
      'pay_cod': 'Cash on Delivery (COD)',
      'pay_cutluy': 'Pay by QR (CutLuy)',
      'qr_scan': 'Scan this QR code with CutLuy / ABA or any e-wallet app to pay',
      'qr_wait': 'Waiting for payment…',
      'paid_ok': '✓ Payment confirmed!',
      'order_placed': 'Your order has been placed ✓',
      'order_ref': 'Order ID',
      'cod_note': 'Please prepare the cash — our rider will contact you at the given time.',
      'back_home': 'Back to Home',
      'stock_left': '{n} sets left',
      'sold_out': 'Sold Out',
      'err_fill': 'Please fill in name, phone and address',
      'err_server': 'Could not reach the store. Check your connection.',
      'price_set': 'Set price',
      'order_success': 'Thank you! 🎉',
      'order_success_s': 'We will contact you by phone to confirm delivery.',
      'tab_buy': 'Buy',
      'stock': 'Stock',
      'not_sellable': 'This recipe set is not available for purchase right now.',
      'in_set': "What's inside this set",
      'go_cart': 'Go to Cart',
      'usd_note': 'approx. USD',
    },  };
}

/// Convenience: `context.t('key')`.
extension I18NContext on BuildContext {
  String t(String key, {String? n, String? a, String? b}) {
    final i18n = Provider.of<I18N>(this, listen: true);
    return i18n.t(key, n: n, a: a, b: b);
  }

  /// True when the active locale is Khmer (meal content is localized).
  bool get useKhmer {
    final i18n = Provider.of<I18N>(this, listen: true);
    return i18n.locale == I18N.kh;
  }
}

/// Maps a raw meal category (local_db.dart) to a translatable `cat_*` key.
String catKey(String? category) {
  switch ((category ?? '').toLowerCase()) {
    case 'chicken':
      return 'cat_chicken';
    case 'seafood':
      return 'cat_seafood';
    case 'dessert':
      return 'cat_dessert';
    case 'veg':
    case 'vegan':
    case 'vegetarian':
    case 'side':
      return 'cat_veg';
    case 'beef':
    case 'pork':
    case 'miscellaneous':
    default:
      return 'cat_other';
  }
}
