//
//  SwiftUI.Color+.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 3/25/25.
//

import SwiftUI

extension Color {
  /// HEX 스트링으로
  func toHex() -> String? {
#if os(macOS)
    guard let components = NSColor(self).cgColor.components, components.count >= 3 else {
      return nil
    }
#else
    guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
      return nil
    }
#endif
    
    let r = Int(components[0] * 255)
    let g = Int(components[1] * 255)
    let b = Int(components[2] * 255)
    
    return String(format: "#%02X%02X%02X", r, g, b)
  }
  
  /// HEX 스트링으로부터 
  init?(hex: String) {
    var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if hexSanitized.hasPrefix("#") {
      hexSanitized.removeFirst()
    }
    
    guard hexSanitized.count == 6, let intVal = Int(hexSanitized, radix: 16) else {
      return nil
    }
    
    let r = Double((intVal >> 16) & 0xFF) / 255.0
    let g = Double((intVal >> 8) & 0xFF) / 255.0
    let b = Double(intVal & 0xFF) / 255.0
    
    self.init(red: r, green: g, blue: b)
  }
  
  /// 배경색에 가장 잘 대비되는 회색 톤 텍스트 색상 반환 (흰색~검정 사이)
  func readableGrayTextColor() -> Color {
    let nsColor = NSColor(self)

    guard let rgbColor = nsColor.usingColorSpace(.sRGB) else {
      return .black
    }

    let red = rgbColor.redComponent
    let green = rgbColor.greenComponent
    let blue = rgbColor.blueComponent

    // W3C 명도 공식
    func linearize(_ component: CGFloat) -> CGFloat {
      return component <= 0.03928 ? (component / 12.92) :
        pow((component + 0.055) / 1.055, 2.4)
    }

    let bgLuminance = 0.2126 * linearize(red)
                    + 0.7152 * linearize(green)
                    + 0.0722 * linearize(blue)

    // 그레이스케일 컬러 중에서 가장 대비가 높은 값 찾기
    var bestGray: CGFloat = 0
    var bestContrast: CGFloat = 0.0

    for gray in stride(from: 0.0, through: 1.0, by: 0.01) {
      let lum = linearize(gray)
      let contrast = (max(bgLuminance, lum) + 0.05) / (min(bgLuminance, lum) + 0.05)

      if contrast > bestContrast {
        bestContrast = contrast
        bestGray = gray
      }
    }

    return Color(white: bestGray)
  }
  
  /// 배경색에 따라 흰색 또는 검은색 중 대비가 가장 잘 되는 텍스트 색상을 반환
  /// https://www.w3.org/TR/WCAG20/#relativeluminancedef
  func readableTextColor() -> Color {
    let nsColor = NSColor(self)

    guard let rgbColor = nsColor.usingColorSpace(.sRGB) else {
      return .black // fallback
    }

    let red = rgbColor.redComponent
    let green = rgbColor.greenComponent
    let blue = rgbColor.blueComponent

    // W3C 권장 명도 공식
    func luminance(_ component: CGFloat) -> CGFloat {
      return (component <= 0.03928) ? (component / 12.92) :
        pow((component + 0.055) / 1.055, 2.4)
    }

    let lum = 0.2126 * luminance(red)
            + 0.7152 * luminance(green)
            + 0.0722 * luminance(blue)

    // 기준은 0.5 근처, 필요시 조절 가능
    return lum > 0.5 ? .black : .white
  }
}
