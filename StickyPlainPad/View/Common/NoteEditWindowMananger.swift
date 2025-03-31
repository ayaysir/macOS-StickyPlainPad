//
//  NoteEditWindowMananger.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 3/31/25.
//

import AppKit
import SwiftUI
import Combine

final class NoteEditWindowMananger {
  static let shared = NoteEditWindowMananger()

  let screenSize = NSScreen.main?.frame ?? .zero
  let windowSize = CGSize(width: 400, height: 300)
  private init() {
    newWindowPos = newWindowPosFirst
  }
  
  var newWindowPosFirst: CGPoint {
    CGPoint(
      x: (screenSize.width - windowSize.width) / 2,
      y: (screenSize.height - windowSize.height) / 2
    )
  }
  
  private(set) var openWindows: [NoteEditWindow] = []
  private var createdWindowCount = 0 {
    didSet {
      let increment = CGFloat(createdWindowCount * 10)
      newWindowPos = CGPoint(
        x: newWindowPosFirst.x + increment,
        y: newWindowPosFirst.y - increment
      )
    }
  }
  private(set) var newWindowPos: CGPoint!
  private var cancellables = Set<AnyCancellable>()
  
  func open(
    noteViewModel: NoteViewModel,
    noteID: UUID,
    previewText: String? = nil
  ) {
    guard !isAlreadyOpened(noteID: noteID) else {
      bringWindowToFront(noteID: noteID)
      addWindowToMenu(noteID: noteID)
      return
    }
    
    // 화면의 중앙에 창 위치 계산
    let windowFrame = CGRect(
      origin: newWindowPos,
      size: windowSize
    )

    // CustomWindow 생성
    let customWindow = NoteEditWindow(
      contentRect: windowFrame,
      styleMask: [.borderless, .fullSizeContentView, .resizable],
      backing: .buffered,
      defer: false
    )

    // CustomWindow 스타일 설정
    customWindow.titlebarAppearsTransparent = true
    customWindow.isMovableByWindowBackground = true
    
    // NoteEditView를 NSHostingView로 감싸서 CustomWindow의 콘텐츠로 설정
    let noteEditView = NoteEditView(
      noteViewModel: noteViewModel,
      noteID: noteID
    )
    
    let hostingView = NSHostingView(rootView: noteEditView)
    hostingView.frame = customWindow.contentView?.bounds ?? .zero
    customWindow.contentView?.addSubview(hostingView)
    customWindow.title = if let previewText {
      previewText
    } else {
      "Note \(noteID)"
    }
     
    customWindow.noteID = noteID
    
    // EXC_BAD_ACCESS 오류 https://stackoverflow.com/a/75341381
    customWindow.isReleasedWhenClosed = false

    // 창을 활성화하고 보이게 하기
    customWindow.makeKeyAndOrderFront(nil)
    // 윈도우 리스트에 등록
    openWindows.append(customWindow)
    
    // windowFrame 정보가 있는 경우 창 위치 조절
    if let windowFrame = noteViewModel.loadWindowFrame(noteID: noteID) {
      customWindow.setFrame(
        windowFrame.toCGRect,
        display: true
      )
    }
    
    registerWindowPublisher(
      customWindow,
      noteViewModel: noteViewModel,
      noteID: noteID
    )
    
    DispatchQueue.main.async {
      self.addWindowToMenu(customWindow)
    }
  }
  
  func addWindowToMenu(noteID: UUID) {
    guard let window = getWindow(noteID: noteID) else {
      return
    }
    
    DispatchQueue.main.async {
      self.addWindowToMenu(window)
    }
  }
  
  func addWindowToMenu(_ window: NoteEditWindow) {
    let menu = NSApplication.shared.menu
    
    guard let windowMenu = menu?.item(withTitle: "Window")?.submenu else {
      return
    }
    
    // 중복 검사
    guard !windowMenu.items.contains(where: { ($0.representedObject as? NoteEditWindow) == window }) else {
      return
    }
    
    let windowItem = NSMenuItem(
      title: window.title,
      action: #selector(switchToWindow(_:)),
      keyEquivalent: ""
    )
    windowItem.target = self
    windowItem.representedObject = window
    
    windowMenu.addItem(windowItem)
  }
  
  func removeWindowMenu(_ window: NoteEditWindow) {
    let menu = NSApplication.shared.menu
    
    guard let windowMenu = menu?.item(withTitle: "Window")?.submenu else {
      return
    }
    
    guard let item = windowMenu.items.first(where: { ($0.representedObject as? NoteEditWindow) == window }) else {
      return
    }
    
    windowMenu.removeItem(item)
  }
  
  @objc func switchToWindow(_ sender: NSMenuItem) {
    guard let window = sender.representedObject as? NoteEditWindow else {
      return
    }
    
    // 해당 윈도우를 활성화
    window.makeKeyAndOrderFront(nil)
  }
  
  private func getWindow(noteID: UUID) -> NoteEditWindow? {
    openWindows.first(where: { $0.noteID == noteID })
  }
  
  private func bringWindowToFront(noteID: UUID) {
    getWindow(noteID: noteID)?.makeKeyAndOrderFront(nil)
  }
  
  private func isAlreadyOpened(noteID: UUID) -> Bool {
    openWindows.contains(where: { $0.noteID == noteID })
  }
  
  private func registerWindowPublisher(
    _ window: NoteEditWindow,
    noteViewModel: NoteViewModel,
    noteID: UUID
  ) {
    window.windowFramePublisher
      .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
      .sink { rect in
        noteViewModel.updateNote(noteID: noteID, windowFrame: rect)
      }
      .store(in: &cancellables)
  }
  
  func appendCreateWindowCount() {
    createdWindowCount += 1
  }
}
