//
//  NoteEditView.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 3/29/25.
//

import SwiftUI
import SwiftData
import Combine

struct NoteEditView: View {
  let HEADER_HEIGHT: CGFloat = 15
  let ICON_SIZE: CGFloat = 10
  
  @State private var noteViewModel: NoteViewModel
  @State private var themeViewModel: ThemeViewModel
  @Bindable private var findReplaceViewModel = FindReplaceViewModel()
  @Bindable private var noteEditViewModel = NoteEditViewModel()
  
  @State private var note: Note
  @State private var theme: Theme?
  @State private var currentContent = ""
  @State private var fontSize: CGFloat = 14
  @State private var naviTitle = "가나다"
  
  @State private var showThemeSelectSheet = false
  
  init(
    noteViewModel: NoteViewModel,
    themeViewModel: ThemeViewModel,
    note: Note
  ) {
    _noteViewModel = State(initialValue: noteViewModel)
    _themeViewModel = State(initialValue: themeViewModel)
    _note = State(initialValue: note)
    
    if let themeID = note.themeID {
      _theme = State(initialValue: themeViewModel.theme(withID: themeID))
    }
  }
  
  var body: some View {
    VStack(spacing: 0) {
      HeaderToolbar
      TextEditorArea
    }
    .navigationTitle(naviTitle)
    .onAppear(perform: setup)
    .onChange(of: currentContent) {
      naviTitle = currentContent.truncated(to: 30)
      note = noteViewModel.updateNote(note, content: currentContent)
    }
    .onChange(of: findReplaceViewModel.text) {
      currentContent = findReplaceViewModel.text
      note = noteViewModel.updateNote(note, content: currentContent)
    }
    .onChange(of: fontSize) {
      note.fontSize = fontSize
      note = noteViewModel.updateNote(note)
    }
    .onReceive(
      noteViewModel.lastUpdatedNoteID.publisher.debounce(
        for: 0.1,
        scheduler: RunLoop.main
      )
    ) { noteID in
      if noteID == note.id,
         let newNote = noteViewModel.findNote(id: noteID) {
        Log.info("Note updated: \(note.id)")
        note = newNote
      }
    }
    .onChange(of: noteViewModel.currentNoteIdForFind) { _, noteID in
      if noteID == note.id {
        findReplaceViewModel.isSearchWindowPresented = true
      } else {
        findReplaceViewModel.isSearchWindowPresented = false
      }
    }
    .onChange(of: noteViewModel.currentNoteIdForAddText, handleNoteAddText)
    .onChange(of: findReplaceViewModel.isSearchWindowPresented) { oldValue, newValue in
      if oldValue == true,
         newValue == false,
         noteViewModel.currentNoteIdForFind == note.id {
        noteViewModel.currentNoteIdForFind = nil
      }
      
      if oldValue == false, newValue == true {
        findReplaceViewModel.text = currentContent
      }
    }
    .onReceive(
      NotificationCenter.default.publisher(for: .didThemeChanged),
      perform: handleThemeChanged
    )
    .sheet(isPresented: $showThemeSelectSheet) {
      // onDismiss
      updateTheme()
    } content: {
      NoteThemeSelectView(
        note: $note,
        noteViewModel: noteViewModel,
        themeViewModel: themeViewModel
      )
      .frame(minHeight: 500, maxHeight: 1000)
    }
  }
}

extension NoteEditView {
  func HeaderButton(
    action: @escaping VoidCallback,
    imageSystemName: String,
    isTurnOn: Bool = false
  ) -> some View {
    Button(action: action) {
      if let theme,
         let imageColor = Color(hex: theme.backgroundColorHex)?.readableGrayTextColor() {
        Image(systemName: imageSystemName)
          .font(.system(size: ICON_SIZE))
          .foregroundStyle(isTurnOn ? .red : imageColor)
      } else {
        Image(systemName: imageSystemName)
          .font(.system(size: ICON_SIZE))
          .foregroundStyle(isTurnOn ? .red : .primary)
      }
    }
    .background(isTurnOn ? .black.opacity(0.5) : .clear)
    .buttonStyle(.plain)
  }
  
  private var HeaderToolbar: some View {
    ZStack {
      if let theme {
        Color(hex: theme.backgroundColorHex)
        Color(hex: theme.textColorHex)?.colorInvert().opacity(0.08)
      } else {
        // Color(.gray)
        Color(.defaultNoteBackground).opacity(0.8)
      }
      
      HStack {
        // 닫기
        HeaderButton(
          action: closeWindow,
          imageSystemName: "squareshape"
        )
        .help("loc_close_note")
        
        Spacer()
          .frame(height: HEADER_HEIGHT)
          .contentShape(Rectangle())
          .onTapGesture(count: 2, perform: maximizeWindow)
      
        // 새 노트 추가
        HeaderButton(
          action: makeNewNote,
          imageSystemName: "plus"
        )
        
        HeaderButton(
          action: makeWindowAlwaysOnTop,
          imageSystemName: "pin.fill",
          isTurnOn: note.isPinned
        )
        .help("loc_always_on_top")
        
        HeaderButton(
          action: { showThemeSelectSheet = true },
          imageSystemName: "paintpalette"
        )
        .help("loc_change_theme_ellipsis")
        
        HeaderButton(
          action: maximizeWindow,
          imageSystemName: "arrow.up.left.and.arrow.down.right"
        )
        .help("loc_maxres_window")
        
        HeaderButton(
          action: { shrinkWindow(to: HEADER_HEIGHT) },
          imageSystemName: "rectangle.topthird.inset.filled"
        )
        .help("loc_shrink_header")
      }
      .padding(4)
    }
    .frame(height: HEADER_HEIGHT)
  }
  
