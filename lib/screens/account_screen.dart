import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        backgroundColor: C.bg,
        elevation: 0,
        titleSpacing: 20,
        title: const Text('Akun Saya',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: C.ink)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            // ---- Profile card ----
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF9A3D), Color(0xFFFF7A00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: C.primary.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6)),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 30, color: C.primary),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Andi Pratama',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        SizedBox(height: 3),
                        Text('andi.pratama@mail.com',
                            style: TextStyle(
                                fontSize: 12, color: Colors.white70)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.white70),
                ],
              ),
            ),
            // ---- Stats ----
            const SizedBox(height: 16),
            Row(
              children: [
                _StatCard(value: '${st.favoriteCount}', label: 'Resep'),
                const SizedBox(width: 10),
                _StatCard(value: '${st.listCount}', label: 'Belanja'),
                const SizedBox(width: 10),
                _StatCard(value: '23/12', label: 'Target'),
              ],
            ),
            const SizedBox(height: 16),
            // ---- Weekly progress ----
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: C.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: C.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text('Progres Mingguan',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: C.ink)),
                      Spacer(),
                      Text('62%',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: C.primaryDark)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: st.progress,
                      minHeight: 10,
                      backgroundColor: C.line,
                      color: C.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Masak 4 dari 6 resep sehat minggu ini',
                      style: TextStyle(fontSize: 11.5, color: C.muted)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // ---- Menu list ----
            _MenuGroup(
              items: [
                (Icons.notifications_outlined, 'Notifikasi', '#FFFFFF80'),
                (Icons.receipt_long_outlined, 'Riwayat Masak', '#FFFFFF'),
                (Icons.download_outlined, 'Unduhan', '#FFFFFF'),
              ],
            ),
            const SizedBox(height: 12),
            _MenuGroup(
              items: [
                (Icons.help_outline, 'Bantuan & Pusat Dukungan', '#FFFFFF80'),
                (Icons.privacy_tip_outlined, 'Privasi & Kebijakan', '#FFFFFF'),
                (Icons.star_outline, 'Beri Nilai Aplikasi', '#FFFFFF80'),
              ],
            ),
            const SizedBox(height: 12),
            _MenuGroup(
              items: [
                (Icons.logout, 'Keluar dari Akun', '#FFFFFF'),
              ],
              danger: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: C.line),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w800, color: C.ink)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11.5, color: C.muted)),
          ],
        ),
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  final List<(IconData, String, String)> items;
  final bool danger;
  const _MenuGroup({required this.items, this.danger = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.line),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            InkWell(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('“${items[i].$2}” — segera hadir'))),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(items[i].$1,
                        size: 20, color: danger ? C.red : C.primary),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(items[i].$2,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: C.ink)),
                    ),
                    Icon(Icons.chevron_right, size: 18, color: C.muted),
                  ],
                ),
              ),
            ),
            if (i < items.length - 1)
              const Divider(height: 1, indent: 52, color: C.line),
          ],
        ],
      ),
    );
  }
}
