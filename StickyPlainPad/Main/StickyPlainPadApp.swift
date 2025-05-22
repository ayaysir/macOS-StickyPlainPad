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
    Window("loc_list_title", id: .idMemoListWindow) {
      NoteListView(
        viewModel: noteViewModel,
        themeViewModel: themeViewModel
      )
      .onAppear {
        loadInitialThemesIfNeeded()
        loadInitialNotesIfNeeded()
      }
      .onReceive(NotificationCenter.default.publisher(for: .didOpenFileURL)) { output in
        // print("onReceive: \(output)")
        guard let url = output.object as? URL else { return }
        NoteEditWindowManager.shared.addNewNoteAndOpen(
          noteViewModel: noteViewModel,
          themeViewModel: themeViewModel,
          fileURL: url,
          content: readTextFileAutoEncoding(at: url) ?? ""
        )
      }
    }
    .defaultSize(width: 600, height: 400) // 기본 창 크기 설정
    .commands { commands() }
    
    Window("loc_theme_manager", id: .idThemeNewWindow) {
      ThemeListView(themeViewModel: themeViewModel)
    }
    
    Window("loc_editor_settings", id: .idEditorSettingWindow) {
      EditorOptionsSettingsView()
    }
  }
}

// MARK : - 앱 초기 설정

extension StickyPlainPadApp {
  /// 앱 설치 직후, 초기 테마 추가
  private func loadInitialThemesIfNeeded() {
    guard !UserDefaults.standard.bool(forKey: .onceHasLoadedInitialThemes) else {
      return
    }
    
    guard themeViewModel.themes.isEmpty else {
      Log.warning("\(#function): theme is not empty, 이미 테마가 있습니다.")
      return
    }
    
    guard let url = Bundle.main.url(forResource: "InitialThemes", withExtension: "json"),
          let jsonData = try? Data(contentsOf: url),
          let jsonString = String(data: jsonData, encoding: .utf8),
          let themes = [Theme].decodeFromJSON(jsonString, as: [Theme].self)
    else {
      Log.error("❌ 초기 테마 로딩 실패")
      return
    }
    
    themeViewModel.addThemes(from: themes)
    UserDefaults.standard.set(true, forKey: .onceHasLoadedInitialThemes)
    Log.notice("✅ 초기 테마를 성공적으로 로드했습니다")
  }
  
  /// 앱 설치 직후, 초기 노트 추가
  private func loadInitialNotesIfNeeded() {
    guard !UserDefaults.standard.bool(forKey: .onceHasLoadedInitialNotes) else { return }
    
    guard let url = Bundle.main.url(forResource: "loc_InitialNotes".localized, withExtension: "json"),
          let jsonData = try? Data(contentsOf: url),
          let jsonString = String(data: jsonData, encoding: .utf8),
          let initNotes = [InitNote].decodeFromJSON(jsonString, as: [InitNote].self)
    else {
      Log.error("❌ 초기 노트 로딩 실패")
      return
    }
    
    let notes = initNotes.enumerated().map { index, initNote in
      return Note(
        id: .init(),
        createdAt: .now,
        modifiedAt: .now,
        content: initNote.content,
        fileURL: nil,
        // 위치: index 0: 메인 모니터의 오른쪽 상단, index 1: 메인 모니터의 왼쪽 상단, index 2: 메인 모니터의 왼쪽 하단
        // 크기: 500, 300
        windowFrame: windowFrame(for: index),
        isPinned: false,
        fontSize: 17,
        lastWindowFocusedAt: nil,
        isWindowOpened: true,
        themeID: nil,
        isWindowShrinked: false
      )
    }
    
    noteViewModel.addNotes(from: notes)
    UserDefaults.standard.set(true, forKey: .onceHasLoadedInitialNotes)
    Log.notice("✅ 초기 노트를 성공적으로 로드했습니다")
  }
  
  private func windowFrame(for index: Int, padding: CGFloat = 20) -> Rect? {
    guard let screen = NSScreen.main else { return nil }
    
    let screenFrame = screen.visibleFrame
    let windowWidth: CGFloat = 550
    let windowHeight: CGFloat = 350
    
    return switch index {
    case 0:
      // 오른쪽 상단 (왼쪽/아래로 padding)
      Rect(
        originX: screenFrame.maxX - windowWidth - padding,
        originY: screenFrame.maxY - windowHeight - padding,
        width: windowWidth,
        height: windowHeight
      )
      
    case 2:
      // 왼쪽 상단 (오른쪽/아래로 padding)
      Rect(
        originX: screenFrame.minX + padding,
        originY: screenFrame.maxY - windowHeight - padding,
        width: windowWidth,
        height: windowHeight
      )
      
    case 1:
      // 왼쪽 하단 (오른쪽/위로 padding)
      Rect(
        originX: screenFrame.minX + padding,
        originY: screenFrame.minY + padding,
        width: windowWidth,
        height: windowHeight
      )
      
    default:
      nil
    }
  }
}

