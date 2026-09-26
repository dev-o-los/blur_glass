import 'dart:async';
import 'package:flutter/services.dart';

import '../models/attention_snapshot.dart';

export '../models/attention_snapshot.dart';

class OwnerEnrollmentException implements Exception {
  OwnerEnrollmentException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Thin wrapper over the two channels: `blur_glass/privacy` (methods) and
/// `blur_glass/privacy/events` (snapshots).
class PrivacyChannel {
  PrivacyChannel();

  static const _methods = MethodChannel('blur_glass/privacy');
  static const _events = EventChannel('blur_glass/privacy/events');

  Stream<AttentionSnapshot>? _stream;

  Stream<AttentionSnapshot> snapshots() {
    _stream ??= _events.receiveBroadcastStream().map((event) {
      if (event is Map) {
        return AttentionSnapshot.fromMap(event.cast<Object?, Object?>());
      }
      return const AttentionSnapshot(
        state: 'idle',
        faceCount: 0,
        ownerMatch: false,
        shieldVisible: false,
        message: '',
      );
    });
    return _stream!;
  }

  Future<T> _invoke<T>(String method, [dynamic args]) async {
    try {
      final result = await _methods.invokeMethod<T>(method, args);
      if (result == null) {
        if (T == String) return '' as T;
        if (T == bool) return false as T;
        if (T == int) return 0 as T;
      }
      return result as T;
    } on PlatformException catch (e) {
      throw OwnerEnrollmentException(e.message ?? e.code);
    }
  }

  Future<String> getDeviceFingerprint() =>
      _invoke<String>('getDeviceFingerprint');

  Future<String> getHardwareUUID() => _invoke<String>('getHardwareUUID');

  Future<String> cameraPermission() => _invoke<String>('getCameraPermission');

  Future<bool> requestCameraPermission() =>
      _invoke<bool>('requestCameraPermission');

  Future<void> openCameraSettings() => _invoke<void>('openCameraSettings');

  Future<bool> authenticateOwner() => _invoke<bool>('authenticateOwner');

  Future<bool> hasOwnerTemplate() => _invoke<bool>('hasOwnerTemplate');

  Future<int> enrollOwner() => _invoke<int>('enrollOwner');

  Future<void> cancelEnrollment() => _invoke<void>('cancelEnrollment');

  Future<void> clearOwner() => _invoke<void>('clearOwner');

  Future<bool> startProtection() => _invoke<bool>('startProtection');

  Future<bool> stopProtection() => _invoke<bool>('stopProtection');

  Future<bool> isProtecting() => _invoke<bool>('isProtecting');

  Future<bool> hasEmergencyPassword() => _invoke<bool>('hasEmergencyPassword');

  Future<bool> setEmergencyPassword(String password) =>
      _invoke<bool>('setEmergencyPassword', password);

  Future<bool> verifyEmergencyPassword(String password) =>
      _invoke<bool>('verifyEmergencyPassword', password);

  Future<bool> clearEmergencyPassword() =>
      _invoke<bool>('clearEmergencyPassword');

  Future<void> setConfig({
    double? yawDegrees,
    double? pitchDegrees,
    double? unlockMs,
    double? noFaceLockMs,
  }) =>
      _invoke<void>('setConfig', {
        'yawDegrees': ?yawDegrees,
        'pitchDegrees': ?pitchDegrees,
        'unlockMs': ?unlockMs,
        'noFaceLockMs': ?noFaceLockMs,
      });
}
