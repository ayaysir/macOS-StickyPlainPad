//
//  WindowPanelUtil.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 4/30/25.
//

import SwiftUI

/// 파일 읽기 대화상자
func openSelectReadFilePanel() -> StringWithURL? {
  let panel = NSOpenPanel()
  panel.allowedContentTypes = [
    .text, // 모든 종류의 텍스트 기반 파일 (source, json, html, 등 포함)
  ]
  panel.allowsMultipleSelection = false
  panel.canChooseDirectories = false

  let response = panel.runModal()
  if response == .OK, let url = panel.url {
    return .init(text: readTextFileAutoEncoding(at: url), url: url)
  }

  return nil
}

/// 저장 대화상자
func openSavePanel(
  _ text: String,
  defaultFileName: String = "Untitled.txt",
  urlCompletionHandler: URLToVoidCallback? = nil
) {
  let panel = NSSavePanel()
  panel.allowedContentTypes = [.plainText]
  panel.nameFieldStringValue = defaultFileName

  panel.begin { response in
    guard response == .OK, let url = panel.url else { return }

    do {
      try saveToURL(text: text, to: url, atomically: true, encoding: .utf8)
      urlCompletionHandler?(url)
    } catch {
      Log.error("Save to file failed: \(error.localizedDescription)")
    }
  }
}

/// 텍스트 인쇄 대화상자
func openPrintPanel(_ text: String, font: NSFont?) {
  let printInfo = NSPrintInfo.shared
  printInfo.horizontalPagination = .automatic
  printInfo.verticalPagination = .automatic
  printInfo.isHorizontallyCentered = true
  printInfo.isVerticallyCentered = false

  let printableWidth = printInfo.paperSize.width
    - printInfo.leftMargin
    - printInfo.rightMargin

  // 레이아웃 구성
  let textStorage = NSTextStorage(string: text)
  let layoutManager = NSLayoutManager()
  let textContainer = NSTextContainer(
    size: NSSize(width: printableWidth, height: .greatestFiniteMagnitude)
  )
  textContainer.widthTracksTextView = true
  layoutManager.addTextContainer(textContainer)
  textStorage.addLayoutManager(layoutManager)

  let textView = NSTextView(frame: .zero, textContainer: textContainer)
  textView.isEditable = false
  textView.font = font
  
  // 레이아웃 강제 계산
  layoutManager.glyphRange(for: textContainer)
  let usedRect = layoutManager.usedRect(for: textContainer)

  // 프레임: 페이지 너비에 맞춰, 높이는 내용 기반
  textView.frame = NSRect(
    x: 0,
    y: 0,
    width: printableWidth,
    height: usedRect.height + 20
  )

  let printOp = NSPrintOperation(view: textView, printInfo: printInfo)
  printOp.showsPrintPanel = true
  printOp.showsProgressPanel = true
  printOp.run()
}

/// 쓰기 권한 체크 (샌드박스 이슈)
func saveWithPanelFallback(text: String, fallbackURL url: URL) -> Bool {
  let fileManager = FileManager.default
  
  // 쓰기 권한이 있는 경우만 저장 시도
  if fileManager.isWritableFile(atPath: url.path) {
    do {
      try text.write(to: url, atomically: true, encoding: .utf8)
      Log.info("✅ 기존 경로에 저장 성공: \(url)")
      return true
    } catch {
      Log.error("⚠️ 기존 경로 저장 실패: \(error.localizedDescription)")
      return false
    }
  }
  
  // 🔁 false인 경우 저장 다이얼로그 호출
  return false
}

/// 윈도우 생성
func openWindow<Content: View>(
  title: String,
  size: CGSize = CGSize(width: 400, height: 300),
  style: NSWindow.StyleMask = [.titled, .closable],
  isReleasedWhenClosed: Bool = false,
  rootView: Content
) {
  let window = NSWindow(
    contentRect: NSRect(origin: .zero, size: size),
    styleMask: style,
    backing: .buffered,
    defer: false
  )
  window.center()
  window.title = title
  window.contentView = NSHostingView(rootView: rootView)
  window.isReleasedWhenClosed = isReleasedWhenClosed
  window.makeKeyAndOrderFront(nil)
}
