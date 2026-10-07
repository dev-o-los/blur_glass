import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blur_glass/services/device_lock_service.dart';
import 'package:blur_glass/services/privacy_channel.dart';
import 'package:blur_glass/services/privacy_controller.dart';
import 'package:blur_glass/screens/dashboard_screen.dart';

class FakePrivacyChannel extends PrivacyChannel {
  final _snapshotController = StreamController<AttentionSnapshot>.broadcast();
  bool isCurrentlyProtecting = true;

  @override
  Stream<AttentionSnapshot> snapshots() => _snapshotController.stream;

  @override
  Future<String> cameraPermission() async => 'authorized';

  @override
  Future<String> getDeviceFingerprint() async => 'test-device-fp';

  @override
  Future<bool> hasOwnerTemplate() async => true;

  @override
  Future<bool> isProtecting() async => isCurrentlyProtecting;

  @override
  Future<bool> startProtection() async {
    isCurrentlyProtecting = true;
    _snapshotController.add(const AttentionSnapshot(
      state: 'owner',
      faceCount: 1,
      ownerMatch: true,
      shieldVisible: false,
      message: 'Screen clear',
    ));
    return true;
  }

  @override
  Future<bool> stopProtection() async {
    isCurrentlyProtecting = false;
    _snapshotController.add(const AttentionSnapshot(
      state: 'idle',
      faceCount: 0,
      ownerMatch: false,
      shieldVisible: false,
      message: '',
    ));
    return true;
  }

  void emitSnapshot(AttentionSnapshot snapshot) {
    _snapshotController.add(snapshot);
  }
}

class FakeDeviceLockService extends DeviceLockService {
  @override
  Future<DeviceLockStatus> verify() async => DeviceLockStatus.valid;
}

void main() {
  testWidgets('BlurGlassPopover renders exact elements from reference image',
      (tester) async {
    final channel = FakePrivacyChannel();
    final controller = PrivacyController(
      channel: channel,
      deviceLockService: FakeDeviceLockService(),
    );
    await controller.init();

    // Provide initial owner snapshot (Screen clear)
    channel.emitSnapshot(const AttentionSnapshot(
      state: 'owner',
      faceCount: 1,
      ownerMatch: true,
      shieldVisible: false,
      message: 'Screen clear',
    ));

    await tester.pumpWidget(
      MaterialApp(
        home: DashboardScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title & Tagline
    expect(find.text('Blur Glass'), findsOneWidget);
    expect(find.text('Screen privacy, naturally.'), findsOneWidget);

    // Verify Feature Card
    expect(find.text('Screen Privacy'), findsOneWidget);
    expect(find.text('Blur when you look away'), findsOneWidget);

    // Verify Shield Icon & Gear Icon
    expect(find.byIcon(CupertinoIcons.shield_fill), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.gear_alt), findsOneWidget);

    // Verify Status Indicator text
    expect(find.text('Screen clear'), findsOneWidget);

    // Tap gear to open Settings
    await tester.tap(find.byIcon(CupertinoIcons.gear_alt));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    // Tap Back to return to main card
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Screen Privacy'), findsOneWidget);
  });
}
