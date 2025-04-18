//
//  AppKit.NSColor+.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 4/15/25.
//

import AppKit

extension NSColor {
  convenience init?(hex: String) {
    var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
    if hex.hasPrefix("#") {
      hex.removeFirst()
    }

    guard let hexNumber = UInt64(hex, radix: 16) else {
      return nil
    }

    let r, g, b, a: CGFloat

    switch hex.count {
    case 6: // RGB (hex: #RRGGBB)
      r = CGFloat((hexNumber & 0xFF0000) >> 16) / 255
      g = CGFloat((hexNumber & 0x00FF00) >> 8) / 255
      b = CGFloat(hexNumber & 0x0000FF) / 255
      a = 1.0
    case 8: // ARGB (hex: #AARRGGBB)
      a = CGFloat((hexNumber & 0xFF000000) >> 24) / 255
      r = CGFloat((hexNumber & 0x00FF0000) >> 16) / 255
      g = CGFloat((hexNumber & 0x0000FF00) >> 8) / 255
      b = CGFloat(hexNumber & 0x000000FF) / 255
    default:
      return nil
    }

    self.init(red: r, green: g, blue: b, alpha: a)
  }
  
  /// 이 색상과 대비되는 색상 (흰색 또는 검정색) 반환
  var contrastingColor: NSColor {
    let rgbColor = usingColorSpace(.sRGB) ?? self
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0

    rgbColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

    // 밝기 계산 (sRGB 기준 상대 밝기)
    let brightness = (0.299 * red + 0.587 * green + 0.114 * blue)

    return brightness > 0.5 ? .black : .white
  }
  
  /// 이 색상의 반전 색상 반환
  var invertedColor: NSColor {
    let rgbColor = usingColorSpace(.sRGB) ?? self

    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0

    rgbColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

    return NSColor(red: 1.0 - red,
                   green: 1.0 - green,
                   blue: 1.0 - blue,
                   alpha: alpha)
  }
}
