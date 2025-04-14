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
}
