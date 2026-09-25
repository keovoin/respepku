import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../data/store_keys.dart';

/// One recipe set (a buyable "one set" of a recipe).
class RecipeSet {
  final String id;
  final String mealId;
  final String nameEn;
  final String nameKm;
  final String descEn;
  final String descKm;
  final double price;
  final int stock;
  final String? imageUrl;
  final List<Map<String, dynamic>> ingredients;

  RecipeSet({
    required this.id,
    required this.mealId,
    required this.nameEn,
    required this.nameKm,
    required this.descEn,
    required this.descKm,
    required this.price,
    required this.stock,
    this.imageUrl,
    this.ingredients = const [],
  });

  String name(bool khmer) => khmer ? nameKm : nameEn;
  String desc(bool khmer) => khmer ? descKm : descEn;

  factory RecipeSet.fromJson(Map<String, dynamic> j) => RecipeSet(
        id: j['id'].toString(),
        mealId: (j['meal_id'] ?? '').toString(),
        nameEn: (j['name_en'] ?? '').toString(),
        nameKm: (j['name_km'] ?? j['name_en'] ?? '').toString(),
        descEn: (j['description_en'] ?? '').toString(),
        descKm: (j['description_km'] ?? '').toString(),
        price: (j['price'] as num).toDouble(),
        stock: (j['stock'] as num).toInt(),
        imageUrl: (j['image_url'] as String?)?.isEmpty == true
            ? null
            : j['image_url'] as String?,
        ingredients: (j['ingredients'] as List? ?? const [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(),
      );
}

class Banner {
  final String id;
  final String imageUrl;
  final String link;
  final String titleEn;
  final String titleKm;
  final String subtitleEn;
  final String subtitleKm;

  Banner({
    required this.id,
    required this.imageUrl,
    this.link = '',
    this.titleEn = '',
    this.titleKm = '',
    this.subtitleEn = '',
    this.subtitleKm = '',
  });

  String title(bool khmer) => khmer ? (titleKm.isNotEmpty ? titleKm : titleEn) : titleEn;
  String subtitle(bool khmer) =>
      khmer ? (subtitleKm.isNotEmpty ? subtitleKm : subtitleEn) : subtitleEn;

  factory Banner.fromJson(Map<String, dynamic> j) => Banner(
        id: j['id'].toString(),
        imageUrl: (j['image_url'] ?? '').toString(),
        link: (j['link'] ?? '').toString(),
        titleEn: (j['title_en'] ?? '').toString(),
        titleKm: (j['title_km'] ?? '').toString(),
        subtitleEn: (j['subtitle_en'] ?? '').toString(),
        subtitleKm: (j['subtitle_km'] ?? '').toString(),
      );
}

/// A line in the cart: one recipe set + quantity.
class CartLine {
  RecipeSet set;
  int qty;
  CartLine(this.set, this.qty);

  double get lineTotal => set.price * qty;
}

/// Client for the Sastra Fitmeal store (catalog, promo, cart, checkout).
///
/// Cart contents persist on-device via shared_preferences; every price is
/// re-quoted server-side at checkout time, so the cart can never be used to
/// underpay.
class ShopState extends ChangeNotifier {
  final List<CartLine> _cart = [];
  bool _loaded = false;
  bool _failed = false;
  List<RecipeSet> _sets = [];
  List<Banner> _banners = [];

  SharedPreferences? _prefs;
  static const _cartKey = 'shop_cart_v1';

  static ShopState? _instance;
  static ShopState get i => _instance ??= ShopState();

  // ---------- init ----------
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _restore();
    } catch (_) {}
    notifyListeners();
  }

