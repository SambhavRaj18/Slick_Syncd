import 'package:flutter_test/flutter_test.dart';
import 'package:first_game/main.dart';

void main() {
  testWidgets('Smart Home App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartHomeApp());
    expect(find.byType(SmartHomeApp), findsOneWidget);
  });
}
