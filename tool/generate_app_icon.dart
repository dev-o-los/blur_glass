import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

/// Renders the Blur Glass app icon: macOS rounded-square canvas, blue
/// vertical gradient, white dotted-grid "iris" — the same geometry as the
/// in-app BrandMark in lib/theme.dart.
///
/// Run: dart run tool/generate_app_icon.dart

const _gradientTop = [0x33, 0xA0, 0xFF];
const _gradientBottom = [0x0A, 0x72, 0xF0];

// macOS icon canvas proportions (Big Sur grid): mark ~824/1024 of the
// canvas, corner radius ~185.4/1024.
const double _markFraction = 824 / 1024;
const double _radiusFraction = 185.4 / 1024;

void main() {
  final master = _render(1024);
  final outDir = 'macos/Runner/Assets.xcassets/AppIcon.appiconset';
  const sizes = {
    'app_icon_16.png': 16,
    'app_icon_32.png': 32,
    'app_icon_64.png': 64,
    'app_icon_128.png': 128,
    'app_icon_256.png': 256,
    'app_icon_512.png': 512,
    'app_icon_1024.png': 1024,
  };
  for (final entry in sizes.entries) {
    final scaled = img.copyResize(
      master,
      width: entry.value,
      height: entry.value,
      interpolation: img.Interpolation.cubic,
    );
    File('$outDir/${entry.key}').writeAsBytesSync(img.encodePng(scaled));
    stdout.writeln('Wrote $outDir/${entry.key}');
  }
}

img.Image _render(int size) {
  final image = img.Image(width: size, height: size);
  final markSize = (size * _markFraction).round();
  final offset = (size - markSize) ~/ 2;
  final radius = size * _radiusFraction;

  for (final p in image) {
    // Transparent canvas; only the rounded mark is painted.
    final localX = p.x - offset;
    final localY = p.y - offset;
    if (localX < 0 || localY < 0 || localX >= markSize || localY >= markSize) {
      continue;
    }
    final t = localY / markSize;
    final c = _lerpColor(_gradientTop, _gradientBottom, t);
    // Subtle vertical shading from the bottom to give the mark depth.
    final inRect = _insideRoundedRect(
      localX.toDouble(),
      localY.toDouble(),
      markSize.toDouble(),
      radius,
    );
    if (!inRect) continue;
    image.setPixelRgba(p.x, p.y, c[0], c[1], c[2], 255);
  }

  _paintDots(image, offset.toDouble(), markSize.toDouble());
  return image;
}

bool _insideRoundedRect(double x, double y, double size, double radius) {
  final rx = math.min(x, size - 1 - x);
  final ry = math.min(y, size - 1 - y);
  if (rx >= 0 && ry >= 0) {
    if (rx >= radius || ry >= radius) return true;
    final dx = radius - rx;
    final dy = radius - ry;
    return dx * dx + dy * dy <= radius * radius;
  }
  return false;
}

List<int> _lerpColor(List<int> a, List<int> b, double t) {
  return [
    (a[0] + (b[0] - a[0]) * t).round(),
    (a[1] + (b[1] - a[1]) * t).round(),
    (a[2] + (b[2] - a[2]) * t).round(),
  ];
}

void _paintDots(img.Image image, double origin, double markSize) {
  final center = origin + markSize / 2;
  final u = markSize; // unit scale

  void dot(double cx, double cy, double rUnits) {
    final r = rUnits * u;
    final x0 = (cx - r).floor().clamp(0, image.width - 1);
    final x1 = (cx + r).ceil().clamp(0, image.width - 1);
    final y0 = (cy - r).floor().clamp(0, image.height - 1);
    final y1 = (cy + r).ceil().clamp(0, image.height - 1);
    for (var y = y0; y <= y1; y++) {
      for (var x = x0; x <= x1; x++) {
        final dx = x + 0.5 - cx;
        final dy = y + 0.5 - cy;
        if (dx * dx + dy * dy <= r * r) {
          // Keep dots inside the rounded square (outer diagonal dots sit
          // close to the corner).
          if (!_insideRoundedRect(
              x - origin, y - origin, markSize, u * _radiusFraction)) {
            continue;
          }
          image.setPixelRgba(x, y, 255, 255, 255, 255);
        }
      }
    }
  }

  // Center dot.
  dot(center, center, 0.08);

  // Inner ring of eight dots.
  for (var i = 0; i < 8; i++) {
    final angle = (-90.0 + i * 45.0) * math.pi / 180;
    dot(
      center + math.cos(angle) * 0.24 * u,
      center + math.sin(angle) * 0.24 * u,
      0.055,
    );
  }

  // Four small outer dots on the diagonals.
  for (final angleDeg in const [45.0, 135.0, 225.0, 315.0]) {
    final angle = angleDeg * math.pi / 180;
    dot(
      center + math.cos(angle) * 0.375 * u,
      center + math.sin(angle) * 0.375 * u,
      0.032,
    );
  }
}
