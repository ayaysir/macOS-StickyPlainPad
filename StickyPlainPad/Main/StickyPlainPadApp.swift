//
//  StickyPlainPadApp.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 3/25/25.
//

import SwiftUI
import SwiftData

@main
struct StickyPlainPadApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  @Environment(\.openWindow) var openWindow
  
  @State private var noteViewModel: NoteViewModel
  @State private var themeViewModel: ThemeViewModel
  
  init() {
    // @State를 init에서 초기화하는 경우 _*** = State(initialValue:) 사용
    _noteViewModel = State(
      initialValue: NoteViewModel(
        repository: NoteRepositoryImpl(context: .mainContext)
      )
    )
    
    _themeViewModel = State(
      initialValue: ThemeViewModel(
        repository: ThemeRepositoryImpl(context: .mainContext)
      )
    )
  }
  
  var body: some Scene {
    // 디버그용 리스트 창 (목록을 어디에 배치할지 추후 결정)
    Window("List", id: "list") {
      NoteListView(
        viewModel: noteViewModel,
        themeViewModel: themeViewModel
      )
    }
    .defaultSize(width: 600, height: 400) // 기본 창 크기 설정
    .commands {
      // TODO: - 커맨드 메뉴 '파일'
      CommandGroup(after: .newItem) {
        Button("New Sticker") {
          NoteEditWindowMananger.shared.addEmptyNoteAndOpen(
            noteViewModel: noteViewModel,
            themeViewModel: themeViewModel
          )
        }
        Divider()
        Button("Load from Text File...") {
          
        }
        Button("Save to Text File...") {
          
        }
        Divider()
        Button("Print...") {
          guard let window = NoteEditWindowMananger.shared.keyWindow,
                let note = noteViewModel.notes.first(where: { $0.id == window.noteID }) else {
            return
          }
          
          let font: NSFont = if let themeID = note.themeID,
                                 let theme = themeViewModel.theme(withID: themeID) {
            NSFont(name: theme.fontName, size: note.fontSize) ?? NSFont.systemFont(ofSize: note.fontSize)
          } else {
            NSFont.systemFont(ofSize: note.fontSize)
          }
          
          printText(note.content, font: font)
        }
        .keyboardShortcut("p", modifiers: [.command])
      }
      
      CommandGroup(after: .appInfo) {
        Button("테마 관리...") {
          openWindow(id: "theme-new-window")
        }
        .keyboardShortcut("t", modifiers: [.command, .shift])
      }
    }
    
    Window("테마 관리", id: "theme-new-window") {
      ThemeListView(themeViewModel: themeViewModel)
    }
  }
  
  func printText(_ text: String, font: NSFont?) {
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
}
