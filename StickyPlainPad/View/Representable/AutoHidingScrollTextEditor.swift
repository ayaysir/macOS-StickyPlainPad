//
//  AutoHidingScrollTextEditor.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 3/30/25.
//

import SwiftUI
import Combine

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
  
  // @State private var isLoadFirstTime = true

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
    textView.textContainer?.containerSize = NSSize(
      width: CGFloat.greatestFiniteMagnitude,
      height: CGFloat.greatestFiniteMagnitude
    )
    textView.textContainer?.widthTracksTextView = true
    
    // 20250425: 렌더링 속도 빠르게 하기 위함
    textView.usesFontPanel = false // 효과 X
    textView.wantsLayer = true // 효과 O?

    // 스크롤 뷰
    let scrollView = NSScrollView()
    scrollView.documentView = textView
    scrollView.hasVerticalScroller = true
    scrollView.autohidesScrollers = true // 🔥 내용이 많을 때만 스크롤바 표시
    scrollView.borderType = .noBorder
    scrollView.drawsBackground = false
    scrollView.hasHorizontalScroller = false
    scrollView.autoresizingMask = [.width, .height]
    
    scrollView.postsBoundsChangedNotifications = true

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
    
    // ⚠️ 이 부분은 영향 없음
    if textView.string != text {
      DispatchQueue.main.async {
        textView.string = text
      }
    }
    
    // 기존 스타일 초기화 <- ❌ 실행되면 안됨 (스크롤 이상 현상)
    // -> 서치 모드일 때만 실행되도록
    // -> 테마 업데이트는 반드시 이부분보다 나중에 실행 (폰트 적용 위해)
    if viewModel.isSearchWindowPresented {
      let fullRange = NSRange(location: 0, length: (textView.string as NSString).length)
      if let theme,
         let labelColor = NSColor(hex: theme.textColorHex) {
        textView.textStorage?.setAttributes([.foregroundColor: labelColor], range: fullRange)
      } else {
        textView.textStorage?.setAttributes([.foregroundColor: NSColor.labelColor], range: fullRange)
      }
    }
    
    // 검색 관련 <- ⚠️ , 대신 && 사용? (기분탓?)
    if viewModel.isSearchWindowPresented && viewModel.resultRanges.count > 0 {
      // 창이 떠 있고, 검색 결과가 1 이상 있을 때
      highlight(using: viewModel.resultRanges, in: textView)
      textView.isEditable = false
    } else if !viewModel.isSearchWindowPresented && !textView.isEditable {
      // ⚠️ 이 부분이 너무 자주 호출되면 안됨 -> else if 조건 추가
      textView.isEditable = true
      Log.debug("text view is editable now")
    }
    
    // 검색 시 위치 이동 <- ⚠️ , 대신 && 사용? (기분탓?)
    if viewModel.isSearchWindowPresented && viewModel.currentResultRangeIndex < viewModel.resultRanges.count {
      let range = viewModel.resultRanges[viewModel.currentResultRangeIndex]
      textView.scrollRangeToVisible(range)
    }
    
    // 테마 업데이트 (영향 없음, 지우면 테마 적용 안됨)
    updateTheme(textView: textView)
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject, NSTextViewDelegate {
    var parent: AutoHidingScrollTextEditor
    weak var textView: NSTextView?
    
    private var cancellable: AnyCancellable?
    private let textSubject = PassthroughSubject<String, Never>()

    init(_ parent: AutoHidingScrollTextEditor) {
      self.parent = parent
      
      super.init()
      
      cancellable = textSubject
        .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
        .sink { [weak self] text in
          self?.parent.text = text
        }
    }

    // ⚠️ 여기가 문제, 호출되고 뭔가 하면 무조건 깨짐
    // ⚠️ updateNSView 문제 해결하면 이 부분 문제 또한 해결됨
    func textDidChange(_ notification: Notification) {
      // if let textView {
      //   parent.text = textView.string
      // }
      
      // 퍼포먼스 향상 위해 debounce 도입
      if let textView {
        textSubject.send(textView.string)
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
      if !viewModel.isSearchWindowPresented, textView.textColor != newTextColor {
        textView.textColor = newTextColor
      }
    } else {
      // 테마가 없을 경우 기본 스타일 적용
      textView.font = NSFont.systemFont(ofSize: fontSize)
      textView.backgroundColor = .defaultNoteBackground
      textView.textColor = .defaultText
      
      // 🔄 폰트 크기 반영
      if let currentFont = textView.font,
          currentFont.pointSize != fontSize {
        textView.font = NSFont(descriptor: currentFont.fontDescriptor, size: fontSize)
      }
    }
  }
  
  private func highlight(using ranges: [NSRange], in textView: NSTextView) {
    let LEAST_OPACITY = 0.7
    
    // 강조된 부분 다시 설정
    for (index, range) in ranges.enumerated() {
      let isCurrent = index == viewModel.currentResultRangeIndex
      let font = NSFont.boldSystemFont(ofSize: textView.font?.pointSize ?? 12)

      let attributes: [NSAttributedString.Key: Any]

      if let theme,
         let backgroundColor = NSColor(hex: theme.backgroundColorHex),
         let textColor = NSColor(hex: theme.textColorHex) {
        let newBGColor = backgroundColor.contrastingColor
        let newTextColor = newBGColor.invertedColor
        
        attributes = [
          .foregroundColor: newTextColor,
          .backgroundColor: newBGColor.withAlphaComponent(isCurrent ? 1 : LEAST_OPACITY),
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

