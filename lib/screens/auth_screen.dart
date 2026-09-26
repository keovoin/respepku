import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../i18n/localizations.dart';
import '../state/account_state.dart';
import '../theme.dart';

/// Register / login. Inside the Telegram Mini App: one-tap continue.
/// Everywhere else: phone (SMS OTP when Twilio is wired) or email code.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  int _method = 0; // 0 phone, 1 email
  bool _sent = false;
  bool _busy = false;
  String? _err;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() f) async {
    setState(() { _busy = true; _err = null; });
    try {
      await f();
      if (mounted && context.read<AccountState>().loggedIn) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        final s = e.toString();
        // Never show raw stack/network details to the user.
        final isNet = s.contains('ClientException') ||
            s.contains('SocketException') ||
            s.contains('HandshakeException') ||
            s.contains('Failed host lookup');
        setState(() => _err = isNet
            ? context.t('err_server')
            : s.replaceFirst('AccountError: ', ''));
      }
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _send() => _run(() async {
        if (_method == 0) {
          await context
              .read<AccountState>()
              .sendOtp(phone: _phoneCtrl.text.trim());
        } else {
          await context
              .read<AccountState>()
              .sendOtp(email: _emailCtrl.text.trim());
        }
        if (mounted) setState(() => _sent = true);
      });

  Future<void> _verify() => _run(() async {
        final acc = context.read<AccountState>();
        await acc.verifyOtp(
          phone: _method == 0 ? _phoneCtrl.text.trim() : null,
          email: _method == 1 ? _emailCtrl.text.trim() : null,
          code: _codeCtrl.text.trim(),
        );
      });

  @override
  Widget build(BuildContext context) {
    final acc = context.watch<AccountState>();
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
          title: Text(context.t('auth_title'),
              style: const TextStyle(height: 1.4,
                  fontSize: 17, fontWeight: FontWeight.w800)),
          backgroundColor: C.bg,
          elevation: 0,
          foregroundColor: C.ink),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
          children: [
            if (acc.inTelegram) ...[
              FilledButton.icon(
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2AABEE),
                    padding: const EdgeInsets.symmetric(vertical: 15)),
                onPressed: _busy ? null : () => _run(() => acc.tgLogin(acc.initData)),
                icon: const Icon(Icons.login, color: Colors.white),
                label: Text(context.t('tg_login'),
                    style: const TextStyle(height: 1.4,
                        fontWeight: FontWeight.w700, color: Colors.white)),
              ),
              const SizedBox(height: 14),
              Row(children: [
                const Expanded(child: Divider(color: C.line)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(context.t('or'),
                      style: const TextStyle(height: 1.4, color: C.muted)),
                ),
                const Expanded(child: Divider(color: C.line)),
              ]),
              const SizedBox(height: 14),
            ],
            // ---- method switch (phone / email) ----
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: C.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: C.line)),
              child: Row(
                children: [
                  _methodTab(0, Icons.phone_outlined, context.t('phone'),
                      context.t('auth_phone_q')),
                  _methodTab(1, Icons.mail_outline, context.t('email'),
                      context.t('auth_email_q')),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (!_sent) ...[
              if (_method == 0)
                _input(_phoneCtrl, context.t('phone_ph'),
                    TextInputType.phone)
              else
                _input(_emailCtrl, context.t('email_ph'),
                    TextInputType.emailAddress),
              const SizedBox(height: 12),
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: C.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: _busy ? null : _send,
                child: Text(context.t('send_code'),
                    style: const TextStyle(height: 1.4,
                        fontWeight: FontWeight.w700)),
              ),
            ] else ...[
              Text(
                  _method == 0
                      ? context.t('code_sent_phone_q')
                      : context.t('code_sent_q'),
                  style: const TextStyle(height: 1.5,
                      fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _input(_codeCtrl, context.t('code_ph'), TextInputType.number,
                  max: 8),
              const SizedBox(height: 12),
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: C.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: _busy ? null : _verify,
                child: Text(context.t('verify_login'),
                    style: const TextStyle(height: 1.4,
                        fontWeight: FontWeight.w700)),
              ),
              TextButton(
                  onPressed: () => setState(() => _sent = false),
                  child: Text(
                      _method == 0
                          ? context.t('change_phone')
                          : context.t('change_email'),
                      style: const TextStyle(height: 1.4, fontSize: 12))),
            ],
            if (_err != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(_err!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        height: 1.5, fontSize: 12.5, color: C.red)),
              ),
            const SizedBox(height: 10),
            Text(context.t('auth_note'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    height: 1.5, fontSize: 11.5, color: C.muted)),
          ],
        ),
      ),
    );
  }

  Widget _methodTab(int idx, IconData icon, String label, String hint) {
    final on = _method == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() { _method = idx; _sent = false; _err = null; }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: on ? C.primarySoft : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: on ? C.primary : C.muted),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(height: 1.4,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: on ? C.primary : C.muted)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(TextEditingController c, String hint, TextInputType type,
      {int? max}) {
    return TextField(
      controller: c,
      keyboardType: type,
      maxLength: max,
      decoration: InputDecoration(
        hintText: hint,
        counterText: '',
        filled: true,
        fillColor: C.card,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: C.line)),
      ),
    );
  }
}
