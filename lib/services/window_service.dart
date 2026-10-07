import 'package:flutter/services.dart';

/// Helper service to control the macOS window dimensions dynamically.
class WindowService {
  static const MethodChannel _channel = MethodChannel('blur_glass/window');

  /// Requests the native macOS window to animate to the specified width and height.
  static Future<void> setWindowSize({
    required double width,
    required double height,
    bool animate = true,
  }) async {
    try {
      await _channel.invokeMethod('setWindowSize', {
        'width': width,
        'height': height,
        'animate': animate,
      });
    } catch (_) {
      // Ignore if channel is unavailable (e.g. unit tests or non-macOS platforms)
    }
  }
}