  void _restore() {
    final raw = _prefs?.getString(_cartKey);
    if (raw == null) return;
    try {
      final list = (jsonDecode(raw) as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      for (final e in list) {
        // resolved against the catalog once it loads (_adopt)
        _pendingCart.add((e['set_id'].toString(), (e['qty'] as num).toInt()));
      }
    } catch (_) {}
  }

  final List<(String, int)> _pendingCart = [];

  // ---------- catalog ----------
  bool get loaded => _loaded;
  bool get failed => _failed;
  List<RecipeSet> get sets => _sets;
  List<Banner> get banners => _banners;

  /// KHR per 1 USD (from the server, editable in admin Settings).
  double usdRate = 4100;

  /// Approximate USD mirror of a KHR amount, for dual display.
  String usd(double khr) =>
      '\$${(khr / (usdRate <= 0 ? 4100 : usdRate)).toStringAsFixed(2)}';

  RecipeSet? setForMeal(String mealId) {
    for (final s in _sets) {
      if (s.mealId == mealId && s.stock > 0) return s;
    }
    return null;
  }

  Future<void> loadCatalog() async {
    try {
      final body = await http.post(
        Uri.parse(StoreKeys.shopUrl),
        headers: _headers(),
        body: jsonEncode({'action': 'catalog'}),
      );
      final j = jsonDecode(body.body) as Map<String, dynamic>;
      usdRate = (j['usd_rate'] as num?)?.toDouble() ?? 4100;
      final sets = (j['sets'] as List? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(RecipeSet.fromJson)
          .toList();
      _banners = (j['banners'] as List? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(Banner.fromJson)
          .toList();
      _adopt(sets);
      _loaded = true;
      _failed = false;
    } catch (_) {
      // offline — app keeps working without the shop
      _loaded = true;
      _failed = true;
    }
    notifyListeners();
  }

  void _adopt(List<RecipeSet> fresh) {
    // drop stale sets from the cart
    _cart.removeWhere((l) => fresh.where((s) => s.id == l.set.id).isEmpty);
    for (final s in fresh) {
      final line = _cart.where((l) => l.set.id == s.id).firstOrNull;
      if (line != null) line.set = s;
    }
    // apply pending (restored) cart lines
    for (final (id, qty) in _pendingCart) {
      final s = fresh.where((x) => x.id == id).firstOrNull;
      if (s != null && !_cart.any((l) => l.set.id == id)) {
        _cart.add(CartLine(s, qty));
      }
    }
    _pendingCart.clear();
    _sets = fresh;
  }

  // ---------- cart ----------
  List<CartLine> get cart => _cart;
  int get itemCount => _cart.fold(0, (n, l) => n + l.qty);
  double get subtotal => _cart.fold(0.0, (n, l) => n + l.lineTotal);
  bool get hasItems => _cart.isNotEmpty;

  bool inCart(String setId) => _cart.any((l) => l.set.id == setId);
  int cartQty(String setId) =>
      _cart.where((l) => l.set.id == setId).firstOrNull?.qty ?? 0;

  void addToCart(RecipeSet set) {
    final existing = _cart.where((l) => l.set.id == set.id).firstOrNull;
    if (existing == null) {
      _cart.add(CartLine(set, 1));
    } else {
      existing.qty = (existing.qty + 1).clamp(1, 99);
    }
    _persist();
    notifyListeners();
  }

  void setQty(RecipeSet set, int qty) {
    if (qty <= 0) {
      _cart.removeWhere((l) => l.set.id == set.id);
    } else {
      final existing = _cart.where((l) => l.set.id == set.id).firstOrNull;
      if (existing == null) {
        _cart.add(CartLine(set, qty.clamp(1, 99)));
      } else {
        existing.qty = qty.clamp(1, 99);
      }
    }
    _persist();
    notifyListeners();
  }

  void clear() {
    _cart.clear();
    _persist();
    notifyListeners();
  }

  void _persist() {
    try {
      _prefs?.setString(
          _cartKey,
          jsonEncode([
            for (final l in _cart)
              {'set_id': l.set.id, 'qty': l.qty}
          ]));
    } catch (_) {}
  }

  // ---------- server calls ----------
  Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        'apikey': StoreKeys.anonKey,
        'Authorization': 'Bearer ${StoreKeys.anonKey}',
      };

  Future<Map<String, dynamic>> _call(Map<String, dynamic> body) async {
    final r = await http.post(
      Uri.parse(StoreKeys.shopUrl),
      headers: _headers(),
      body: jsonEncode(body),
    );
    final j = jsonDecode(r.body) as Map<String, dynamic>;
    if (r.statusCode >= 400) {
      throw ShopError(j['error']?.toString() ?? 'Request failed.');
    }
    return j;
  }

  /// Validate a promo code. Returns promo json or throws.
  Future<Map<String, dynamic>> checkPromo(String code) async {
    return _call({'action': 'promo_check', 'code': code});
  }

  /// Quote the cart (server-side pricing). Returns the quote json.
  Future<Map<String, dynamic>> quote({String? promoCode}) async {
    final body = <String, dynamic>{
      'action': 'quote',
      'items': [for (final l in _cart) {'set_id': l.set.id, 'qty': l.qty}],
    };
    if (promoCode != null && promoCode.trim().isNotEmpty) {
      body['promo_code'] = promoCode.trim().toUpperCase();
    }
    return _call(body);
  }

  /// Place an order. Returns the order json (includes cutluy fields when
  /// payment_method == cutluy).
  Future<Map<String, dynamic>> checkout({
    required String name,
    required String phone,
    required String address,
    required String deliveryTime,
    required String paymentMethod,
    String? promoCode,
  }) async {
    final body = <String, dynamic>{
      'action': 'create_order',
      'customer': {
        'name': name,
        'phone': phone,
        'address': address,
        'delivery_time': deliveryTime,
      },
      'items': [for (final l in _cart) {'set_id': l.set.id, 'qty': l.qty}],
      'payment_method': paymentMethod,
    };
    if (promoCode != null && promoCode.trim().isNotEmpty) {
      body['promo_code'] = promoCode.trim().toUpperCase();
    }
    return _call(body);
  }

  /// Poll order status (CutLuy payments settle by webhook + poll).
  Future<Map<String, dynamic>> orderStatus(String orderRef) =>
      _call({'action': 'order_status', 'order_ref': orderRef});

  String money(double v) => '៛ ${v.toStringAsFixed(0)}';
}

class ShopError implements Exception {
  final String message;
  ShopError(this.message);
  @override
  String toString() => message;
}
