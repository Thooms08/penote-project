import 'package:flutter_test/flutter_test.dart';
import 'package:penote/main.dart';

void main() {
  testWidgets('Opening screen shows app branding', (WidgetTester tester) async {
    await tester.pumpWidget(const PenoteApp());

    expect(find.text('Penote'), findsOneWidget);
  });
}
