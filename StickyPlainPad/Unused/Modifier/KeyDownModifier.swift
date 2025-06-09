//
//  KeyDownModifier.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 6/9/25.
//

import SwiftUI
import AppKit

struct KeyDownModifier: ViewModifier {
  let onKeyDown: (NSEvent) -> Bool
  
  func body(content: Content) -> some View {
    content
      .background(KeyDownHandler(onKeyDown: onKeyDown))
  }
}

extension View {
  func onKeyDown(perform: @escaping (NSEvent) -> Bool) -> some View {
    modifier(KeyDownModifier(onKeyDown: perform))
  }
}
