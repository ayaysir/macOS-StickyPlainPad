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
  
  var keyWindow: NoteEditWindow? {
    NSApplication.shared.keyWindow as? NoteEditWindow
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
  
  func addNewNoteAndOpen(
    noteViewModel: NoteViewModel,
    themeViewModel: ThemeViewModel,
    content: String = ""
  ) {
    withAnimation {
      let note = noteViewModel.addNewNote(content: content)
      appendCreateWindowCount()
      
      open(
        noteViewModel: noteViewModel,
        themeViewModel: themeViewModel,
        note: note,
        previewText: !content.isEmpty ? content.truncated() : nil
      )
    }
  }
  
  func open(
    noteViewModel: NoteViewModel,
    themeViewModel: ThemeViewModel,
    note: Note,
    previewText: String? = nil
  ) {
    guard !isAlreadyOpened(noteID: note.id) else {
      bringWindowToFront(noteID: note.id)
      addWindowToMenu(noteID: note.id)
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
    
    // NoteEditView를 열기 전에 먼저 윈도우 오픈 상태 업데이트
    let note = noteViewModel.updateNote(note, isWindowOpened: true)
    
    // NoteEditView를 NSHostingView로 감싸서 CustomWindow의 콘텐츠로 설정
    let noteEditView = NoteEditView(
      noteViewModel: noteViewModel,
      themeViewModel: themeViewModel,
      note: note
    )
    
    let hostingView = NSHostingView(rootView: noteEditView)
    hostingView.frame = customWindow.contentView?.bounds ?? .zero
    customWindow.contentView?.addSubview(hostingView)
    customWindow.title = if let previewText {
      previewText.truncated()
    } else {
      "Note \(note.id)"
    }
     
    customWindow.noteID = note.id
    
    // EXC_BAD_ACCESS 오류 https://stackoverflow.com/a/75341381
    customWindow.isReleasedWhenClosed = false

    // 창을 활성화하고 보이게 하기
    customWindow.makeKeyAndOrderFront(nil)
    // 윈도우 리스트에 등록
    openWindows.append(customWindow)
    
    // windowFrame 정보가 있는 경우 창 위치 조절
    if let windowFrame = noteViewModel.loadWindowFrame(note: note) {
      customWindow.setFrame(
        windowFrame.toCGRect,
        display: true
      )
    }
    
    // isPinned 여부에 따라 플로팅 레벨 조절
    customWindow.level = note.isPinned ? .floating : .normal
    
    registerWindowPublisher(
      customWindow,
      noteViewModel: noteViewModel,
      note: note
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
  
  func updateWindowsOpenStatus(
    noteViewModel: NoteViewModel,
    note: Note,
    isWindowOpened: Bool
  ) -> Note {
    noteViewModel.updateNote(note, isWindowOpened: isWindowOpened)
  }
  
  @objc func switchToWindow(_ sender: NSMenuItem) {
    guard let window = sender.representedObject as? NoteEditWindow else {
      return
    }
    
    // 해당 윈도우를 활성화
    window.makeKeyAndOrderFront(nil)
  }
  
  /// 윈도우의 플로팅 레벨 변경
  func changeWindowLevel(note: Note, noteViewModel: NoteViewModel) -> Note {
    var note = note
    
    if let window = openWindows.first(where: { $0.noteID == note.id }) {
      if note.isPinned == true {
        window.level = .normal
        note.isPinned = false
        print("noteisPinne false")
      } else {
        window.level = .floating
        note.isPinned = true
        print("noteisPinne true")
      }
    }
    
    return noteViewModel.updateNote(note)
  }
  
  /// 현재 열려있는 윈도우 목록에서 `noteID`에 해당하는 윈도우를 가져온다.
  private func getWindow(noteID: UUID) -> NoteEditWindow? {
    openWindows.first(where: { $0.noteID == noteID })
  }
  
  /// 현재 열려있는 윈도우 목록에서 `noteID`에 해당하는 윈도우를 key window로 만든다.
  private func bringWindowToFront(noteID: UUID) {
    getWindow(noteID: noteID)?.makeKeyAndOrderFront(nil)
  }
  
  /// 현재 열려있는 윈도우 목록에서 `noteID`에 해당하는 윈도우가 있는지 확인한다.
  private func isAlreadyOpened(noteID: UUID) -> Bool {
    openWindows.contains(where: { $0.noteID == noteID })
  }
  
  private func registerWindowPublisher(
    _ window: NoteEditWindow,
    noteViewModel: NoteViewModel,
    note: Note
  ) {
    window.windowFramePublisher
      .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
      .sink { rect in
        // 이 부분을 note로 전송하게 되면 여기서 고여있는 Note가 계속 전송된다.
        _ = noteViewModel.updateNote(id: note.id, windowFrame: rect)
      }
      .store(in: &cancellables)
  }
  
  func appendCreateWindowCount() {
    createdWindowCount += 1
  }
}
