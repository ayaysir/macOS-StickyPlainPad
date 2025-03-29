//
//  NoteRepositoryImpl.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 3/29/25.
//

import Foundation
import SwiftData

// Impl(DataLayer)은 다수가 존재할 수 있다. Mock포함

class NoteRepositoryImpl: NoteRepository {
  private let context: ModelContext
  
  init(context: ModelContext) {
    self.context = context
  }
  
  private func saveContext() {
    do {
      try context.save()
    } catch {
      print("Failed to save context:", error)
    }
  }
  
  private func findEntity(by id: UUID) -> NoteEntity? {
    let descriptor = FetchDescriptor<NoteEntity>(predicate: #Predicate { $0.id == id })
    return try? context.fetch(descriptor).first
  }
  
  func fetchAll() -> [Note] {
    let descriptor = FetchDescriptor<NoteEntity>(
      sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
    )
    let entities = (try? context.fetch(descriptor)) ?? []
    
    return entities.map {
      Note(
        id: $0.id,
        createdAt: $0.createdAt,
        modifiedAt: $0.modifiedAt,
        content: $0.content,
        fileURL: $0.fileURL,
        backgroundColorHex: $0.backgroundColorHex,
        windowFrame: $0.windowFrame?.toCGRect
      )
    }
  }
  
  func add(_ note: Note) {
    let entity = NoteEntity(
      id: note.id,
      createdAt: note.createdAt,
      modifiedAt: note.modifiedAt,
      content: note.content,
      fileURL: note.fileURL,
      backgroundColorHex: note.backgroundColorHex,
      windowFrame: .init(cgRect: note.windowFrame)
    )
    context.insert(entity)
    saveContext()
  }
  
  func update(_ note: Note) {
    guard let entity = findEntity(by: note.id) else {
      return
    }
    
    entity.content = note.content
    entity.backgroundColorHex = note.backgroundColorHex
    entity.fileURL = note.fileURL
    entity.modifiedAt = note.modifiedAt
    entity.windowFrame = Rect(cgRect: note.windowFrame)
  }
  
  func delete(_ note: Note) {
    guard let entity = findEntity(by: note.id) else {
      return
    }
    
    context.delete(entity)
    saveContext()
  }
}
