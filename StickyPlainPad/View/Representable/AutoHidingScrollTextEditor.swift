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
  @Binding var viewModel: FindReplaceViewModel
  
  @AppStorage(.cfgEditorAutoCopyPaste) private var autoCopyPaste = true
  @AppStorage(.cfgEditorAutoQuotes) private var autoQuotes = false
  @AppStorage(.cfgEditorAutoDashes) private var autoDashes = true
  @AppStorage(.cfgEditorAutoSpelling) private var autoSpelling = false
  @AppStorage(.cfgEditorAutoTextReplacement) private var autoTextReplacement = true
  @AppStorage(.cfgEditorAutoDataDetection) private var autoDataDetection = false
  @AppStorage(.cfgEditorAutoLinkDetection) private var autoLinkDetection = false

  func makeNSView(context: Context) -> NSScrollView {
    let textView = ExpandableTextView()
    textView.isEditable = true
    textView.isSelectable = true
    textView.isRichText = false
    textView.allowsUndo = true
    textView.textContainerInset = NSSize(width: 0, height: 4) // ← 패딩 추가
    
    // AppStorage 값들을 NSTextView에 적용
    textView.smartInsertDeleteEnabled = autoCopyPaste
    textView.isAutomaticQuoteSubstitutionEnabled = autoQuotes
    textView.isAutomaticDashSubstitutionEnabled = autoDashes
    textView.isAutomaticSpellingCorrectionEnabled = autoSpelling
    textView.isAutomaticTextReplacementEnabled = autoTextReplacement
    textView.isAutomaticDataDetectionEnabled = autoDataDetection
    textView.isAutomaticLinkDetectionEnabled = autoLinkDetection
    
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

    // 스크롤 뷰
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
    if viewModel.isSearchWindowPresented, viewModel.resultRanges.count > 0 {
      // 창이 떠 있고, 검색 결과가 1 이상 있을 때
      // applyDimmedStyle(to: textView)
      // textView.alphaValue = 0.4
      highlight(using: viewModel.resultRanges, in: textView)
      textView.isEditable = false
    } else {
      // textView.alphaValue = 1
      textView.isEditable = true
    }
    
    if textView.string != text {
      textView.string = text
    }
    
    // 테마 업데이트
    updateTheme(textView: textView)
    
    // 검색 시 위치 이동
    if viewModel.currentResultRangeIndex < viewModel.resultRanges.count {
      let range = viewModel.resultRanges[viewModel.currentResultRangeIndex]
      textView.scrollRangeToVisible(range)
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
    // let fullRange = NSRange(location: 0, length: (textView.string as NSString).length)

    // 기존 스타일 초기화 (흐리게)
    // textView.textStorage?.setAttributes([
    //   .foregroundColor: NSColor.labelColor.withAlphaComponent(0.3)
    // ], range: fullRange)
    
    let LEAST_OPACITY = 0.45

    // 강조된 부분 다시 설정
    for (index, range) in ranges.enumerated() {
      let isCurrent = index == viewModel.currentResultRangeIndex
      let font = NSFont.boldSystemFont(ofSize: textView.font?.pointSize ?? 12)

      let attributes: [NSAttributedString.Key: Any]

      if let theme, let textColor = NSColor(hex: theme.textColorHex) {
        let color = textColor.invertedColor
        attributes = [
          .foregroundColor: color,
          .backgroundColor: color.withAlphaComponent(isCurrent ? 1 : LEAST_OPACITY),
          .font: font
        ]
      } else {
        attributes = [
          .foregroundColor: NSColor.defaultSelected,
          .backgroundColor: NSColor.defaultSelected.withAlphaComponent(isCurrent ? 1 : LEAST_OPACITY),
          .font: font
        ]
      }

      textView.textStorage?.addAttributes(attributes, range: range)
    }
  }
}

#Preview {
  @Previewable @State var text = "ABCD\n"
  @Previewable @State var fontSize: CGFloat = 14
  @Previewable @State var theme: Theme? = nil
  @Previewable @State var findReplaceViewModel = FindReplaceViewModel()
  
  AutoHidingScrollTextEditor(
    text: $text,
    fontSize: $fontSize,
    theme: $theme,
    viewModel: $findReplaceViewModel
  )
    .frame(width: 400, height: 100)
}

