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
  @Attribute(.unique) var id: UUID = UUID()
  var createdAt: Date = Date.now
  var modifiedAt: Date?
  var content: String = ""
  var fileURL: URL?
  var backgroundColorHex: String = "#FFFFFF" // -> 테마
  var windowFrame: Rect?
  var isPinned: Bool = false
  var fontSize: CGFloat = 14
  var lastWindowFocusedAt: Date?
  var isWindowOpened: Bool = false
  
  // Thread 1: Fatal error: Composite Coder only supports Keyed Container
  // var windowFrame: CGRect?
  
  init(
    id: NoteEntity.ID,
    createdAt: Date,
    modifiedAt: Date? = nil,
    content: String,
    fileURL: URL? = nil,
    backgroundColorHex: String,
    windowFrame: Rect?,
    isPinned: Bool = false,
    fontSize: CGFloat = 14,
    lastWindowFocusedAt: Date? = nil,
    isWindowOpened: Bool = false
  ) {
    self.id = id
    self.createdAt = createdAt
    self.modifiedAt = modifiedAt
    self.content = content
    self.fileURL = fileURL
    self.backgroundColorHex = backgroundColorHex
    self.windowFrame = windowFrame
    self.isPinned = isPinned
    self.fontSize = fontSize
    self.lastWindowFocusedAt = lastWindowFocusedAt
    self.isWindowOpened = isWindowOpened
  }
}
