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
  @Bindable var frViewModel: FindReplaceViewModel
  @Bindable var neViewModel: NoteEditViewModel
  
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
      if let postScriptName = theme.fontMember?.postScriptName {
        textView.font = NSFont(name: postScriptName, size: fontSize) ?? NSFont.systemFont(ofSize: fontSize)
      } else {
        textView.font = NSFont(name: theme.fontName, size: fontSize) ?? NSFont.systemFont(ofSize: fontSize)
      }
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
      if frViewModel.isReplaceAreaPresented,
         let undoManager = textView.undoManager {
        let oldText = textView.string
        
        undoManager.registerUndo(withTarget: textView) { target in
          target.string = oldText
          DispatchQueue.main.async {
            frViewModel.text = oldText
            text = oldText
          }
        }
        
        undoManager.setActionName("Replace")
        
        textView.string = text
        highlight(using: frViewModel.resultRanges, in: textView)
      } else {
        // text가 바뀌었다면 textView.string 업데이트
        DispatchQueue.main.async {
          textView.string = text
        }
      }
    }
    
    if frViewModel.isSearchWindowPresented {
      // 기존 스타일 초기화 <- ❌ 실행되면 안됨 (스크롤 이상 현상)
      // -> 서치 모드일 때만 실행되도록
      // -> 테마 업데이트는 반드시 이부분보다 나중에 실행 (폰트 적용 위해)
      resetAllStorageAttributes(textView: textView)
    }
    
    if frViewModel.isSearchOrReplaceCompletedOnce {
      resetAllStorageAttributes(textView: textView)
      frViewModel.isSearchOrReplaceCompletedOnce = false
    }
    
    // 검색 관련 <- ⚠️ , 대신 && 사용? (기분탓?)
    if frViewModel.isSearchWindowPresented && frViewModel.resultRanges.count > 0 {
      // 창이 떠 있고, 검색 결과가 1 이상 있을 때
      highlight(using: frViewModel.resultRanges, in: textView)
      textView.isEditable = false
    } else if !frViewModel.isSearchWindowPresented && !textView.isEditable {
      // ⚠️ 이 부분이 너무 자주 호출되면 안됨 -> else if 조건 추가
      textView.isEditable = true
      Log.debug("text view is editable now")
    }
    
    // 검색 시 위치 이동 <- ⚠️ , 대신 && 사용? (기분탓?)
    if frViewModel.isSearchWindowPresented && frViewModel.currentResultRangeIndex < frViewModel.resultRanges.count {
      let range = frViewModel.resultRanges[frViewModel.currentResultRangeIndex]
      textView.scrollRangeToVisible(range)
    }
    
    // 특정 텍스트 삽입
    if let insertText = neViewModel.pendingInsertText {
      insertTextToCurrentCursor(textView: textView, insertText: insertText)
      neViewModel.pendingInsertText = nil
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
      if let postScriptName = theme.fontMember?.postScriptName {
        let newFont = NSFont(name: postScriptName, size: fontSize) ?? NSFont.systemFont(ofSize: fontSize)
        if textView.font?.fontName != postScriptName || textView.font?.pointSize != fontSize {
          textView.font = newFont
        }
      } else {
        let newFont = NSFont(name: theme.fontName, size: fontSize) ?? NSFont.systemFont(ofSize: fontSize)
        if textView.font?.fontName != theme.fontName || textView.font?.pointSize != fontSize {
          textView.font = newFont
        }
      }
      
      // 🔄 배경색 적용
      let newBackgroundColor = NSColor(hex: theme.backgroundColorHex) ?? .textBackgroundColor
      if textView.backgroundColor != newBackgroundColor {
        textView.backgroundColor = newBackgroundColor
      }
      
      // 🔄 텍스트 색상 적용
      let newTextColor = NSColor(hex: theme.textColorHex) ?? .textColor
      if !frViewModel.isSearchWindowPresented, textView.textColor != newTextColor {
        textView.textColor = newTextColor
      }
    } else {
      // 테마가 없을 경우 기본 스타일 적용
      // 20250430: 기본 테마에서 텍스트 뷰 문제 있어서 이전 배경, 텍스트 색과 비교하는 로직 추가
      
      // 🔄 폰트 크기 반영
      if let currentFont = textView.font,
          currentFont.pointSize != fontSize {
        textView.font = NSFont(descriptor: currentFont.fontDescriptor, size: fontSize)
      }
      
      if textView.backgroundColor != .defaultNoteBackground {
        textView.backgroundColor = .defaultNoteBackground
      }
      
      if textView.textColor != .defaultText {
        textView.textColor = .defaultText
      }
    }
  }
  
  private func highlight(using ranges: [NSRange], in textView: NSTextView) {
    let LEAST_OPACITY = 0.7
    
    // 강조된 부분 다시 설정
    if let textStorage = textView.textStorage {
      let maxLength = textStorage.length
      
      for (index, range) in ranges.enumerated() {
        guard range.location >= 0,
              range.location + range.length <= maxLength
        else {
          Log.warning("❗️하이라이트 범위 초과: \(range), 텍스트 길이: \(maxLength)")
          continue
        }
        
        let isCurrent = index == frViewModel.currentResultRangeIndex
        let font = NSFont.boldSystemFont(ofSize: textView.font?.pointSize ?? 12)
        let attributes: [NSAttributedString.Key : Any]
        
        if let theme,
           let backgroundColor = NSColor(hex: theme.backgroundColorHex) {
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
   
        textStorage.addAttributes(attributes, range: range)
      }
    }
    
    // for (index, range) in ranges.enumerated() {
    //   let isCurrent = index == viewModel.currentResultRangeIndex
    //   let font = NSFont.boldSystemFont(ofSize: textView.font?.pointSize ?? 12)
   
    //   let attributes: [NSAttributedString.Key: Any]
   
    //   if let theme, let backgroundColor = NSColor(hex: theme.backgroundColorHex) {
    //     let newBGColor = backgroundColor.contrastingColor
    //     let newTextColor = newBGColor.invertedColor
    //     
    //     attributes = [
    //       .foregroundColor: newTextColor,
    //       .backgroundColor: newBGColor.withAlphaComponent(isCurrent ? 1 : LEAST_OPACITY),
    //       .font: font
    //     ]
    //   } else {
    //     attributes = [
    //       .foregroundColor: NSColor.defaultSelected,
    //       .backgroundColor: NSColor.defaultSelected.withAlphaComponent(isCurrent ? 1 : LEAST_OPACITY),
    //       .font: font
    //     ]
    //   }
   
    //   textView.textStorage?.addAttributes(attributes, range: range)
    // }
  }
  
  func resetAllStorageAttributes(textView: NSTextView) {
    guard let textStorage = textView.textStorage else {
      return
    }
    
    let fullRange = NSRange(location: 0, length: textStorage.length)
    
    // 속도 개선
    let color = theme.flatMap { NSColor(hex: $0.textColorHex) } ?? .labelColor
    textStorage.beginEditing()
    textStorage.setAttributes([.foregroundColor: color], range: fullRange)
    textStorage.endEditing()
    
    // if let theme,
    //    let labelColor = NSColor(hex: theme.textColorHex) {
    //   textView.textStorage?.setAttributes([.foregroundColor: labelColor], range: fullRange)
    // } else {
    //   textView.textStorage?.setAttributes([.foregroundColor: NSColor.labelColor], range: fullRange)
    // }
  }
  
  func insertTextToCurrentCursor(textView: NSTextView, insertText: String) {
    let range = textView.selectedRange()
    
    if let undoManager = textView.undoManager {
      let oldText = textView.string
      
      undoManager.registerUndo(withTarget: textView) { target in
        target.string = oldText
        target.setSelectedRange(range)
        DispatchQueue.main.async {
          frViewModel.text = oldText
        }
      }
      undoManager.setActionName("Insert Text")
    }
    
    // 실제 삽입
    textView.insertText(insertText, replacementRange: range)
    DispatchQueue.main.async {
      text = textView.string
      frViewModel.text = textView.string
    }

    // 커서를 삽입된 텍스트 뒤로 이동
    let newCursorPosition = range.location + (insertText as NSString).length
    textView.setSelectedRange(NSRange(location: newCursorPosition, length: 0))
  }
}

#Preview {
  @Previewable @State var text = "ABCD\n"
  @Previewable @State var fontSize: CGFloat = 14
  @Previewable @State var theme: Theme? = nil
  @Previewable @Bindable var findReplaceViewModel = FindReplaceViewModel()
  @Previewable @Bindable var noteEditViewModel = NoteEditViewModel()
  
  AutoHidingScrollTextEditor(
    text: $text,
    fontSize: $fontSize,
    theme: $theme,
    frViewModel: findReplaceViewModel,
    neViewModel: noteEditViewModel
  )
    .frame(width: 400, height: 100)
}

