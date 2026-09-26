import 'dart:async';

import 'device_lock_service.dart';
import 'privacy_channel.dart';

/// App lifecycle: onboarding → dashboard.
enum AppPhase { loading, onboarding, dashboard }

/// Bridges the native agent streams into UI state.
///
/// The agent owns protection; this controller mirrors its state, handles
/// enrollment (a native-run procedure that emits progress snapshots on the
/// same event channel), and re-checks permission state on resume.
class PrivacyController {
  PrivacyController({
    PrivacyChannel? channel,
    DeviceLockService? deviceLockService,
  })  : _channel = channel ?? PrivacyChannel(),
        _deviceLock = deviceLockService ??
            (channel != null
                ? DeviceLockService(channel: channel)
                : DeviceLockService.instance) {
    _instance = this;
  }

  static PrivacyController? _instance;

  /// App-wide instance, for dialogs created outside the widget tree.
  static PrivacyController? get instance => _instance;

  final PrivacyChannel _channel;
  final DeviceLockService _deviceLock;

  final _phase = StreamController<AppPhase>.broadcast();
  final _permission = StreamController<String>.broadcast();
  final _enrollmentActive = StreamController<bool>.broadcast();
  final _snapshots = StreamController<AttentionSnapshot>.broadcast();
  final _errors = StreamController<String>.broadcast();

  AppPhase _currentPhase = AppPhase.loading;
  String _currentPermission = 'notDetermined';
  bool _currentEnrollment = false;
  bool _hasTemplate = false;
  bool _onboardingDone = false;
  AttentionSnapshot? _currentSnapshot;

  Stream<AppPhase> get phase => _phase.stream;
  Stream<String> get permission => _permission.stream;
  Stream<bool> get enrollmentActive => _enrollmentActive.stream;
  Stream<AttentionSnapshot> get snapshots => _snapshots.stream;
  Stream<String> get errors => _errors.stream;

  AppPhase get currentPhase => _currentPhase;
  String get currentPermission => _currentPermission;
  bool get currentEnrollment => _currentEnrollment;
  bool get currentHasTemplate => _hasTemplate;
  AttentionSnapshot? get currentSnapshot => _currentSnapshot;

  StreamSubscription<AttentionSnapshot>? _snapshotSub;

  Future<void> init() async {
    _snapshotSub = _channel.snapshots().listen(_onSnapshot);
    await _deviceLock.verify();
    await _refresh();
  }

  Future<void> refresh() => _refresh();

  Future<void> _refresh() async {
    try {
      final permission = await _channel.cameraPermission();
      final hasTemplate = await _channel.hasOwnerTemplate();
      final protecting = await _channel.isProtecting();
      _currentPermission = permission;
      _hasTemplate = hasTemplate;
      // A stored template means setup completed at some point.
      if (hasTemplate) {
        _onboardingDone = true;
      }
      if (!_permission.isClosed) {
        _permission.add(permission);
      }
      _setPhase(hasTemplate || protecting || _onboardingDone
          ? AppPhase.dashboard
          : AppPhase.onboarding);
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

  /// Called when the user finishes the onboarding wizard; keeps them on the
  /// dashboard even if no template exists yet (e.g. camera skipped).
  void finishOnboarding() {
    _onboardingDone = true;
    _setPhase(AppPhase.dashboard);
  }

  /// Re-opens the setup wizard without deleting anything (used when no
  /// template exists yet, e.g. the user skipped camera setup).
  void redoOnboarding() {
    _setPhase(AppPhase.onboarding);
  }

  Future<void> startProtection() async {
    final lockStatus = await _deviceLock.verify();
    if (lockStatus == DeviceLockStatus.mismatch) {
      if (!_errors.isClosed) {
        _errors.add(
          'Protected device mismatch: This installation is bound to another Mac. '
          'Please install fresh from the official website.',
        );
      }
      return;
    }
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
    // Deliberately clearing the owner drops the user back into setup.
    _onboardingDone = false;
    _hasTemplate = false;
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
    if (_instance == this) {
      _instance = null;
    }
    await _snapshotSub?.cancel();
    await _phase.close();
    await _permission.close();
    await _enrollmentActive.close();
    await _snapshots.close();
    await _errors.close();
  }
}
