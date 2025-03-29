//
//  NoteViewModel.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 3/29/25.
//

import Foundation

@Observable
class NoteViewModel {
  private let repository: NoteRepository
  var notes: [Note] = []

  // var noteList: [Note] {
  //   notes
  // }
  
  init(repository: NoteRepository) {
    self.repository = repository
    loadNotes()
  }
  
  func loadNotes() {
    notes = repository.fetchAll()
  }
  
  func findNote(id: UUID) -> Note? {
    notes.first(where: { $0.id == id })
  }
  
  func addEmptyNote() {
    let newNote = Note(
      id: .init(),
      createdAt: .now,
      content: ""
    )
    
    repository.add(newNote)
    loadNotes()
  }
  
  func updateNote(_ note: Note, content: String) {
    var note = note
    note.content = content
    note.modifiedAt = .now
    
    repository.update(note)
    loadNotes()
  }
  
  func deleteNote(_ note: Note) {
    repository.delete(note)
    loadNotes()
  }
  
  func deleteNote(index: Int) {
    repository.delete(notes[index])
    loadNotes()
  }
}
