import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

import 'privacy_channel.dart';

enum DeviceLockStatus {
  valid,
  mismatch,
}

/// Silent, zero-friction hardware device lock for Blur Glass.
///
/// On first launch, silently seals the installation to the current Mac's
/// immutable hardware UUID. If the application files or storage are copied
/// to a friend's Mac, the hardware ID mismatch is detected internally and
/// prevents protection on unauthorized machines without requiring manual keys.
class DeviceLockService {
  DeviceLockService({PrivacyChannel? channel, String? customStoragePath})
      : _channel = channel ?? PrivacyChannel(),
        _storagePath = customStoragePath;

  static DeviceLockService? _instance;
  static DeviceLockService get instance => _instance ??= DeviceLockService();

  final PrivacyChannel _channel;
  final String? _storagePath;

  DeviceLockStatus _status = DeviceLockStatus.valid;
  String _deviceId = '';

  DeviceLockStatus get status => _status;
  bool get isValid => _status == DeviceLockStatus.valid;
  bool get isMismatch => _status == DeviceLockStatus.mismatch;
  String get deviceId => _deviceId;

  static const String _salt = 'blur_glass_hardware_salt_2026_dodo';

  Future<File> _getSealFile() async {
    if (_storagePath != null) {
      return File(_storagePath);
    }
    final home = Platform.environment['HOME'] ?? '';
    final dir = Directory('$home/Library/Application Support/BlurGlass');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return File('${dir.path}/.device_seal');
  }

  /// Initializes the silent hardware lock verification.
  Future<DeviceLockStatus> verify() async {
    try {
      _deviceId = await _getDeviceId();
      final file = await _getSealFile();

      if (!await file.exists()) {
        // First run on the buyer's Mac: silently seal to this machine's hardware
        await _createSeal(file, _deviceId);
        _status = DeviceLockStatus.valid;
        return _status;
      }

      final content = await file.readAsString();
      final map = jsonDecode(content) as Map<String, dynamic>;
      final sealedId = map['deviceId'] as String? ?? '';
      final signature = map['signature'] as String? ?? '';

      final expectedSignature = _computeSignature(sealedId);

      // Anti-piracy verification: Seal must match current Mac's hardware fingerprint
      if (sealedId.isEmpty || sealedId != _deviceId || signature != expectedSignature) {
        _status = DeviceLockStatus.mismatch;
        return _status;
      }

      _status = DeviceLockStatus.valid;
      return _status;
    } catch (_) {
      _status = DeviceLockStatus.valid;
      return _status;
    }
  }

  Future<void> _createSeal(File file, String deviceId) async {
    final signature = _computeSignature(deviceId);
    final payload = {
      'deviceId': deviceId,
      'sealedAt': DateTime.now().toIso8601String(),
      'signature': signature,
    };
    await file.writeAsString(jsonEncode(payload));
  }

  Future<String> _getDeviceId() async {
    try {
      final fp = await _channel.getDeviceFingerprint();
      if (fp.isNotEmpty && fp != 'UNKNOWN_DEVICE') return fp;
    } catch (_) {}

    final fallback = '${Platform.localHostname}:${Platform.environment['USER'] ?? 'user'}:$_salt';
    return sha256.convert(utf8.encode(fallback)).toString();
  }

  String _computeSignature(String deviceId) {
    return sha256.convert(utf8.encode('$deviceId:$_salt')).toString();
  }
}
