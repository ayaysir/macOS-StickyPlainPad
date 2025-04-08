//
//  AutoHidingScrollTextEditor.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 3/30/25.
//

import SwiftUI

struct AutoHidingScrollTextEditor: NSViewRepresentable {
  @Binding var text: String
  @Binding var fontSize: CGFloat

  func makeNSView(context: Context) -> NSScrollView {
    let textView = ExpandableTextView()
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
    
    let MIN_FONT_SIZE: CGFloat = 8
    let MAX_FONT_SIZE: CGFloat = 104
    
    // 🪄 트랙패드 줌 이벤트
    textView.onMagnify = { magnification in
      let newSize = max(
        MIN_FONT_SIZE,
        min(MAX_FONT_SIZE, fontSize * (1 + magnification))
      )
      
      DispatchQueue.main.async {
        fontSize = newSize
      }
    }
    
    // ⌨️ 키보드 줌 이벤트
    textView.onKeyboardZoom = { delta in
      let newSize = max(
        MIN_FONT_SIZE,
        min(MAX_FONT_SIZE, fontSize + delta)
      )
      
      DispatchQueue.main.async {
        fontSize = newSize
      }
    }

    return scrollView
  }

  func updateNSView(_ nsView: NSScrollView, context: Context) {
    if let textView = nsView.documentView as? NSTextView {
      if textView.string != text {
        textView.string = text
      }
      
      // 🔄 폰트 크기 반영
      if let currentFont = textView.font,
          currentFont.pointSize != fontSize {
        textView.font = NSFont(descriptor: currentFont.fontDescriptor, size: fontSize)
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
      if let textView {
        parent.text = textView.string
      }
    }
  }
}

#Preview {
  @Previewable @State var text = "ABCD\n"
  @Previewable @State var fontSize: CGFloat = 14
  
  AutoHidingScrollTextEditor(text: $text, fontSize: $fontSize)
    .frame(width: 400, height: 100)
}

