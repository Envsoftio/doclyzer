import AppKit
import Foundation
import ImageIO
import UniformTypeIdentifiers

// Run from apps/mobile: swift scripts/generate_app_icons.swift
let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
let fullLogoSource = root.appendingPathComponent("assets/branding/512_512-Full.svg")
let appMarkSource = root.appendingPathComponent("assets/branding/512_512.svg")
guard let fullLogo = NSImage(contentsOf: fullLogoSource),
      let appMark = NSImage(contentsOf: appMarkSource) else {
  fatalError("Cannot open branding SVGs")
}

// Android status icons are alpha masks: color and the white SVG background must go.
let notificationSvg = try String(contentsOf: appMarkSource, encoding: .utf8)
  .replacingOccurrences(of: #"<rect\b[^>]*/>"#, with: "", options: .regularExpression)
  .replacingOccurrences(of: "fill=\"#[0-9A-Fa-f]{6}\"", with: "fill=\"white\"", options: .regularExpression)
guard let notificationMark = NSImage(data: Data(notificationSvg.utf8)),
      !notificationSvg.contains("<rect"),
      !notificationSvg.contains("fill=\"#") else {
  fatalError("Cannot create monochrome notification icon")
}

func writeIcon(_ path: String, size: Int, image: NSImage, artworkFraction: CGFloat = 1, transparent: Bool = false) throws {
  guard let bitmap = NSBitmapImageRep(
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
  ), let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
    fatalError("Cannot create \(size)x\(size) bitmap")
  }

  NSGraphicsContext.saveGraphicsState()
  NSGraphicsContext.current = context
  context.imageInterpolation = .high
  if (!transparent) {
    NSColor.white.setFill()
    NSRect(x: 0, y: 0, width: size, height: size).fill()
  }
  let artworkSize = CGFloat(size) * artworkFraction
  let inset = (CGFloat(size) - artworkSize) / 2
  image.draw(
    in: NSRect(x: inset, y: inset, width: artworkSize, height: artworkSize),
    from: NSRect(origin: .zero, size: image.size),
    operation: .sourceOver,
    fraction: 1
  )
  context.flushGraphics()
  NSGraphicsContext.restoreGraphicsState()

  let destination = root.appendingPathComponent(path)
  try FileManager.default.createDirectory(at: destination.deletingLastPathComponent(), withIntermediateDirectories: true)
  if transparent {
    guard let data = bitmap.representation(using: .png, properties: [:]) else {
      fatalError("Cannot encode PNG")
    }
    try data.write(to: destination)
  } else {
    // App Store icons must be RGB PNGs without an alpha channel.
    guard let opaqueContext = CGContext(
      data: nil,
      width: size,
      height: size,
      bitsPerComponent: 8,
      bytesPerRow: 0,
      space: CGColorSpaceCreateDeviceRGB(),
      bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
    ), let sourceImage = bitmap.cgImage,
      let pngDestination = CGImageDestinationCreateWithURL(destination as CFURL, UTType.png.identifier as CFString, 1, nil) else {
      fatalError("Cannot create RGB PNG")
    }
    opaqueContext.draw(sourceImage, in: CGRect(x: 0, y: 0, width: size, height: size))
    guard let opaqueImage = opaqueContext.makeImage() else { fatalError("Cannot flatten icon") }
    CGImageDestinationAddImage(pngDestination, opaqueImage, nil)
    guard CGImageDestinationFinalize(pngDestination) else { fatalError("Cannot write RGB PNG") }
  }
}

let iosDir = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
let iosIcons: [(String, Int)] = [
  ("Icon-App-20x20@1x.png", 20), ("Icon-App-20x20@2x.png", 40), ("Icon-App-20x20@3x.png", 60),
  ("Icon-App-29x29@1x.png", 29), ("Icon-App-29x29@2x.png", 58), ("Icon-App-29x29@3x.png", 87),
  ("Icon-App-40x40@1x.png", 40), ("Icon-App-40x40@2x.png", 80), ("Icon-App-40x40@3x.png", 120),
  ("Icon-App-60x60@2x.png", 120), ("Icon-App-60x60@3x.png", 180),
  ("Icon-App-76x76@1x.png", 76), ("Icon-App-76x76@2x.png", 152),
  ("Icon-App-83.5x83.5@2x.png", 167), ("Icon-App-1024x1024@1x.png", 1024),
]
for (name, size) in iosIcons {
  try writeIcon("\(iosDir)/\(name)", size: size, image: fullLogo)
}

// Flutter screens use the same symbol as the Android launcher and system splash.
try writeIcon("assets/branding/app_mark.png", size: 512, image: appMark, transparent: true)

let androidDensities: [(String, Int)] = [
  ("mdpi", 48), ("hdpi", 72), ("xhdpi", 96), ("xxhdpi", 144), ("xxxhdpi", 192),
]
for (density, size) in androidDensities {
  try writeIcon("android/app/src/main/res/mipmap-\(density)/ic_launcher.png", size: size, image: appMark, artworkFraction: 0.9)
  // The adaptive icon and Android 12 splash mask the foreground to a circle.
  try writeIcon("android/app/src/main/res/drawable-\(density)/ic_launcher_foreground.png", size: size * 9 / 4, image: appMark, artworkFraction: 0.68, transparent: true)
  try writeIcon("android/app/src/main/res/drawable-\(density)/ic_launcher_monochrome.png", size: size * 9 / 4, image: notificationMark, artworkFraction: 0.68, transparent: true)
  try writeIcon("android/app/src/main/res/drawable-\(density)/ic_stat_doclyzer.png", size: size / 2, image: notificationMark, transparent: true)
}
