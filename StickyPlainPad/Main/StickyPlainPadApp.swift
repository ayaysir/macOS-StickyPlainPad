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
      NoteListView(viewModel: noteViewModel)
    }
    .defaultSize(width: 600, height: 400) // 기본 창 크기 설정
    .commands {
      // TODO: - 커맨드 메뉴 '파일'
      
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
}
