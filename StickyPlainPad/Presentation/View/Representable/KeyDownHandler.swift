//
//  KeyDownHandler.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 6/9/25.
//

import SwiftUI
import AppKit

struct KeyDownHandler: NSViewRepresentable {
  var onKeyDown: (NSEvent) -> Bool
  
  func makeNSView(context: Context) -> NSView {
    let view = KeyCatcherView()
    view.onKeyDown = onKeyDown
    return view
  }
  
  func updateNSView(_ nsView: NSView, context: Context) {}
  
  class KeyCatcherView: NSView {
    var onKeyDown: ((NSEvent) -> Bool)?
    
    override var acceptsFirstResponder: Bool { true }
    
    override func keyDown(with event: NSEvent) {
      if onKeyDown?(event) != true {
        super.keyDown(with: event)
      }
    }
  }
}
