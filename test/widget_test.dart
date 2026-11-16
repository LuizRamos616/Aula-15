import 'package:flutter_test/flutter_test.dart';

import 'package:perfil_midia/main.dart';

void main() {
  testWidgets('App builds', (WidgetTester tester) async {
    await tester.pumpWidget(const MeuApp());
    await tester.pump();
    expect(find.text('Perfil do Usuário'), findsOneWidget);
  });
}
