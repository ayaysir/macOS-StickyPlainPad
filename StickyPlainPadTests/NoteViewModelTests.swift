//
//  File.swift
//  StickyPlainPadTests
//
//  Created by 윤범태 on 3/29/25.
//

import XCTest
@testable import StickyPlainPad

final class NoteViewModelTests: XCTestCase {
  var viewModel: NoteViewModel!
  var mockRepository: NoteRepository!
  
  override func setUp() {
    super.setUp()
    mockRepository = MockNoteRepository()
    viewModel = NoteViewModel(repository: mockRepository)
  }
  
  override func tearDown() {
    viewModel = nil
    mockRepository = nil
    super.tearDown()
  }

  func testAddEmptyNote() throws {
    viewModel.addEmptyNote()
    
    XCTAssertEqual(viewModel.notes.count, 1)
    XCTAssertEqual(viewModel.notes.first?.content, "")
  }
  
  func testFetchAllNotes() throws {
    viewModel.addEmptyNote()
    viewModel.addEmptyNote()
    
    XCTAssertEqual(viewModel.notes.count, 2)
  }
  
  func testUpdateNote() throws {
    viewModel.addEmptyNote()
    
    var note = viewModel.notes.first!
    note.modifiedAt = .now
    
    viewModel.updateNote(note, content: "Updated content")
    
    XCTAssertEqual(viewModel.notes.count, 1)
    XCTAssertEqual(viewModel.notes.first?.content, "Updated content")
    XCTAssertNotNil(viewModel.notes.first?.modifiedAt)
  }
  
  func testDeleteNote() throws {
    viewModel.addEmptyNote()
    let note = viewModel.notes.first!
    
    viewModel.deleteNote(note)
    
    XCTAssertEqual(viewModel.notes.count, 0)
  }
}

class MockNoteRepository: NoteRepository {
  private var notes: [Note] = []
  
  func fetchAll() -> [StickyPlainPad.Note] {
    notes
  }
  
  func add(_ note: StickyPlainPad.Note) {
    notes.append(note)
  }
  
  func update(_ note: StickyPlainPad.Note) {
    if let index = notes.firstIndex(where: { $0.id == note.id }) {
      notes[index] = note
    }
  }
  
  func delete(_ note: StickyPlainPad.Note) {
    if let index = notes.firstIndex(where: { $0.id == note.id }) {
      notes.remove(at: index)
    }
  }
}
