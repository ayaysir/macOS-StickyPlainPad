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
  @Binding var theme: Theme?

  func makeNSView(context: Context) -> NSScrollView {
    let textView = ExpandableTextView()
    textView.isEditable = true
    textView.isSelectable = true
    textView.isRichText = false
    textView.allowsUndo = true
    textView.textContainerInset = NSSize(width: 0, height: 4) // ← 패딩 추가
    
    // 테마 적용
    if let theme {
      textView.font = NSFont(name: theme.fontName, size: fontSize)
    } else {
      textView.font = NSFont.systemFont(ofSize: fontSize)
    }
    
    textView.drawsBackground = true
    textView.backgroundColor = .defaultNoteBackground
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
    guard let textView = nsView.documentView as? NSTextView else {
      return
    }
    
    if textView.string != text {
      textView.string = text
    }
    
    if let theme {
      // 🔄 폰트 크기 반영 (폰트명도 포함하여 완전히 새로 설정)
      let newFont = NSFont(name: theme.fontName, size: fontSize) ?? NSFont.systemFont(ofSize: fontSize)
      if textView.font?.fontName != newFont.fontName || textView.font?.pointSize != fontSize {
        textView.font = newFont
      }
      
      // 🔄 배경색 적용
      let newBackgroundColor = NSColor(hex: theme.backgroundColorHex) ?? .textBackgroundColor
      if textView.backgroundColor != newBackgroundColor {
        textView.backgroundColor = newBackgroundColor
      }
      
      // 🔄 텍스트 색상 적용
      let newTextColor = NSColor(hex: theme.textColorHex) ?? .textColor
      if textView.textColor != newTextColor {
        textView.textColor = newTextColor
      }
    } else {
      // 테마가 없을 경우 기본 스타일 적용
      textView.font = NSFont.systemFont(ofSize: fontSize)
      textView.backgroundColor = .defaultNoteBackground
      textView.textColor = .textColor
      
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
  @Previewable @State var theme: Theme? = nil
  
  AutoHidingScrollTextEditor(
    text: $text,
    fontSize: $fontSize,
    theme: $theme
  )
    .frame(width: 400, height: 100)
}

