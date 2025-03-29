//
//  NoteEditView.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 3/29/25.
//

import SwiftUI
import SwiftData

struct NoteEditView: View {
  @State private var note: Note?
  @State private var noteViewModel: NoteViewModel
  @State private var currentContent = ""
  @State private var naviTitle = "가나다"
  @State private var isAlwaysOnTop = false
  
  init(noteViewModel: NoteViewModel, noteID: UUID) {
    _noteViewModel = State(initialValue: noteViewModel)
    let first = noteViewModel.notes.first(where: { $0.id == noteID })
    
    if let note = first {
      _note = State(initialValue: note)
    }
  }
  
  var body: some View {
    VStack(spacing: 0) {
      ZStack {
        Color.white
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
      }
      .frame(height: 20)
      
      TextEditor(text: $currentContent)
    }
    .navigationTitle(naviTitle)
    .onAppear {
      guard let note else {
        return
      }
      
      currentContent = note.content
      naviTitle = note.content
    }
    .onChange(of: currentContent) {
      guard let note else {
        return
      }
      
      noteViewModel.updateNote(note, content: currentContent)
    }
  }
}

#Preview {
  NoteEditView(
    noteViewModel: NoteViewModel(
      repository: NoteRepositoryImpl(context: .forPreviewContext)
    ),
    noteID: .init()
  )
}
