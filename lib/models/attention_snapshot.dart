/// Mirror of the native `AttentionSnapshot` emitted on `blur_glass/privacy/events`.
class AttentionSnapshot {
  const AttentionSnapshot({
    required this.state,
    required this.faceCount,
    required this.ownerMatch,
    required this.shieldVisible,
    required this.message,
    this.yaw,
    this.pitch,
    this.matchDistance,
  });

  factory AttentionSnapshot.fromMap(Map<Object?, Object?> map) {
    return AttentionSnapshot(
      state: map['state'] as String? ?? 'idle',
      faceCount: (map['faceCount'] as num?)?.toInt() ?? 0,
      ownerMatch: map['ownerMatch'] as bool? ?? false,
      shieldVisible: map['shieldVisible'] as bool? ?? false,
      message: map['message'] as String? ?? '',
      yaw: (map['yaw'] as num?)?.toDouble(),
      pitch: (map['pitch'] as num?)?.toDouble(),
      matchDistance: (map['matchDistance'] as num?)?.toDouble(),
    );
  }

  final String state;
  final int faceCount;
  final bool ownerMatch;
  final bool shieldVisible;
  final String message;
  final double? yaw;
  final double? pitch;
  final double? matchDistance;

  /// True when the native frost shield is covering the screen.
  bool get isShielded =>
      state != 'owner' && state != 'idle' && state != 'enrolling';

  /// Rough color grouping for UI accents.
  SnapshotTone get tone {
    switch (state) {
      case 'owner':
        return SnapshotTone.good;
      case 'extraFace':
      case 'stranger':
      case 'error':
        return SnapshotTone.danger;
      case 'noFace':
      case 'lookAway':
        return SnapshotTone.warning;
      case 'enrolling':
        return SnapshotTone.info;
      default:
        return SnapshotTone.neutral;
    }
  }
}

enum SnapshotTone { good, warning, danger, info, neutral }
