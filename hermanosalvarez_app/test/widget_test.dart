import 'package:flutter_test/flutter_test.dart';
import 'package:hermanosalvarez_app/app/app.dart';

void main() {
  testWidgets('La aplicación arranca correctamente', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const HermanosAlvarezApp());

    expect(
      find.byType(HermanosAlvarezApp),
      findsOneWidget,
    );
  });
}