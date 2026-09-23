// Minimal smoke test for the Blur Glass shell.
//
// The native agent (camera, enrollment, shield) only exists inside the macOS
// app bundle, so this test exercises the loading phase only.
import 'package:flutter_test/flutter_test.dart';

import 'package:blur_glass/main.dart';

void main() {
  testWidgets('app boots into the agent splash', (WidgetTester tester) async {
    await tester.pumpWidget(const BlurGlassApp());
    await tester.pump();

    expect(find.text('Connecting to the Blur Glass agent…'), findsOneWidget);
  });
}
