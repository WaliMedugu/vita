import 'package:flutter_test/flutter_test.dart';
import 'package:vita/main.dart';

void main() {
  testWidgets('VITA smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const VitaApp());
    expect(find.byType(VitaApp), findsOneWidget);
  });
}
