//
//  NoteEditView.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 3/29/25.
//

import SwiftUI
import SwiftData

struct NoteEditView: View {
  @State private var note: Note
  @State private var noteViewModel: NoteViewModel
  @State private var currentContent = ""
  @State private var fontSize: CGFloat = 14
  @State private var naviTitle = "가나다"
  // @State private var isAlwaysOnTop = false
  
  init(noteViewModel: NoteViewModel, note: Note) {
    _noteViewModel = State(initialValue: noteViewModel)
    _note = State(initialValue: note)
  }
  
  var body: some View {
    VStack(spacing: 0) {
      ZStack {
        Color.white
          .ignoresSafeArea()
        HStack {
          Button {
            note = NoteEditWindowMananger.shared.changeWindowLevel(
              note: note,
              noteViewModel: noteViewModel
            )
          } label: {
            Text("Always on Top")
              .frame(height: 15)
              .foregroundStyle(note.isPinned ? .red : .primary)
          }
          
          Button {
            closeWindow()
          } label: {
            Text("Close Window")
          }
        }
        
      }
      .frame(height: 20)
      
      // TextEditor(text: $currentContent)
      AutoHidingScrollTextEditor(
        text: $currentContent,
        fontSize: $fontSize
      )
    }
    .navigationTitle(naviTitle)
    .onAppear {
      currentContent = note.content
      naviTitle = note.content
      fontSize = note.fontSize
    }
    .onChange(of: currentContent) {
      naviTitle = currentContent.truncated(to: 30)
      note = noteViewModel.updateNote(note, content: currentContent)
    }
    .onChange(of: fontSize) {
      note.fontSize = fontSize
      note = noteViewModel.updateNote(note)
    }
  }
}

extension NoteEditView {
  /// 현재 윈도우를 닫는 메서드
  func closeWindow() {
    if let window = NSApplication.shared.keyWindow as? NoteEditWindow {
      window.close()
      NoteEditWindowMananger.shared.removeWindowMenu(window)
    }
    
    _ = NoteEditWindowMananger.shared.updateWindowsOpenStatus(
      noteViewModel: noteViewModel,
      note: note,
      isWindowOpened: false
    )
  }
}

#Preview {
  NoteEditView(
    noteViewModel: NoteViewModel(
      repository: NoteRepositoryImpl(context: .forPreviewContext)
    ),
    note: Note(id: .init(), createdAt: .now, content: "가나다라")
  )
}
