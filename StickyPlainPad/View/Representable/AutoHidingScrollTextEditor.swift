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
  @Binding var findAndReplaceViewModel: FindAndReplaceViewModel

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
    
    // 기존 스타일 초기화
    let fullRange = NSRange(location: 0, length: (textView.string as NSString).length)
    textView.textStorage?.setAttributes([.foregroundColor: NSColor.labelColor], range: fullRange)
    
    // 검색 관련
    if findAndReplaceViewModel.isSearchWindowPresented, findAndReplaceViewModel.resultRanges.count > 0 {
      // 창이 떠 있고, 검색 결과가 1 이상 있을 때
      // applyDimmedStyle(to: textView)
      // textView.alphaValue = 0.4
      highlight(using: findAndReplaceViewModel.resultRanges, in: textView)
    } else {
      // textView.alphaValue = 1
    }
    
    if textView.string != text {
      textView.string = text
    }
    
    // 테마 업데이트
    updateTheme(textView: textView)
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

extension AutoHidingScrollTextEditor {
  func updateTheme(textView: NSTextView) {
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
  
  func applyDimmedStyle(to textView: NSTextView) {
    let fullRange = NSRange(location: 0, length: textView.string.utf16.count)
    let dimmedAttributes: [NSAttributedString.Key: Any] = [
      .foregroundColor: NSColor.labelColor.withAlphaComponent(0.3)
    ]
    textView.textStorage?.addAttributes(dimmedAttributes, range: fullRange)
  }
  
  
  private func highlight(using ranges: [NSRange], in textView: NSTextView) {
    let fullRange = NSRange(location: 0, length: (textView.string as NSString).length)

    // 기존 스타일 초기화 (흐리게)
    textView.textStorage?.setAttributes([
      .foregroundColor: NSColor.labelColor.withAlphaComponent(0.3)
    ], range: fullRange)

    // 강조된 부분 다시 설정
    
    for range in ranges {
      if let theme, let textColor = NSColor(hex: theme.textColorHex) {
        textView.textStorage?.addAttributes([
          .foregroundColor: textColor.invertedColor,
          .backgroundColor: textColor.invertedColor.withAlphaComponent(0.7),
          .font: NSFont.boldSystemFont(ofSize: textView.font?.pointSize ?? 12)
        ], range: range)
      } else {
        textView.textStorage?.addAttributes([
          .foregroundColor: NSColor.systemYellow,
          .backgroundColor: NSColor.systemOrange.withAlphaComponent(0.5),
          .font: NSFont.boldSystemFont(ofSize: textView.font?.pointSize ?? 12)
        ], range: range)
      }
    }
  }
}

#Preview {
  @Previewable @State var text = "ABCD\n"
  @Previewable @State var fontSize: CGFloat = 14
  @Previewable @State var theme: Theme? = nil
  @Previewable @State var findAndReplaceViewModel = FindAndReplaceViewModel()
  
  AutoHidingScrollTextEditor(
    text: $text,
    fontSize: $fontSize,
    theme: $theme,
    findAndReplaceViewModel: $findAndReplaceViewModel
  )
    .frame(width: 400, height: 100)
}

