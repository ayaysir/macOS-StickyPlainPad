//
//  NoteEditWindow.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 3/31/25.
//

import AppKit
import SwiftUI
import Combine

class NoteEditWindow: NSWindow  {
  /*
   타이틀바를 제거하면 메인 윈도우가 안되기 때문에 억지로 key, main 윈도우로 만든다
   */
  override var canBecomeKey: Bool {
    return true
  }

  override var canBecomeMain: Bool {
    return true
  }
  
  var noteID: UUID?
  var windowFramePublisher = PassthroughSubject<Rect, Never>()
  
  override init(
    contentRect: NSRect,
    styleMask style: NSWindow.StyleMask,
    backing backingStoreType: NSWindow.BackingStoreType,
    defer flag: Bool
  ) {
    super.init(
      contentRect: contentRect,
      styleMask: style,
      backing: backingStoreType,
      defer: flag
    )
    
    delegate = self
  }
}

extension NoteEditWindow: NSWindowDelegate {
  func windowDidResize(_ notification: Notification) {
    // 내용 뷰(NSHostingView)의 크기를 창 크기에 맞게 조정
    if let hostingView = contentView?.subviews.first(where: { $0 is NSHostingView<NoteEditView> }) {
      hostingView.frame = contentView?.bounds ?? .zero
    }
    
    // 창 크기 정보 내보내기
    guard let windowFrame = Rect(cgRect: frame) else {
      return
    }
    
    windowFramePublisher.send(windowFrame)
  }
  
  func windowDidMove(_ notification: Notification) {
    // 창 위치 정보 내보내기
    guard let windowFrame = Rect(cgRect: frame) else {
      return
    }
    
    windowFramePublisher.send(windowFrame)
  }
}
