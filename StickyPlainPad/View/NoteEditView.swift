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
  @State private var note: Note
  @State private var theme: Theme?
  @State private var noteViewModel: NoteViewModel
  @State private var themeViewModel: ThemeViewModel
  @State private var currentContent = ""
  @State private var fontSize: CGFloat = 14
  @State private var naviTitle = "가나다"
  // @State private var isAlwaysOnTop = false
  
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
      ZStack {
        Color.white
          .ignoresSafeArea()
        HStack {
          Button(action: closeWindow) {
            Text("Close Window")
          }
          
          Button(action: makeWindowAlwaysOnTop) {
            Text("Always on Top")
              .frame(height: 15)
              .foregroundStyle(note.isPinned ? .red : .primary)
          }
          
          Button(action: { showThemeSelectSheet = true }) {
            Text("Select theme")
          }
          
          Button(action: maximizeWindow) {
            Text("Maximize Window")
          }
          
          Button(action: { shrinkWindow(to: 20) }) {
            Text("Shrink Window")
          }
        }
      }
      .frame(height: 20)
      
      // TextEditor(text: $currentContent)
      AutoHidingScrollTextEditor(
        text: $currentContent,
        fontSize: $fontSize,
        theme: $theme
      )
    }
    .navigationTitle(naviTitle)
    .onAppear {
      currentContent = note.content
      naviTitle = note.content
      fontSize = note.fontSize
      
      if let themeID = note.themeID {
        print("theme exist: \(themeID)")
      }
    }
    .onChange(of: currentContent) {
      naviTitle = currentContent.truncated(to: 30)
      note = noteViewModel.updateNote(note, content: currentContent)
    }
    .onChange(of: fontSize) {
      note.fontSize = fontSize
      note = noteViewModel.updateNote(note)
    }
    .onReceive(noteViewModel.lastUpdatedNoteID.publisher) { noteID in
      // if noteID == note.id,
      //    let newNote = noteViewModel.findNote(id: noteID) {
      //   print("note updated:", newNote.id, note.id)
      //   note = newNote
      // }
    }
    .sheet(isPresented: $showThemeSelectSheet) {
      // onDismiss
      if let themeID = note.themeID {
        theme = themeViewModel.theme(withID: themeID)
      }
      
    } content: {
      NoteThemeSelectView(
        note: $note,
        noteViewModel: noteViewModel,
        themeViewModel: themeViewModel
      )
    }
  }
}

extension NoteEditView {
  /// 현재 윈도우를 닫는 메서드
  func closeWindow() {
    guard let window else {
      return
    }
    
    window.close()
    NoteEditWindowMananger.shared.removeWindowMenu(window)
    
    _ = NoteEditWindowMananger.shared.updateWindowsOpenStatus(
      noteViewModel: noteViewModel,
      note: note,
      isWindowOpened: false
    )
  }
  
  func shrinkWindow(to height: CGFloat) {
    guard let window else {
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
    guard let window else {
      return
    }
    
    window.zoom(nil)
  }
  
  func makeWindowAlwaysOnTop() {
    note = NoteEditWindowMananger.shared.changeWindowLevel(
      note: note,
      noteViewModel: noteViewModel
    )
  }
  
  var window: NoteEditWindow? {
    NSApplication.shared.keyWindow as? NoteEditWindow
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
