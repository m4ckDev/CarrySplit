import AppKit
import Foundation

let arguments = CommandLine.arguments

guard arguments.count == 2 else {
    fputs("Usage: swift generate_app_icon.swift <output-png>\n", stderr)
    exit(2)
}

let outputURL = URL(fileURLWithPath: arguments[1])
let size = NSSize(width: 1024, height: 1024)
let image = NSImage(size: size)

image.lockFocus()

guard let context = NSGraphicsContext.current?.cgContext else {
    fputs("Unable to obtain drawing context.\n", stderr)
    exit(3)
}

context.setFillColor(NSColor(calibratedRed: 0.07, green: 0.11, blue: 0.19, alpha: 1).cgColor)
context.fill(CGRect(origin: .zero, size: CGSize(width: 1024, height: 1024)))

let strokeColor = NSColor(calibratedWhite: 1.0, alpha: 0.96)
strokeColor.setStroke()

func drawBranch(from start: NSPoint, to merge: NSPoint, control1: NSPoint, control2: NSPoint) {
    let path = NSBezierPath()
    path.move(to: start)
    path.curve(to: merge, controlPoint1: control1, controlPoint2: control2)
    path.lineWidth = 58
    path.lineCapStyle = .round
    path.lineJoinStyle = .round
    path.stroke()
}

func drawLine(from start: NSPoint, to end: NSPoint) {
    let path = NSBezierPath()
    path.move(to: start)
    path.line(to: end)
    path.lineWidth = 58
    path.lineCapStyle = .round
    path.stroke()
}

let upperStart = NSPoint(x: 244, y: 700)
let lowerStart = NSPoint(x: 244, y: 324)
let merge = NSPoint(x: 565, y: 512)
let end = NSPoint(x: 790, y: 512)

drawBranch(
    from: upperStart,
    to: merge,
    control1: NSPoint(x: 390, y: 700),
    control2: NSPoint(x: 440, y: 548)
)

drawBranch(
    from: lowerStart,
    to: merge,
    control1: NSPoint(x: 390, y: 324),
    control2: NSPoint(x: 440, y: 476)
)

drawLine(from: merge, to: end)

func drawEndpoint(center: NSPoint, radius: CGFloat) {
    let rect = NSRect(
        x: center.x - radius,
        y: center.y - radius,
        width: radius * 2,
        height: radius * 2
    )
    let circle = NSBezierPath(ovalIn: rect)
    strokeColor.setFill()
    circle.fill()
}

drawEndpoint(center: upperStart, radius: 34)
drawEndpoint(center: lowerStart, radius: 34)
drawEndpoint(center: end, radius: 42)

image.unlockFocus()

guard
    let tiff = image.tiffRepresentation,
    let bitmap = NSBitmapImageRep(data: tiff),
    let png = bitmap.representation(using: .png, properties: [:])
else {
    fputs("Unable to encode icon as PNG.\n", stderr)
    exit(4)
}

try FileManager.default.createDirectory(
    at: outputURL.deletingLastPathComponent(),
    withIntermediateDirectories: true
)
try png.write(to: outputURL)

print("Generated \(outputURL.path)")
