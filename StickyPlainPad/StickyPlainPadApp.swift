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
  
  @State private var noteViewModel: NoteViewModel
  
  init() {
    // @State를 init에서 초기화하는 경우 _*** = State(initialValue:) 사용
    _noteViewModel = State(
      initialValue: NoteViewModel(
        repository: NoteRepositoryImpl(context: .mainContext)
      )
    )
  }
  
  var body: some Scene {
    // 디버그용 리스트 창 (목록을 어디에 배치할지 추후 결정)
    Window("List", id: "list") {
      NoteListView(viewModel: noteViewModel)
    }
    
    // 포스트잇 창
    WindowGroup("Note", for: Note.ID.self) { $noteID in
      if let noteID = $noteID.wrappedValue {
        NoteEditView(noteViewModel: noteViewModel, noteID: noteID)
      } else {
        Text("Note is nil.")
      }
    }
    .defaultSize(width: 600, height: 400) // 기본 창 크기 설정
    // .windowStyle(.hiddenTitleBar)
    // .windowResizability(.contentSize)
  }
}

class AppDelegate: NSObject, NSApplicationDelegate {
  func applicationDidFinishLaunching(_ notification: Notification) {
    // hideTitleBar()
  }
  
  func hideTitleBar() {
    NSApplication.shared.windows.forEach { window in
      window.titlebarAppearsTransparent = true
      window.titleVisibility = .hidden
      
      window.isMovableByWindowBackground = true
      
      // window.standardWindowButton(.closeButton)?.isHidden = true
      // window.standardWindowButton(.miniaturizeButton)?.isHidden = true
      // window.standardWindowButton(.zoomButton)?.isHidden = true
      
      // window.styleMask.remove(.titled) // 타이틀바 제거
      // window.styleMask.insert(.fullSizeContentView) // 전체 콘텐츠 뷰 활성화
      
      /*
       print(window.styleMask.contains(.borderless)) // t
       print(window.styleMask.contains(.closable)) // t
       print(window.styleMask.contains(.docModalWindow)) // f
       print(window.styleMask.contains(.fullScreen)) // f
       print(window.styleMask.contains(.fullSizeContentView)) // t
       print(window.styleMask.contains(.hudWindow)) // f
       print(window.styleMask.contains(.miniaturizable)) // t
       print(window.styleMask.contains(.nonactivatingPanel)) // f
       print(window.styleMask.contains(.resizable)) // t
       print(window.styleMask.contains(.titled)) // t
       print(window.styleMask.contains(.unifiedTitleAndToolbar)) // f
       print(window.styleMask.contains(.utilityWindow)) // f
       
       print(window.canBecomeKey, window.canBecomeMain)
       */
    }
  }
}


