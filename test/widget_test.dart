import 'package:flutter_test/flutter_test.dart';
import 'package:sueltito/app.dart';

void main() {
  testWidgets('Welcome muestra elementos básicos', (tester) async {
    await tester.pumpWidget(const SueltitoApp());
    await tester.pumpAndSettle();
    expect(find.text('Sueltito'), findsOneWidget);
    expect(find.text('Inicia Sesion'), findsOneWidget);
    expect(find.text('Registrate'), findsOneWidget);
  });
}
