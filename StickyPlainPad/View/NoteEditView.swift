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
  
  init(noteViewModel: NoteViewModel, noteID: UUID) {
    _noteViewModel = State(initialValue: noteViewModel)
    let first = noteViewModel.notes.first(where: { $0.id == noteID })
    
    if let note = first {
      _note = State(initialValue: note)
    }
  }
  
  var body: some View {
    TextEditor(text: $currentContent)
      .onAppear {
        guard let note else {
          return
        }
        
        currentContent = note.content
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
      repository: NoteRepositoryImpl(context: .memoryContext)
    ),
    noteID: .init()
  )
}
