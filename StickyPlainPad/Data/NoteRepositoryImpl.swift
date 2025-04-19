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
      Log.error("Failed to save context: \(error)")
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
    
    do {
      return try context.fetch(descriptor).map {
        $0.toDomain()
      }
    } catch {
      Log.error("\(#function): \(error)")
      return []
    }
  }
  
  func add(_ note: Note) {
    let entity = NoteEntity(from: note, in: context)
    context.insert(entity)
    saveContext()
  }
  
  func update(_ note: Note) {
    guard let entity = findEntity(by: note.id) else {
      Log.error("\(#function): Can't find note entity \(note.id)")
      return
    }
    
    entity.content = note.content
    entity.fileURL = note.fileURL
    entity.modifiedAt = note.modifiedAt
    entity.windowFrame = note.windowFrame
    entity.isPinned = note.isPinned
    entity.fontSize = note.fontSize
    entity.lastWindowFocusedAt = note.lastWindowFocusedAt
    entity.isWindowOpened = note.isWindowOpened
    
    if entity.theme?.id != note.themeID {
      if let themeID = note.themeID {
        let themeDescriptor = FetchDescriptor<ThemeEntity>(
          predicate: #Predicate { $0.id == themeID }
        )
        
        entity.theme = try? context.fetch(themeDescriptor).first
      } else {
        entity.theme = nil
      }
    }
    
    saveContext()
  }
  
  func delete(_ note: Note) {
    guard let entity = findEntity(by: note.id) else {
      return
    }
    
    context.delete(entity)
    saveContext()
  }
}
