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

  Future<T> _invoke<T>(String method, [Map<String, Object?>? args]) async {
    try {
      final result = await _methods.invokeMethod<T>(method, args);
      return result as T;
    } on PlatformException catch (e) {
      throw OwnerEnrollmentException(e.message ?? e.code);
    }
  }

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
