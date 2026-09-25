import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../data/store_keys.dart';

/// A verified customer session + saved delivery profile.
class AccountState extends ChangeNotifier {
  String? accessToken;
  String? refreshToken;
  String? userId;
  String? userEmail;

  String name = '';
  String phone = '';
  String address = '';
  String deliveryTime = '';
  String? tgName;

  SharedPreferences? _prefs;
  static const _accUrl =
      'https://swxpjxdzkwdilgkbbrnz.supabase.co/functions/v1/meal-account';

  /// Telegram initData captured at boot (empty outside the Mini App).
  String initData = '';

  bool get inTelegram => initData.isNotEmpty;
  bool get loggedIn => accessToken != null && userId != null;

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (_) {
      _prefs = null;
    }
    final p = _prefs;
    if (p != null) {
      accessToken = p.getString('acc_at');
      refreshToken = p.getString('acc_rt');
      userId = p.getString('acc_uid');
      userEmail = p.getString('acc_email');
      name = p.getString('prof_name') ?? '';
      phone = p.getString('prof_phone') ?? '';
      address = p.getString('prof_addr') ?? '';
      deliveryTime = p.getString('prof_time') ?? '';
      tgName = p.getString('prof_tgname');
      if (accessToken != null) {
        notifyListeners();
        // refresh the profile from the server in the background
        loadProfile();
      }
    }
    // Telegram Mini App: one-tap auto-login with the initData index.html stored.
    initData = p?.getString('tg_init') ?? '';
    if (!loggedIn && initData.isNotEmpty) {
      try {
        await tgLogin(initData);
      } catch (_) {}
      await p?.remove('tg_init');
    }
  }

  Map<String, String> get _h => {
        'Content-Type': 'application/json',
        'apikey': StoreKeys.anonKey,
        'Authorization': 'Bearer ${StoreKeys.anonKey}',
      };

  Future<Map<String, dynamic>> _call(Map<String, dynamic> body) async {
    final r = await http.post(Uri.parse(_accUrl),
        headers: _h, body: jsonEncode(body));
    final j = jsonDecode(r.body) as Map<String, dynamic>;
    if (r.statusCode >= 400) {
      throw AccountError(j['error']?.toString() ?? 'Request failed.');
    }
    return j;
  }

  Future<void> sendOtp({String? email, String? phone}) =>
      _call({'action': 'otp_send', if (email != null) 'email': email,
        if (phone != null) 'phone': phone});

  Future<void> verifyOtp({String? email, String? phone, required String code}) async {
    final j = await _call({'action': 'otp_verify',
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone, 'code': code});
    _adoptSession(j['session'] as Map<String, dynamic>);
    await loadProfile();
  }

  Future<void> tgLogin(String initData) async {
    final j = await _call({'action': 'tg_login', 'init_data': initData});
    _adoptSession(j['session'] as Map<String, dynamic>);
    tgName = j['tg_name']?.toString();
    await _prefs?.setString('prof_tgname', tgName ?? '');
    await loadProfile();
  }

  void _adoptSession(Map<String, dynamic> s) {
    accessToken = s['access_token'];
    refreshToken = s['refresh_token'];
    final u = s['user'] as Map<String, dynamic>;
    userId = u['id']?.toString();
    userEmail = u['email']?.toString();
    final p = _prefs;
    if (p != null) {
      p.setString('acc_at', accessToken ?? '');
      p.setString('acc_rt', refreshToken ?? '');
      p.setString('acc_uid', userId ?? '');
      p.setString('acc_email', userEmail ?? '');
    }
    notifyListeners();
  }

  Future<void> loadProfile() async {
    if (!loggedIn) return;
    try {
      final j = await _call({'action': 'account.get', 'token': accessToken});
      final pr = j['profile'] as Map<String, dynamic>;
      name = pr['name']?.toString() ?? name;
      phone = pr['phone']?.toString() ?? phone;
      address = pr['address']?.toString() ?? address;
      deliveryTime = pr['delivery_time']?.toString() ?? deliveryTime;
      _persistProfile();
      notifyListeners();
    } catch (_) {}
  }

  Future<List<Map<String, dynamic>>> loadOrders() async {
    if (!loggedIn) return const [];
    final j = await _call({'action': 'account.orders', 'token': accessToken});
    return (j['orders'] as List? ?? const [])
        .cast<Map<String, dynamic>>();
  }

  /// Save the entered delivery info as the account's defaults.
  Future<void> saveProfile({String? name, String? phone, String? address,
      String? deliveryTime}) async {
    if (!loggedIn) return;
    this.name = name ?? this.name;
    this.phone = phone ?? this.phone;
    this.address = address ?? this.address;
    this.deliveryTime = deliveryTime ?? this.deliveryTime;
    _persistProfile();
    notifyListeners();
    await _call({'action': 'account.save', 'token': accessToken,
      'name': this.name, 'phone': this.phone, 'address': this.address,
      'delivery_time': this.deliveryTime});
  }

  void _persistProfile() {
    final p = _prefs;
    if (p == null) return;
    p.setString('prof_name', name);
    p.setString('prof_phone', phone);
    p.setString('prof_addr', address);
    p.setString('prof_time', deliveryTime);
  }

  void logout() {
    accessToken = null;
    refreshToken = null;
    userId = null;
    userEmail = null;
    final p = _prefs;
    p?.remove('acc_at');
    p?.remove('acc_rt');
    p?.remove('acc_uid');
    p?.remove('acc_email');
    notifyListeners();
  }
}

class AccountError implements Exception {
  final String message;
  AccountError(this.message);
  @override
  String toString() => message;
}
