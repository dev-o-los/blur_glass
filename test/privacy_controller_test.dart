import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:blur_glass/privacy_channel.dart';
import 'package:blur_glass/privacy_controller.dart';

class FakePrivacyChannel implements PrivacyChannel {
  final _snapshotController = StreamController<AttentionSnapshot>.broadcast();
  String cameraPermissionState = 'authorized';
  bool hasTemplateState = false;
  bool protectingState = false;
  bool authenticateResult = true;
  int enrolledCount = 10;
  bool throwOnEnroll = false;

  @override
  Stream<AttentionSnapshot> snapshots() => _snapshotController.stream;

  void emitSnapshot(AttentionSnapshot snapshot) {
    _snapshotController.add(snapshot);
  }

  @override
  Future<String> cameraPermission() async => cameraPermissionState;

  @override
  Future<bool> requestCameraPermission() async {
    cameraPermissionState = 'authorized';
    return true;
  }

  @override
  Future<void> openCameraSettings() async {}

  @override
  Future<bool> authenticateOwner() async => authenticateResult;

  @override
  Future<bool> hasOwnerTemplate() async => hasTemplateState;

  @override
  Future<int> enrollOwner() async {
    if (throwOnEnroll) {
      throw OwnerEnrollmentException('Enrollment failed in test');
    }
    hasTemplateState = true;
    return enrolledCount;
  }

  @override
  Future<void> cancelEnrollment() async {}

  @override
  Future<void> clearOwner() async {
    hasTemplateState = false;
    protectingState = false;
  }

  @override
  Future<bool> startProtection() async {
    protectingState = true;
    return true;
  }

  @override
  Future<bool> stopProtection() async {
    protectingState = false;
    return true;
  }

  @override
  Future<bool> isProtecting() async => protectingState;

  @override
  Future<void> setConfig({
    double? yawDegrees,
    double? pitchDegrees,
    double? unlockMs,
    double? noFaceLockMs,
  }) async {}

  void dispose() {
    _snapshotController.close();
  }
}

void main() {
  group('AttentionSnapshot parsing and properties', () {
    test('parses complete snapshot correctly', () {
      final map = {
        'state': 'owner',
        'faceCount': 1,
        'ownerMatch': true,
        'shieldVisible': false,
        'message': 'Owner looking at screen',
        'yaw': 2.5,
        'pitch': -1.2,
        'matchDistance': 0.32,
      };

      final snapshot = AttentionSnapshot.fromMap(map);
      expect(snapshot.state, 'owner');
      expect(snapshot.faceCount, 1);
      expect(snapshot.ownerMatch, isTrue);
      expect(snapshot.shieldVisible, isFalse);
      expect(snapshot.isShielded, isFalse);
      expect(snapshot.tone, SnapshotTone.good);
      expect(snapshot.yaw, 2.5);
      expect(snapshot.pitch, -1.2);
      expect(snapshot.matchDistance, 0.32);
    });

    test('determines danger/warning tones accurately', () {
      const extraFace = AttentionSnapshot(
        state: 'extraFace',
        faceCount: 2,
        ownerMatch: false,
        shieldVisible: true,
        message: 'Extra face detected',
      );
      expect(extraFace.tone, SnapshotTone.danger);
      expect(extraFace.isShielded, isTrue);

      const lookAway = AttentionSnapshot(
        state: 'lookAway',
        faceCount: 1,
        ownerMatch: true,
        shieldVisible: true,
        message: 'Looking away',
      );
      expect(lookAway.tone, SnapshotTone.warning);
      expect(lookAway.isShielded, isTrue);

      const enrolling = AttentionSnapshot(
        state: 'enrolling',
        faceCount: 1,
        ownerMatch: false,
        shieldVisible: false,
        message: 'Enrolling',
      );
      expect(enrolling.tone, SnapshotTone.info);
      expect(enrolling.isShielded, isFalse);
    });
  });

  group('PrivacyController lifecycle and state management', () {
    late FakePrivacyChannel fakeChannel;
    late PrivacyController controller;

    setUp(() {
      fakeChannel = FakePrivacyChannel();
      controller = PrivacyController(channel: fakeChannel);
    });

    tearDown(() async {
      await controller.dispose();
      fakeChannel.dispose();
    });

    test('initializes to onboarding when no template exists', () async {
      fakeChannel.hasTemplateState = false;
      await controller.init();

      expect(controller.currentPhase, AppPhase.onboarding);
      expect(controller.currentPermission, 'authorized');
    });

    test('initializes to dashboard when template exists', () async {
      fakeChannel.hasTemplateState = true;
      await controller.init();

      expect(controller.currentPhase, AppPhase.dashboard);
    });

    test('updates snapshot cache and notifies listeners', () async {
      await controller.init();
      expect(controller.currentSnapshot, isNull);

      final events = <AttentionSnapshot>[];
      final sub = controller.snapshots.listen(events.add);

      const snap = AttentionSnapshot(
        state: 'owner',
        faceCount: 1,
        ownerMatch: true,
        shieldVisible: false,
        message: 'Owner detected',
      );
      fakeChannel.emitSnapshot(snap);
      await Future<void>.delayed(Duration.zero);

      expect(controller.currentSnapshot, snap);
      expect(events, [snap]);
      await sub.cancel();
    });

    test('enrollment updates phase to dashboard on success', () async {
      fakeChannel.hasTemplateState = false;
      await controller.init();
      expect(controller.currentPhase, AppPhase.onboarding);

      await controller.enroll();
      expect(controller.currentPhase, AppPhase.dashboard);
      expect(fakeChannel.hasTemplateState, isTrue);
    });

    test('enrollment failure emits error to error stream', () async {
      fakeChannel.hasTemplateState = false;
      fakeChannel.throwOnEnroll = true;
      await controller.init();

      final errors = <String>[];
      final sub = controller.errors.listen(errors.add);

      await controller.enroll();
      expect(errors, contains('Enrollment failed in test'));
      await sub.cancel();
    });

    test('clearOwner resets template and returns to onboarding', () async {
      fakeChannel.hasTemplateState = true;
      await controller.init();
      expect(controller.currentPhase, AppPhase.dashboard);

      await controller.clearOwner();
      expect(controller.currentPhase, AppPhase.onboarding);
      expect(fakeChannel.hasTemplateState, isFalse);
    });
  });
}
