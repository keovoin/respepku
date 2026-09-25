import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../i18n/localizations.dart';
import '../state/app_state.dart';
import '../state/shop_state.dart';
import '../theme.dart';

/// Cart -> checkout (name/phone/address/time) -> COD or CutLuy QR.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key, this.promoHint});

  /// A promo code to pre-fill when arriving from a banner.
  final String? promoHint;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Phase: 0 = cart, 1 = details+payment, 2 = paying (QR/COD), 3 = done
  int _phase = 0;
  String? _err;

  // promo
  final _promoCtrl = TextEditingController();
  String? _promoCode;
  Map<String, dynamic>? _quote; // server quote incl. discount

  // customer form
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addrCtrl = TextEditingController();
  int _time = 0;

  // payment
  int _pay = 0; // 0 = COD, 1 = CutLuy

  // order result
  Map<String, dynamic>? _order;
  Timer? _poll;
  bool _paid = false;

  @override
  void initState() {
    super.initState();
    // prefill from the shopping/account profile if present
    final st = context.read<AppState>();
    _nameCtrl.text = st.customerName;
    _phoneCtrl.text = st.customerPhone;
    _time = st.customerTime;
    // banner deep-link: pre-fill the promo code
    final hint = widget.promoHint?.trim() ?? '';
    if (hint.isNotEmpty) {
      _promoCtrl.text = hint;
      _promoCode = hint;
    }
  }

  @override
  void dispose() {
    _poll?.cancel();
    _promoCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addrCtrl.dispose();
    super.dispose();
  }

  void _applyPromo() async {
    final code = _promoCtrl.text.trim();
    if (code.isEmpty) return;
    final s = context.read<ShopState>();
    setState(() => _err = null);
    try {
      final p = await s.checkPromo(code);
      if (p['ok'] != true) throw ShopError('bad');
      final q = await s.quote(promoCode: code);
      if (!mounted) return;
      setState(() {
        _promoCode = code;
        _quote = q;
        _err = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _promoCode = null;
        _quote = null;
        _err = context.t('promo_bad');
      });
    }
  }

  void _startCheckout() {
    final s = context.read<ShopState>();
    if (!s.hasItems) return;
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final addr = _addrCtrl.text.trim();
    if (name.isEmpty || phone.isEmpty || addr.isEmpty) {
      setState(() => _err = context.t('err_fill'));
      return;
    }
    final st = context.read<AppState>();
    st.saveCustomer(name, phone, _time);
    setState(() {
      _phase = 2;
      _err = null;
    });
    _place();
  }

  Future<void> _place() async {
    final s = context.read<ShopState>();
    final method = _pay == 0 ? 'cod' : 'cutluy';
    try {
      final o = await s.checkout(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        address: _addrCtrl.text.trim(),
        deliveryTime: _deliveryKey(),
        paymentMethod: method,
        promoCode: _promoCode,
      );
      if (!mounted) return;
      setState(() {
        _order = o;
        _paid = o['status'] == 'paid';
      });
      if (method == 'cutluy' && o['status'] != 'paid') {
        _poll = Timer.periodic(const Duration(seconds: 4), (_) => _check());
        _check();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _err = e.toString());
    }
  }

  Future<void> _check() async {
    final o = _order;
    if (o == null) return;
    final s = context.read<ShopState>();
    try {
      final st = await s.orderStatus(o['order_ref'].toString());
      if (!mounted) return;
      setState(() {
        _order = st;
        _paid = st['status'] == 'paid';
      });
      if (st['status'] == 'paid') {
        _poll?.cancel();
        setState(() => _phase = 3);
      }
    } catch (_) {}
  }

  String _deliveryKey() {
    const keys = ['asap', 'morning', 'lunch', 'dinner'];
    return keys[_time.clamp(0, 3)];
  }

  // ---------------- build ----------------
  @override
  Widget build(BuildContext context) {
    final s = context.watch<ShopState>();
    final kh = context.useKhmer;
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        backgroundColor: C.bg,
        elevation: 0,
        titleSpacing: 20,
        leading: _phase > 0 && _phase < 3
            ? const _Back()
            : IconButton(
                icon: const Icon(Icons.close, color: C.ink),
                onPressed: () => Navigator.pop(context)),
        title: Text(
            _phase == 3
                ? context.t('order_success')
                : context.t('cart'),
            style: const TextStyle(height: 1.4,
                fontSize: 18, fontWeight: FontWeight.w800, color: C.ink)),
        actions: [
          if (s.hasItems && _phase == 0)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: C.muted),
              onPressed: s.clear,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _phase == 0
          ? _buildCart(s, kh)
          : _phase == 1
              ? _buildCheckout(s, kh)
              : _phase == 2
                  ? _buildPaying(s, kh)
                  : _buildDone(s, kh),
    );
  }

  // ---------- phase 0: cart ----------
  Widget _buildCart(ShopState s, bool kh) {
    if (!s.hasItems) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_bag_outlined,
                size: 64, color: C.muted),
            const SizedBox(height: 16),
            Text(context.t('cart_empty_t'),
                style:
                    const TextStyle(height: 1.4, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(context.t('cart_empty_s'),
                textAlign: TextAlign.center,
                style: const TextStyle(height: 1.4, fontSize: 13, color: C.muted)),
          ],
        ),
      );
    }
    double subtotal = s.subtotal;
    double discount = _quote?['discount']?.toDouble() ?? 0;
    double total = (subtotal - discount).clamp(0.0, subtotal);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      children: [
        for (final l in s.cart)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: C.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: C.line),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: C.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.restaurant, color: C.primary, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.set.name(kh),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(height: 1.4,
                              fontSize: 14,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text(s.money(l.set.price),
                          style: const TextStyle(height: 1.4,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: C.primaryDark)),
                    ],
                  ),
                ),
                _Stepper(
                  value: l.qty,
                  onDec: () => s.setQty(l.set, l.qty - 1),
                  onInc: () => s.setQty(l.set, l.qty + 1),
                ),
              ],
            ),
          ),
        // promo
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: C.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: C.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.t('promo_code'),
                  style: const TextStyle(height: 1.4,
                      fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _promoCtrl,
                      textCapitalization: TextCapitalization.characters,
                      style:
                          const TextStyle(height: 1.4, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: context.t('promo_ph'),
                        hintStyle:
                            const TextStyle(height: 1.4, color: C.muted, fontSize: 13),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 13),
                        filled: true,
                        fillColor: C.bg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: C.line),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: C.line),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _applyPromo,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: C.primary,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        elevation: 0),
                    child: Text(context.t('apply'),
                        style: const TextStyle(height: 1.4,
                            fontSize: 13, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              if (_quote != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(context.t('promo_applied'),
                      style: const TextStyle(height: 1.4,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E9C55))),
                ),
              if (_err != null && _err!.contains(context.t('promo_bad')))
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_err!,
                      style: const TextStyle(height: 1.4,
                          fontSize: 12, color: Color(0xFFC0392B))),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // totals
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: C.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: C.line),
          ),
          child: Column(
            children: [
              _TotalRow(context.t('subtotal'), s.money(subtotal)),
              if (discount > 0)
                _TotalRow(context.t('discount'), '− ' + s.money(discount),
                    green: true),
              const Divider(height: 18),
              _TotalRow(context.t('total'), s.money(total), big: true),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => setState(() {
            _phase = 1;
            _err = null;
          }),
          style: ElevatedButton.styleFrom(
              backgroundColor: C.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 2),
          icon: const Icon(Icons.arrow_forward),
          label: Text(context.t('checkout'),
              style: const TextStyle(height: 1.4,
                  fontSize: 15, fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }

  // ---------- phase 1: details + payment ----------
  Widget _buildCheckout(ShopState s, bool kh) {
    double subtotal = s.subtotal;
    double discount = _quote?['discount']?.toDouble() ?? 0;
    double total = (subtotal - discount).clamp(0.0, subtotal);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
      children: [
        _SectionTitle(context.t('your_info')),
        _Field(
            label: context.t('full_name'),
            ctrl: _nameCtrl,
            icon: Icons.person_outline,
            kh: kh),
        _Field(
            label: context.t('phone'),
            ctrl: _phoneCtrl,
            icon: Icons.phone_outlined,
            kh: kh,
            numeric: true),
        _Field(
            label: context.t('address'),
            ctrl: _addrCtrl,
            icon: Icons.location_on_outlined,
            kh: kh,
            multiline: true),
        const SizedBox(height: 14),
        _SectionTitle(context.t('delivery_time')),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(4, (i) {
            final sel = _time == i;
            return GestureDetector(
              onTap: () => setState(() => _time = i),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? C.primarySoft : C.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: sel ? C.primary : C.line),
                ),
                child: Text(context.t('dt_${'asap morning lunch dinner'.split(' ')[i]}'),
                    style: TextStyle(height: 1.4,
                        fontSize: 13,
                        fontWeight:
                            sel ? FontWeight.w800 : FontWeight.w500,
                        color: sel ? C.primaryDark : C.ink)),
              ),
            );
          }),
        ),
        const SizedBox(height: 18),
        _SectionTitle(context.t('payment')),
        _PayOption(
          icon: Icons.money_outlined,
          title: context.t('pay_cod'),
          sel: _pay == 0,
          onTap: () => setState(() => _pay = 0),
        ),
        const SizedBox(height: 8),
        _PayOption(
          icon: Icons.qr_code_2,
          title: context.t('pay_cutluy'),
          sel: _pay == 1,
          onTap: () => setState(() => _pay = 1),
        ),
        const SizedBox(height: 16),
        if (_err != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(_err!,
                style:
                    const TextStyle(height: 1.4, fontSize: 13, color: Color(0xFFC0392B))),
          ),
        ElevatedButton.icon(
          onPressed: _startCheckout,
          style: ElevatedButton.styleFrom(
              backgroundColor: C.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 2),
          icon: const Icon(Icons.lock_outline, size: 18),
          label: Text(
              '${context.t('checkout')} — ${s.money(total)}',
              style: const TextStyle(height: 1.4,
                  fontSize: 15, fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }

  // ---------- phase 2: paying ----------
  Widget _buildPaying(ShopState s, bool kh) {
    final o = _order;
    final isCod = _pay == 0;
    final data = (o?['qr_string'] ?? '').toString();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (o == null)
          const Padding(
            padding: EdgeInsets.all(40),
            child: Center(
                child: CircularProgressIndicator(color: C.primary)),
          )
        else if (isCod)
          ...[
            const Icon(Icons.money, size: 72, color: C.amber),
            const SizedBox(height: 16),
            Text(context.t('order_placed'),
                textAlign: TextAlign.center,
                style: const TextStyle(height: 1.4,
                    fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Text(context.t('cod_note'),
                textAlign: TextAlign.center,
                style: const TextStyle(height: 1.4, fontSize: 13, color: C.muted)),
            const SizedBox(height: 20),
            _OrderCard(o, kh: kh, money: s.money),
          ]
        else
          ...[
            Text(context.t('qr_scan'),
                textAlign: TextAlign.center,
                style:
                    const TextStyle(height: 1.4, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: C.line),
              ),
              child: Column(
                children: [
                  Text('${context.t('total')} ${s.money((o['total'] ?? 0).toDouble())}',
                      style: const TextStyle(height: 1.4,
                          fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 14),
                  if (data.isNotEmpty)
                    QrImageView(
                      data: data,
                      version: QrVersions.auto,
                      size: 220,
                      gapless: true,
                    )
                  else
                    const SizedBox(
                        height: 160,
                        child: Center(
                            child: CircularProgressIndicator(
                                color: C.primary))),
                  const SizedBox(height: 12),
                  Text(_paid ? context.t('paid_ok') : context.t('qr_wait'),
                      style: TextStyle(height: 1.4,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _paid
                              ? const Color(0xFF2E9C55)
                              : C.muted)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _OrderCard(o, kh: kh, money: s.money),
          ],
      ],
    );
  }

  // ---------- phase 3: done ----------
  Widget _buildDone(ShopState s, bool kh) {
    final o = _order ?? {};
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                  color: Color(0xFF2E9C55), shape: BoxShape.circle),
              child: const Icon(Icons.check, size: 52, color: Colors.white),
            ),
            const SizedBox(height: 18),
            Text(context.t('order_success'),
                style: const TextStyle(height: 1.4,
                    fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(context.t('order_success_s'),
                textAlign: TextAlign.center,
                style: const TextStyle(height: 1.4, fontSize: 13, color: C.muted)),
            const SizedBox(height: 20),
            _OrderCard(o, kh: kh, money: s.money),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                s.clear();
                Navigator.popUntil(context, (r) => r.settings.name == '/');
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: C.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16))),
              icon: const Icon(Icons.home_outlined),
              label: Text(context.t('back_home'),
                  style: const TextStyle(height: 1.4,
                      fontSize: 14, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> o;
  final bool kh;
  final String Function(double) money;
  const _OrderCard(this.o, {required this.kh, required this.money});

  @override
  Widget build(BuildContext context) {
    final ref = o['order_ref']?.toString() ?? '';
    final total = (o['total'] ?? 0).toDouble();
    final method = o['payment_method']?.toString() ?? '';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.line),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.t('order_ref'),
                  style: const TextStyle(height: 1.4, fontSize: 12, color: C.muted)),
              Text(ref,
                  style: const TextStyle(height: 1.4,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'monospace')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.t('total'),
                  style: const TextStyle(height: 1.4, fontSize: 12, color: C.muted)),
              Text(money(total),
                  style: const TextStyle(height: 1.4,
                      fontSize: 14, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.t('payment'),
                  style: const TextStyle(height: 1.4, fontSize: 12, color: C.muted)),
              Text(method == 'cod'
                  ? context.t('pay_cod')
                  : context.t('pay_cutluy'),
                  style: const TextStyle(height: 1.4,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: C.primaryDark)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 4),
        child: Text(text,
            style: const TextStyle(height: 1.4,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: C.primaryDark)),
      );
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final IconData icon;
  final bool kh;
  final bool numeric;
  final bool multiline;
  const _Field(
      {required this.label,
      required this.ctrl,
      required this.icon,
      this.kh = false,
      this.numeric = false,
      this.multiline = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(height: 1.4, fontSize: 12, color: C.muted)),
          const SizedBox(height: 5),
          TextField(
            controller: ctrl,
            keyboardType: numeric ? TextInputType.phone : TextInputType.text,
            minLines: multiline ? 2 : 1,
            maxLines: multiline ? 3 : 1,
            style: const TextStyle(height: 1.4, fontSize: 14),
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: Icon(icon, size: 20, color: C.muted),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 14),
              filled: true,
              fillColor: C.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(color: C.line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(color: C.line),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PayOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool sel;
  final VoidCallback onTap;
  const _PayOption(
      {required this.icon,
      required this.title,
      required this.sel,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: sel ? C.primarySoft : C.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: sel ? C.primary : C.line),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: sel ? C.primary : C.muted),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title,
                  style: TextStyle(height: 1.4,
                      fontSize: 14,
                      fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
                      color: sel ? C.primaryDark : C.ink)),
            ),
            Icon(
                sel
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: sel ? C.primary : C.muted),
          ],
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool big;
  final bool green;
  const _TotalRow(this.label, this.value, {this.big = false, this.green = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(height: 1.4,
                fontSize: big ? 15 : 13,
                fontWeight: big ? FontWeight.w800 : FontWeight.w600,
                color: big ? C.ink : C.muted)),
        Text(value,
            style: TextStyle(height: 1.4,
                fontSize: big ? 17 : 14,
                fontWeight: FontWeight.w800,
                color: green
                    ? const Color(0xFF2E9C55)
                    : (big ? C.primaryDark : C.ink))),
      ],
    );
  }
}

class _Stepper extends StatelessWidget {
  final int value;
  final VoidCallback onDec;
  final VoidCallback onInc;
  const _Stepper({required this.value, required this.onDec, required this.onInc});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepBtn(icon: Icons.remove, onTap: onDec),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('$value',
              style: const TextStyle(height: 1.4,
                  fontSize: 14,
                  fontWeight: FontWeight.w800)),
        ),
        _StepBtn(icon: Icons.add, onTap: onInc),
      ],
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _StepBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: C.primarySoft,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, size: 16, color: C.primary),
      ),
    );
  }
}

class _Back extends StatelessWidget {
  const _Back();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new, color: C.ink, size: 20),
      onPressed: () => Navigator.pop(context),
    );
  }
}
