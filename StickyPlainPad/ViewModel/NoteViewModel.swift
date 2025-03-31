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
  
  func loadWindowFrame(noteID: UUID) -> Rect? {
    guard let note = findNote(id: noteID) else {
      return nil
    }
    
    return note.windowFrame
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
  
  func updateNote(noteID: UUID, windowFrame: Rect) {
    guard var note = findNote(id: noteID) else {
      return
    }
    
    note.windowFrame = windowFrame
    repository.update(note)
    // 윈도우 좌표만 업데이트하므로 일단 리스트를 리프레시하지는 않음?
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
