//
//  NoteEntity.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 3/25/25.
//

import Foundation
import SwiftData
import SwiftUICore

@Model
final class NoteEntity {
  @Attribute(.unique) var id: UUID
  var createdAt: Date = Date.now
  var modifiedAt: Date?
  var content: String = ""
  var fileURL: URL?
  
  var windowFrame: Rect?
  var isPinned: Bool = false
  var fontSize: CGFloat = 14
  var lastWindowFocusedAt: Date?
  var isWindowOpened: Bool = false
  var isWindowShrinked: Bool = false
  
  @Relationship
  var theme: ThemeEntity? // 관계 정의 (Many-to-One)
  
  // Thread 1: Fatal error: Composite Coder only supports Keyed Container
  // var windowFrame: CGRect?
  
  init(from note: Note, in context: ModelContext) {
    self.id = note.id
    self.createdAt = note.createdAt
    self.modifiedAt = note.modifiedAt
    self.content = note.content
    self.fileURL = note.fileURL
    self.windowFrame = note.windowFrame
    self.isPinned = note.isPinned
    self.fontSize = note.fontSize
    self.lastWindowFocusedAt = note.lastWindowFocusedAt
    self.isWindowOpened = note.isWindowOpened

    if let themeID = note.themeID {
      let descriptor = FetchDescriptor<ThemeEntity>(
        predicate: #Predicate { $0.id == themeID }
      )
      self.theme = try? context.fetch(descriptor).first
    }
    
    self.isWindowShrinked = note.isWindowShrinked
  }

  func toDomain() -> Note {
    .init(
      id: id,
      createdAt: createdAt,
      modifiedAt: modifiedAt,
      content: content,
      fileURL: fileURL,
      
      windowFrame: windowFrame,
      isPinned: isPinned,
      fontSize: fontSize,
      lastWindowFocusedAt: lastWindowFocusedAt,
      isWindowOpened: isWindowOpened,
      
      themeID: theme?.id
    )
  }
}
