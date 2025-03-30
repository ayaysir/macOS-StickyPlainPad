//
//  AutoHidingScrollTextEditor.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 3/30/25.
//

import SwiftUI

struct AutoHidingScrollTextEditor: NSViewRepresentable {
  @Binding var text: String

  func makeNSView(context: Context) -> NSScrollView {
    let textView = NSTextView()
    textView.isEditable = true
    textView.isSelectable = true
    textView.isRichText = false
    textView.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
    textView.drawsBackground = true
    textView.backgroundColor = NSColor.textBackgroundColor
    textView.isVerticallyResizable = true
    textView.isHorizontallyResizable = false
    textView.autoresizingMask = .width
    textView.textContainer?.containerSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
    textView.textContainer?.widthTracksTextView = true

    let scrollView = NSScrollView()
    scrollView.documentView = textView
    scrollView.hasVerticalScroller = true
    scrollView.autohidesScrollers = true // 🔥 내용이 많을 때만 스크롤바 표시
    scrollView.borderType = .noBorder
    scrollView.drawsBackground = false
    scrollView.hasHorizontalScroller = false
    scrollView.autoresizingMask = [.width, .height]


    context.coordinator.textView = textView
    textView.delegate = context.coordinator

    return scrollView
  }

  func updateNSView(_ nsView: NSScrollView, context: Context) {
    if let textView = nsView.documentView as? NSTextView {
      if textView.string != text {
        textView.string = text
      }
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject, NSTextViewDelegate {
    var parent: AutoHidingScrollTextEditor
    weak var textView: NSTextView?

    init(_ parent: AutoHidingScrollTextEditor) {
      self.parent = parent
    }

    func textDidChange(_ notification: Notification) {
      if let textView = textView {
        parent.text = textView.string
      }
    }
  }
}

#Preview {
  @Previewable @State var text = "ABCD\n"
  
  AutoHidingScrollTextEditor(text: $text)
    .frame(width: 400, height: 100)
}

