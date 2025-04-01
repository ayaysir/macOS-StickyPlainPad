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
  @State private var naviTitle = "가나다"
  @State private var isAlwaysOnTop = false
  
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
            if let window = NSApplication.shared.keyWindow {
              if window.level == .normal {
                window.level = .floating
                isAlwaysOnTop = true
              } else {
                window.level = .normal
                isAlwaysOnTop = false
              }
            }
          } label: {
            Text("Always on Top")
              .frame(height: 15)
              .foregroundStyle(isAlwaysOnTop ? .red : .primary)
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
      AutoHidingScrollTextEditor(text: $currentContent)
    }
    .navigationTitle(naviTitle)
    .onAppear {
      currentContent = note.content
      naviTitle = note.content
    }
    .onChange(of: currentContent) {
      naviTitle = currentContent.truncated(to: 30)
      note = noteViewModel.updateNote(note, content: currentContent)
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