// MARK: - Commands

extension StickyPlainPadApp {
  var noteFromKeyWindow: Note? {
    guard let window = NoteEditWindowManager.shared.keyWindow,
          let noteID = window.noteID else {
      return nil
    }
    
    return noteViewModel.findNote(id: noteID)
  }
  
  @CommandsBuilder
  func commands() -> some Commands {
    CommandGroup(after: .newItem) {
      Button("loc_new_note") {
        NoteEditWindowManager.shared.addNewNoteAndOpen(
          noteViewModel: noteViewModel,
          themeViewModel: themeViewModel
        )
      }
      .keyboardShortcut("n", modifiers: [.command])
      
      Divider()
      
      Button("loc_load_file_ellipsis") {
        if let result = openSelectReadFilePanel() {
          NoteEditWindowManager.shared.addNewNoteAndOpen(
            noteViewModel: noteViewModel,
            themeViewModel: themeViewModel,
            fileURL: result.url,
            content: result.text ?? ""
          )
        }
      }
      .keyboardShortcut("o", modifiers: [.command])
      
      Button("loc_save_file_ellipsis") {
        guard let note = noteFromKeyWindow else {
          return
        }
        
        // 새로 저장 후 fileURL을 덮어쓰기 (무조건)
        openSavePanel(
          note.content,
          defaultFileName: note.fileURL?.lastPathComponent ?? "Untitled.txt"
        ) { url in
          _ = noteViewModel.updateNote(note, fileURL: url)
          noteViewModel.lastUpdatedNoteID = note.id
        }
      }
      .keyboardShortcut("s", modifiers: [.command])
      
      Divider()
      
      Button("loc_print_ellipsis") {
        guard let note = noteFromKeyWindow else {
          return
        }
        
        let font: NSFont = if let themeID = note.themeID,
                              let theme = themeViewModel.theme(withID: themeID) {
          NSFont(name: theme.fontName, size: note.fontSize) ?? NSFont.systemFont(ofSize: note.fontSize)
        } else {
          NSFont.systemFont(ofSize: note.fontSize)
        }
        
        openPrintPanel(note.content, font: font)
      }
      .keyboardShortcut("p", modifiers: [.command])
    }
    
    CommandGroup(after: .appInfo) {
      Divider()
      
      Button("loc_memo_list_ellipsis") {
        openWindow(id: .idMemoListWindow)
      }
      .keyboardShortcut("l", modifiers: [.command])
      
      Button("loc_theme_manager_ellipsis") {
        openWindow(id: .idThemeNewWindow)
      }
      .keyboardShortcut("t", modifiers: [.command, .shift])
      
      Button("loc_editor_settings_ellipsis") {
        openWindow(id: .idEditorSettingWindow)
      }
      .keyboardShortcut(",", modifiers: .command)
    }
    
    CommandGroup(after: .pasteboard) {
      Divider()
      
      Button("loc_findreplace_ellipsis") {
        if let note = noteFromKeyWindow {
          noteViewModel.currentNoteIdForFind = note.id
        }
        
      }
      .keyboardShortcut("f", modifiers: [.command])
    }
    
    // Close 버튼 대체
    CommandGroup(replacing: .saveItem) {
      Button("loc_close") {
        if let note = noteFromKeyWindow {
          if let keyWindow = NSApp.keyWindow as? NoteEditWindow {
            NoteEditWindowManager.shared.closeWindowAndRemoveFromCommandMenu(
              keyWindow,
              note: note,
              noteViewModel: noteViewModel
            )
            
            return
          }
        }
        
        NSApp.keyWindow?.close()
      }
      .keyboardShortcut("w", modifiers: [.command])
    }
    
    CommandGroup(after: .help) {
      Divider()
      
      Button("loc_ask_to_developer") {
        openEmailApp()
      }
      
      Divider()
      
      Button("loc_developer_info") {
        openWebsite(MAKER_WEBSITE)
      }
      
      Button("loc_developer_store") {
        openWebsite("https://apps.apple.com/developer/id\(MAKER_ID)")
      }
      
      Divider()
      
      Button("loc_request_review") {
        openWebsite("https://apps.apple.com/app/id\(APP_ID)?action=write-review")
      }
      
      Button("loc_share_app") {
        shareAppURL("https://apps.apple.com/app/id\(APP_ID)")
      }
    }
  }
}