  private var SearchArea: some View {
    FindReplaceInnerView(
      viewModel: findReplaceViewModel
    )
    .background(Color(nsColor: .textBackgroundColor))
  }
  
  private var TextEditorArea: some View {
    VStack(spacing: 0) {
      if findReplaceViewModel.isSearchWindowPresented {
        SearchArea
      }
      AutoHidingScrollTextEditor(
        text: $currentContent,
        fontSize: $fontSize,
        theme: $theme,
        frViewModel: findReplaceViewModel,
        neViewModel: noteEditViewModel
      )
    }
    .background(Color.defaultNoteBackground)
  }
}

extension NoteEditView {
  func setup() {
    currentContent = note.content
    naviTitle = note.content
    fontSize = note.fontSize
    
    // if let themeID = note.themeID {
    //   Log.info("heme exist: \(themeID)")
    // }
  }
  
  func updateTheme() {
    if let themeID = note.themeID {
      theme = themeViewModel.theme(withID: themeID)
    } else {
      theme = nil
    }
  }
  
  private func handleThemeChanged(_ notification: Notification) {
    guard let updatedThemeID = notification.object as? UUID,
          let themeID = theme?.id,
          themeID == updatedThemeID
    else {
      return
    }
    
    updateTheme()
  }
  
  private func handleNoteAddText(
    _ oldValue: NoteCommand?,
    _ newValue: NoteCommand?
  ) {
    guard let noteCommand = newValue,
          note.id == noteCommand.id else {
      // Log.error("Note ID Mismatch")
      return
    }

    switch noteCommand.command {
    case "timestamp":
      let formatter = DateFormatter()
      formatter.locale = .autoupdatingCurrent // 시스템 지역을 따름
      formatter.dateStyle = .medium
      formatter.timeStyle = .medium
      
      noteEditViewModel.pendingInsertText = formatter.string(from: .now)
    default:
      break
    }
    
    noteViewModel.currentNoteIdForAddText = nil
  }
}

extension NoteEditView {
  /// 현재 윈도우를 닫는 메서드
  func closeWindow() {
    guard let window = NoteEditWindowManager.shared.keyWindow else {
      return
    }
    
    window.close()
    NoteEditWindowManager.shared.closeWindowAndRemoveFromCommandMenu(
      window,
      note: note,
      noteViewModel: noteViewModel
    )
    
    _ = NoteEditWindowManager.shared.updateWindowsOpenStatus(
      noteViewModel: noteViewModel,
      note: note,
      isWindowOpened: false
    )
  }
  
  func shrinkWindow(to height: CGFloat) {
    guard let window = NoteEditWindowManager.shared.keyWindow else {
      return
    }
    
    let frame = note.windowFrame?.toCGRect ?? window.frame
    
    let newFrame: NSRect = if note.isWindowShrinked {
      // 윈도우 원래 크기로 복원
      NSRect(
        origin: frame.origin,
        size: frame.size
      )
    } else {
      // 윈도우 축소
      NSRect(
        x: frame.origin.x,
        y: frame.origin.y + frame.size.height - height,
        width: frame.width,
        height: height
      )
    }
    
    note.isWindowShrinked.toggle()
    // note = noteViewModel.updateNote(note)
    
    window.setFrame(
      newFrame,
      display: true,
      animate: true
    )
  }
  
  func maximizeWindow() {
    guard let window = NoteEditWindowManager.shared.keyWindow else {
      return
    }
    
    window.zoom(nil)
  }
  
  func makeWindowAlwaysOnTop() {
    note = NoteEditWindowManager.shared.changeWindowLevel(
      note: note,
      noteViewModel: noteViewModel
    )
  }
  
  func makeNewNote() {
    NoteEditWindowManager.shared.addNewNoteAndOpen(
      noteViewModel: noteViewModel,
      themeViewModel: themeViewModel
    )
  }
}

#Preview {
  NoteEditView(
    noteViewModel: NoteViewModel(
      repository: NoteRepositoryImpl(context: .forPreviewContext)
    ),
    themeViewModel: ThemeViewModel(
      repository: ThemeRepositoryImpl(context: .forPreviewContext)
    ),
    note: Note(id: .init(), createdAt: .now, content: "가나다라")
  )
}
