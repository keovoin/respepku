import 'package:flutter_test/flutter_test.dart';

import 'package:respepku/main.dart';

void main() {
  testWidgets('App boots to Home tab', (WidgetTester tester) async {
    await tester.pumpWidget(const ResepKuApp());
    await tester.pump(const Duration(seconds: 2));
    // Header + featured banner render without network.
    expect(find.text('Hi, Andi'), findsOneWidget);
    expect(find.textContaining('Resep Spesial Hari Ini'), findsOneWidget);
    expect(find.text('Kategori'), findsOneWidget);
    // Network is blocked in tests -> popular row shows offline state.
    expect(find.text('Memuat resep…'), findsNothing);
  });
}
