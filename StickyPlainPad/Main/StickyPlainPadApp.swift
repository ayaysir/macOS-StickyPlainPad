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
    Window("loc_list_title", id: "list") {
      NoteListView(
        viewModel: noteViewModel,
        themeViewModel: themeViewModel
      )
      .onAppear {
        loadInitialThemesIfNeeded()
        loadInitialNotesIfNeeded()
      }
    }
    .defaultSize(width: 600, height: 400) // 기본 창 크기 설정
    .commands {
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
        .keyboardShortcut("l", modifiers: [.command])
        
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
          openWebsite("http://yoonbumtae.com")
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
    
    Window("loc_theme_manager", id: .idThemeNewWindow) {
      ThemeListView(themeViewModel: themeViewModel)
    }
    
    Window("loc_editor_settings", id: .idEditorSettingWindow) {
      EditorOptionsSettingsView()
    }
  }
}

extension StickyPlainPadApp {
  func openWebsite(_ urlString: String) {
    if let url = URL(string: urlString) {
      NSWorkspace.shared.open(url)
    }
  }
  
  func shareAppURL(_ urlString: String) {
    guard let url = URL(string: urlString) else  {
      return
    }
    
    let picker = NSSharingServicePicker(items: [url])
    
    // 현재 앱의 key window를 기준으로 공유창 표시
    if let window = NSApp.keyWindow,
       let contentView = window.contentView {
      picker.show(relativeTo: .zero, of: contentView, preferredEdge: .minY)
    }
  }
  
  func openEmailApp() {
    let versionString = Bundle.main.appVersionString
    let subject = "loc_email_subject".localized
    let body = "loc_email_body".localizedFormat(versionString)

    // URL encoding
    let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

    if let url = URL(string: "mailto:\(MAKER_MAIL)?subject=\(encodedSubject)&body=\(encodedBody)") {
      NSWorkspace.shared.open(url)
    }
  }
}

extension StickyPlainPadApp {
  var noteFromKeyWindow: Note? {
    guard let window = NoteEditWindowManager.shared.keyWindow,
          let noteID = window.noteID else {
      return nil
    }
    
    return noteViewModel.findNote(id: noteID)
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
  
  /// 찾기 대화상자
  func openFindReplaceWindow() {
    let window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 450, height: 260),
      styleMask: [.titled, .closable], // 닫기 버튼만 활성화
      backing: .buffered,
      defer: false
    )
    window.center()
    window.title = "window_find_title".localized
    window.contentView = NSHostingView(rootView: FindReplaceWindowView())
    window.isReleasedWhenClosed = false
    window.makeKeyAndOrderFront(nil)
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
}

extension StickyPlainPadApp {
  /// 앱 설치 직후, 초기 테마 추가
  private func loadInitialThemesIfNeeded() {
    guard !UserDefaults.standard.bool(forKey: .onceHasLoadedInitialThemes) else { return }
    guard themeViewModel.deleteAllThemes() else { return }

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
