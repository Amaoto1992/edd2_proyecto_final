import 'package:flutter_test/flutter_test.dart';

import 'package:edd2_proyecto_final/main.dart';

void main() {
  testWidgets('La pantalla de login carga', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Continuar con Google'), findsOneWidget);
  });
}
