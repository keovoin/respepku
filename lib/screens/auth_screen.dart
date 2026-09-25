import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../i18n/localizations.dart';
import '../state/account_state.dart';
import '../theme.dart';

/// Login / registration: one-tap Telegram inside the Mini App, or email OTP
/// everywhere else. On success the profile (saved address) loads automatically.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  int _step = 0; // 0 = email, 1 = code
  bool _busy = false;
  String? _err;

  bool get _inTelegram => context.read<AccountState>().inTelegram;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() f) async {
    setState(() { _busy = true; _err = null; });
    try {
      await f();
      if (mounted && context.read<AccountState>().loggedIn) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => _err = e.toString());
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final acc = context.read<AccountState>();
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(title: Text(context.t('auth_title')), backgroundColor: C.bg,
          elevation: 0, foregroundColor: C.ink),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            if (_inTelegram) ...[
              FilledButton.icon(
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2AABEE),
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: _busy ? null : () => _run(() => acc.tgLogin(acc.initData)),
                icon: _busy
                    ? const SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.login),
                label: Text(context.t('tg_login'),
                    style: const TextStyle(height: 1.4,
                        fontWeight: FontWeight.w700, color: Colors.white)),
              ),
              const SizedBox(height: 16),
              Center(child: Text(context.t('or'),
                  style: const TextStyle(height: 1.4, color: C.muted))),
              const SizedBox(height: 16),
            ],
            if (_step == 0) ...[
              Text(context.t('auth_email_q'),
                  style: const TextStyle(height: 1.4, fontSize: 15,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: context.t('email_ph'),
                  filled: true, fillColor: C.card,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: C.line)),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: C.primary,
                    padding: const EdgeInsets.symmetric(vertical: 13)),
                onPressed: _busy ? null : () => _run(() async {
                      await acc.sendOtp(email: _emailCtrl.text.trim());
                      setState(() => _step = 1);
                    }),
                child: Text(context.t('send_code'),
                    style: const TextStyle(height: 1.4,
                        fontWeight: FontWeight.w700)),
              ),
            ] else ...[
              Text(context.t('code_sent_q'),
                  style: const TextStyle(height: 1.4, fontSize: 15,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(_emailCtrl.text,
                  style: const TextStyle(height: 1.4, fontSize: 12,
                      color: C.muted)),
              const SizedBox(height: 10),
              TextField(
                controller: _codeCtrl,
                keyboardType: TextInputType.number,
                maxLength: 8,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: context.t('code_ph'),
                  filled: true, fillColor: C.card,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: C.line)),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: C.primary,
                    padding: const EdgeInsets.symmetric(vertical: 13)),
                onPressed: _busy ? null : () => _run(() => acc.verifyOtp(
                    email: _emailCtrl.text.trim(),
                    code: _codeCtrl.text.trim())),
                child: Text(context.t('verify_login'),
                    style: const TextStyle(height: 1.4,
                        fontWeight: FontWeight.w700)),
              ),
              TextButton(
                  onPressed: () => setState(() => _step = 0),
                  child: Text(context.t('change_email'),
                      style: const TextStyle(height: 1.4, fontSize: 12))),
            ],
            if (_err != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(_err!.replaceFirst('AccountError: ', ''),
                    textAlign: TextAlign.center,
                    style: const TextStyle(height: 1.5, fontSize: 12.5,
                        color: C.red)),
              ),
            const SizedBox(height: 8),
            Text(context.t('auth_note'),
                textAlign: TextAlign.center,
                style: const TextStyle(height: 1.5, fontSize: 11.5,
                    color: C.muted)),
          ],
        ),
      ),
    );
  }
}

/// Tiny ThemeExtension carrying the Telegram initData handed over by JS.
/// (Unused — initData is read from SharedPreferences 'tg_init' instead.)

