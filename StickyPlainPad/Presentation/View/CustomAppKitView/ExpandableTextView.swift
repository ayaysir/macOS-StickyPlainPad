//
//  ExpandableTextView.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 4/8/25.
//

import AppKit

class ExpandableTextView: NSTextView {
  var onMagnify: CGFloatToVoidCallback?
  var onKeyboardZoom: CGFloatToVoidCallback?

  override func magnify(with event: NSEvent) {
    super.magnify(with: event)
    let magnification = event.magnification
    onMagnify?(magnification)
  }

  override func keyDown(with event: NSEvent) {
    // ⌘ + / ⌘ -
    if event.modifierFlags.contains(.command) {
      switch event.charactersIgnoringModifiers {
      case "+", "=":
        onKeyboardZoom?(1) // 확대
        return
      case "-", "_":
        onKeyboardZoom?(-1) // 축소
        return
      default:
        break
      }
    }

    super.keyDown(with: event)
  }
}
