import AppKit
import CoreGraphics
import Foundation

func renderAppIcon(canvasSize: CGFloat = 1024) -> NSImage {
    let img = NSImage(size: NSSize(width: canvasSize, height: canvasSize))
    img.lockFocus()
    guard let ctx = NSGraphicsContext.current?.cgContext else {
        img.unlockFocus()
        return img
    }

    ctx.setAllowsAntialiasing(true)
    ctx.setShouldAntialias(true)

    // Sizing for macOS Big Sur squircle within 1024 canvas
    let iconSize: CGFloat = canvasSize * 0.82
    let originOffset: CGFloat = (canvasSize - iconSize) / 2.0
    let cornerRadius: CGFloat = iconSize * 0.225
    let iconRect = CGRect(x: originOffset, y: originOffset, width: iconSize, height: iconSize)

    // Shadow
    ctx.saveGState()
    let shadowColor = NSColor(calibratedRed: 0.0, green: 0.15, blue: 0.45, alpha: 0.35).cgColor
    ctx.setShadow(offset: CGSize(width: 0, height: -canvasSize * 0.025), blur: canvasSize * 0.045, color: shadowColor)

    let squirclePath = CGPath(roundedRect: iconRect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
    ctx.addPath(squirclePath)
    ctx.setFillColor(NSColor(calibratedRed: 0.0, green: 0.4, blue: 0.9, alpha: 1.0).cgColor)
    ctx.fillPath()
    ctx.restoreGState()

    // Draw Gradient inside squircle
    ctx.saveGState()
    ctx.addPath(squirclePath)
    ctx.clip()

    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let startColor = NSColor(calibratedRed: 58.0 / 255.0, green: 157.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0).cgColor
    let endColor = NSColor(calibratedRed: 0.0 / 255.0, green: 103.0 / 255.0, blue: 230.0 / 255.0, alpha: 1.0).cgColor
    let colors = [startColor, endColor] as CFArray
    let locations: [CGFloat] = [0.0, 1.0]

    if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) {
        ctx.drawLinearGradient(
            gradient,
            start: CGPoint(x: originOffset, y: originOffset + iconSize),
            end: CGPoint(x: originOffset + iconSize, y: originOffset),
            options: []
        )
    }

    // Inner subtle glow/gradient overlay
    let glowStart = NSColor(white: 1.0, alpha: 0.25).cgColor
    let glowEnd = NSColor(white: 1.0, alpha: 0.0).cgColor
    if let glowGradient = CGGradient(colorsSpace: colorSpace, colors: [glowStart, glowEnd] as CFArray, locations: [0.0, 0.7]) {
        ctx.drawRadialGradient(
            glowGradient,
            startCenter: CGPoint(x: iconRect.midX, y: iconRect.midY + iconSize * 0.15),
            startRadius: 0,
            endCenter: CGPoint(x: iconRect.midX, y: iconRect.midY),
            endRadius: iconSize * 0.6,
            options: []
        )
    }

    // Border
    let borderPath = CGPath(roundedRect: iconRect.insetBy(dx: 1, dy: 1), cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
    ctx.addPath(borderPath)
    ctx.setStrokeColor(NSColor(white: 1.0, alpha: 0.35).cgColor)
    ctx.setLineWidth(canvasSize * 0.0035)
    ctx.strokePath()

    // Draw Iris Aperture
    let center = CGPoint(x: iconRect.midX, y: iconRect.midY)
    let irisRadius = iconSize * 0.42

    // Outer thin circle ring
    ctx.setStrokeColor(NSColor(white: 1.0, alpha: 0.3).cgColor)
    ctx.setLineWidth(irisRadius * 0.08)
    ctx.addArc(center: center, radius: irisRadius * 0.76, startAngle: 0, endAngle: .pi * 2, clockwise: true)
    ctx.strokePath()

    // 8 Aperture dots
    let dotCount = 8
    for i in 0..<dotCount {
        let angle = (CGFloat(i) * 2.0 * .pi / CGFloat(dotCount)) - (.pi / 2.0)
        let dotCenter = CGPoint(
            x: center.x + cos(angle) * (irisRadius * 0.52),
            y: center.y + sin(angle) * (irisRadius * 0.52)
        )
        ctx.setFillColor(NSColor.white.cgColor)
        ctx.addArc(center: dotCenter, radius: irisRadius * 0.09, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        ctx.fillPath()
    }

    // 4 Sparkle dots
    for i in 0..<4 {
        let angle = (CGFloat(i) * .pi / 2.0) + (.pi / 4.0)
        let sparkleCenter = CGPoint(
            x: center.x + cos(angle) * (irisRadius * 0.74),
            y: center.y + sin(angle) * (irisRadius * 0.74)
        )
        ctx.setFillColor(NSColor(white: 1.0, alpha: 0.92).cgColor)
        ctx.addArc(center: sparkleCenter, radius: irisRadius * 0.055, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        ctx.fillPath()
    }

    // Central pupil
    ctx.setFillColor(NSColor.white.cgColor)
    ctx.addArc(center: center, radius: irisRadius * 0.14, startAngle: 0, endAngle: .pi * 2, clockwise: true)
    ctx.fillPath()

    ctx.restoreGState()

    img.unlockFocus()
    return img
}

func savePNG(image: NSImage, size: Int, destinationURL: URL) {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: size,
        pixelsHigh: size,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!
    rep.size = NSSize(width: size, height: size)

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    image.draw(in: NSRect(x: 0, y: 0, width: size, height: size), from: .zero, operation: .copy, fraction: 1.0)
    NSGraphicsContext.restoreGraphicsState()

    if let pngData = rep.representation(using: .png, properties: [:]) {
        try? pngData.write(to: destinationURL)
        print("Generated: \(destinationURL.lastPathComponent) (\(size)x\(size))")
    }
}

let master = renderAppIcon(canvasSize: 1024)
let targetDir = URL(fileURLWithPath: CommandLine.arguments[1])

let sizes = [
    (16, "app_icon_16.png"),
    (32, "app_icon_32.png"),
    (64, "app_icon_64.png"),
    (128, "app_icon_128.png"),
    (256, "app_icon_256.png"),
    (512, "app_icon_512.png"),
    (1024, "app_icon_1024.png"),
]

for (size, filename) in sizes {
    let url = targetDir.appendingPathComponent(filename)
    savePNG(image: master, size: size, destinationURL: url)
}

print("AppIcon generation complete!")
