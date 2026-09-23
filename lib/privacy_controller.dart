import 'dart:async';

import 'privacy_channel.dart';

/// App lifecycle: onboarding → dashboard.
enum AppPhase { loading, onboarding, dashboard }

/// Bridges the native agent streams into UI state.
///
/// The agent owns protection; this controller mirrors its state, handles
/// enrollment (a native-run procedure that emits progress snapshots on the
/// same event channel), and re-checks permission state on resume.
class PrivacyController {
  PrivacyController({PrivacyChannel? channel})
      : _channel = channel ?? PrivacyChannel();

  final PrivacyChannel _channel;

  final _phase = StreamController<AppPhase>.broadcast();
  final _permission = StreamController<String>.broadcast();
  final _enrollmentActive = StreamController<bool>.broadcast();
  final _snapshots = StreamController<AttentionSnapshot>.broadcast();
  final _errors = StreamController<String>.broadcast();

  AppPhase _currentPhase = AppPhase.loading;
  String _currentPermission = 'notDetermined';
  bool _currentEnrollment = false;
  AttentionSnapshot? _currentSnapshot;

  Stream<AppPhase> get phase => _phase.stream;
  Stream<String> get permission => _permission.stream;
  Stream<bool> get enrollmentActive => _enrollmentActive.stream;
  Stream<AttentionSnapshot> get snapshots => _snapshots.stream;
  Stream<String> get errors => _errors.stream;

  AppPhase get currentPhase => _currentPhase;
  String get currentPermission => _currentPermission;
  bool get currentEnrollment => _currentEnrollment;
  AttentionSnapshot? get currentSnapshot => _currentSnapshot;

  StreamSubscription<AttentionSnapshot>? _snapshotSub;

  Future<void> init() async {
    _snapshotSub = _channel.snapshots().listen(_onSnapshot);
    await _refresh();
  }

  Future<void> refresh() => _refresh();

  Future<void> _refresh() async {
    try {
      final permission = await _channel.cameraPermission();
      final hasTemplate = await _channel.hasOwnerTemplate();
      final protecting = await _channel.isProtecting();
      _currentPermission = permission;
      if (!_permission.isClosed) {
        _permission.add(permission);
      }
      _setPhase(hasTemplate || protecting ? AppPhase.dashboard : AppPhase.onboarding);
    } on OwnerEnrollmentException catch (e) {
      if (!_errors.isClosed) {
        _errors.add(e.message);
      }
    } catch (e) {
      if (!_errors.isClosed) {
        _errors.add(e.toString());
      }
    }
  }

  void _onSnapshot(AttentionSnapshot snapshot) {
    _currentSnapshot = snapshot;
    // Enrollment progress arrives as 'enrolling' snapshots; they surface as a
    // progress banner rather than a screen change, and mark enrollment live.
    final enrolling = snapshot.state == 'enrolling';
    if (enrolling != _currentEnrollment) {
      _currentEnrollment = enrolling;
      if (!_enrollmentActive.isClosed) {
        _enrollmentActive.add(enrolling);
      }
    }
    if (!_snapshots.isClosed) {
      _snapshots.add(snapshot);
    }
    if (snapshot.state == 'idle' && _currentPhase == AppPhase.loading) {
      _setPhase(AppPhase.onboarding);
    }
  }

  Future<bool> requestCameraPermission() async {
    try {
      final granted = await _channel.requestCameraPermission();
      await _refresh();
      return granted;
    } on OwnerEnrollmentException catch (e) {
      if (!_errors.isClosed) {
        _errors.add(e.message);
      }
      return false;
    } catch (e) {
      if (!_errors.isClosed) {
        _errors.add(e.toString());
      }
      return false;
    }
  }

  Future<void> openCameraSettings() async {
    try {
      await _channel.openCameraSettings();
    } on OwnerEnrollmentException catch (e) {
      if (!_errors.isClosed) {
        _errors.add(e.message);
      }
    } catch (e) {
      if (!_errors.isClosed) {
        _errors.add(e.toString());
      }
    }
  }

  /// Full enrollment: authenticate the Mac user, then run native capture.
  Future<void> enroll() async {
    try {
      final authed = await _channel.authenticateOwner();
      if (!authed) {
        if (!_errors.isClosed) {
          _errors.add('Mac authentication is required before enrolling.');
        }
        return;
      }
      await _channel.enrollOwner();
      await _refresh();
    } on OwnerEnrollmentException catch (e) {
      if (!_errors.isClosed) {
        _errors.add(e.message);
      }
      await _refresh();
    } catch (e) {
      if (!_errors.isClosed) {
        _errors.add(e.toString());
      }
      await _refresh();
    }
  }

  Future<void> cancelEnrollment() async {
    try {
      await _channel.cancelEnrollment();
    } on OwnerEnrollmentException catch (e) {
      if (!_errors.isClosed) {
        _errors.add(e.message);
      }
    } catch (e) {
      if (!_errors.isClosed) {
        _errors.add(e.toString());
      }
    }
    await _refresh();
  }

  Future<void> startProtection() async {
    try {
      await _channel.startProtection();
      await _refresh();
    } on OwnerEnrollmentException catch (e) {
      if (!_errors.isClosed) {
        _errors.add(e.message);
      }
    } catch (e) {
      if (!_errors.isClosed) {
        _errors.add(e.toString());
      }
    }
  }

  Future<void> stopProtection() async {
    try {
      await _channel.stopProtection();
      await _refresh();
    } on OwnerEnrollmentException catch (e) {
      if (!_errors.isClosed) {
        _errors.add(e.message);
      }
    } catch (e) {
      if (!_errors.isClosed) {
        _errors.add(e.toString());
      }
    }
  }

  Future<void> clearOwner() async {
    try {
      await _channel.clearOwner();
    } on OwnerEnrollmentException catch (e) {
      if (!_errors.isClosed) {
        _errors.add(e.message);
      }
    } catch (e) {
      if (!_errors.isClosed) {
        _errors.add(e.toString());
      }
    }
    await _refresh();
  }

  Future<void> setConfig({
    double? yawDegrees,
    double? pitchDegrees,
    double? unlockMs,
    double? noFaceLockMs,
  }) async {
    try {
      await _channel.setConfig(
        yawDegrees: yawDegrees,
        pitchDegrees: pitchDegrees,
        unlockMs: unlockMs,
        noFaceLockMs: noFaceLockMs,
      );
    } on OwnerEnrollmentException catch (e) {
      if (!_errors.isClosed) {
        _errors.add(e.message);
      }
    } catch (e) {
      if (!_errors.isClosed) {
        _errors.add(e.toString());
      }
    }
  }

  void _setPhase(AppPhase phase) {
    if (_currentPhase == phase) return;
    _currentPhase = phase;
    if (!_phase.isClosed) {
      _phase.add(phase);
    }
  }

  Future<void> dispose() async {
    await _snapshotSub?.cancel();
    await _phase.close();
    await _permission.close();
    await _enrollmentActive.close();
    await _snapshots.close();
    await _errors.close();
  }
}

