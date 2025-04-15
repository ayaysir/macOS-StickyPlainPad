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
        if let theme {
          Color(hex: theme.backgroundColorHex)
          Color(hex: theme.textColorHex)?.colorInvert().opacity(0.08)
        } else {
          Color.white
        }
        
        HStack {
          // 닫기
          headerButton(
            action: closeWindow,
            imageSystemName: "squareshape"
          )
          .help("현재 스티커 닫기")
          
          Spacer()
          
          headerButton(
            action: makeWindowAlwaysOnTop,
            imageSystemName: "pin.fill",
            isTurnOn: note.isPinned
          )
          .help("항상 위에")
          
          headerButton(
            action: { showThemeSelectSheet = true },
            imageSystemName: "paintpalette"
          )
          .help("스티커 테마 변경")
          
          headerButton(
            action: maximizeWindow,
            imageSystemName: "arrow.up.left.and.arrow.down.right"
          )
          .help("창 최대화/복귀")
          
          headerButton(
            action: { shrinkWindow(to: HEADER_HEIGHT) },
            imageSystemName: "rectangle.topthird.inset.filled"
          )
          .help("헤더만 보기")
        }
        .padding(4)
      }
      .frame(height: HEADER_HEIGHT)
      
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
      .frame(minHeight: 300, maxHeight: 1000)
    }
  }
  
  func headerButton(
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
