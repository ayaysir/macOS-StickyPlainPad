//
//  SwiftUI.Color+.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 3/25/25.
//

import SwiftUI

extension Color {
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
}
