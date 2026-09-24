// Smoke + onboarding-flow tests for the Blur Glass shell.
//
// The native agent only exists inside the macOS app bundle, so the method
// channel is stubbed to simulate a fresh install (no template, permission
// not yet determined).
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blur_glass/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  void stubFreshInstall() {
    const channel = MethodChannel('blur_glass/privacy');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'getCameraPermission':
          return 'notDetermined';
        case 'hasOwnerTemplate':
          return false;
        case 'isProtecting':
          return false;
        default:
          return null;
      }
    });
    // EventChannels dispatch 'listen' over the binary messenger; a null
    // handler result simply yields an empty stream.
    const events = MethodChannel('blur_glass/privacy/events');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(events, (call) async => null);
  }

  testWidgets('app boots into the agent splash', (WidgetTester tester) async {
    await tester.pumpWidget(const BlurGlassApp());
    await tester.pump();

    expect(find.text('Connecting to the Blur Glass agent…'), findsOneWidget);
  });

  testWidgets(
      'a fresh install lands on the onboarding welcome step, before any '
      'permission prompt', (WidgetTester tester) async {
    stubFreshInstall();
    await tester.pumpWidget(const BlurGlassApp());
    await tester.pumpAndSettle();

    // Welcome step explains the product first.
    expect(find.text('Blur Glass'), findsOneWidget);
    expect(find.text('Your Mac, visible only to you.'), findsOneWidget);
    expect(find.text('Read the privacy details'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    // Continuing reaches the explanation step without any system dialog.
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('When does the screen blur?'), findsOneWidget);
  });
}
