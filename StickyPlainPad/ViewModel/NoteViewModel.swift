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

  var lastOpenedNotes: [Note] {
    notes.filter {
      $0.isWindowOpened
    }.sorted {
      ($0.lastWindowFocusedAt ?? .distantPast) > ($1.lastWindowFocusedAt ?? .distantPast)
    }
  }
  
  var lastUpdatedNoteID: Note.ID?
  var currentNoteIdForFind: Note.ID?
  
  var firstWindowFrame: Rect {
    let newPos = NoteEditWindowManager.shared.newWindowPos
    let firstPos = NoteEditWindowManager.shared.newWindowPosFirst
    let windowSize = NoteEditWindowManager.shared.windowSize
    
    return .init(
      originX: newPos?.x ?? firstPos.x ,
      originY: newPos?.y ?? firstPos.y,
      width: windowSize.width,
      height: windowSize.height
    )
  }
  
  init(repository: NoteRepository) {
    self.repository = repository
    loadNotes()
  }
  
  func loadNotes() {
    notes = repository.fetchAll()
  }
  
  func loadWindowFrame(note: Note) -> Rect? {
    return note.windowFrame
  }
  
  func findNote(id: Note.ID) -> Note? {
    notes.first(where: {$0.id == id})
  }
  
  @discardableResult
  func addNewNote(
    content: String = "",
    fileURL: URL? = nil,
    themeID: UUID? = nil
  ) -> Note {
    let noteID = UUID()
    let newNote = Note(
      id: noteID,
      createdAt: .now,
      content: content,
      fileURL: fileURL,
      windowFrame: firstWindowFrame,
      themeID: themeID
    )
    
    repository.add(newNote)
    loadNotes()
    
    return newNote
  }
  
  func addNote(_ note: Note) {
    repository.add(note)
    loadNotes()
  }
  
  func addNotes(from notes: [Note]) {
    notes.forEach { note in
      repository.add(note)
    }
    
    loadNotes()
  }
  
  func updateNote(_ note: Note, content: String) -> Note {
    var note = note
    note.content = content
    note.lastWindowFocusedAt = .now
    note.modifiedAt = .now
    note.isWindowOpened = true
    
    repository.update(note)
    loadNotes()
    
    return note
  }
  
  func updateNote(id: UUID, windowFrame: Rect) -> Note? {
    guard var note = findNote(id: id) else {
      return nil
    }
    
    note.windowFrame = windowFrame
    note.lastWindowFocusedAt = .now
    
    lastUpdatedNoteID = note.id
    
    repository.update(note)
    loadNotes()
    
    return note
  }
  
  func updateNote(_ note: Note, isWindowOpened: Bool) -> Note {
    var note = note
    note.isWindowOpened = isWindowOpened
    
    repository.update(note)
    loadNotes()
    
    return note
  }
  
  func updateNote(_ note: Note, isPinned: Bool) -> Note {
    var note = note
    note.isPinned = isPinned
    
    repository.update(note)
    loadNotes()
    
    return note
  }
  
  func updateNote(_ note: Note, fileURL: URL) -> Note {
    var note = note
    note.fileURL = fileURL
    
    repository.update(note)
    loadNotes()
    
    return note
  }
  
  func updateNote(_ note: Note) -> Note {
    repository.update(note)
    loadNotes()
    
    return note
  }
  
  func deleteNote(_ note: Note) {
    repository.delete(note)
    loadNotes()
  }
  
  @discardableResult
  func deleteNote(index: Int) -> Note.ID {
    let noteID = notes[index].id
    repository.delete(notes[index])
    loadNotes()
    
    return noteID
  }
}
