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
final class NoteEntity: Identifiable {
  @Attribute(.unique) var id: UUID = UUID()
  var createdAt: Date = Date.now
  var modifiedAt: Date?
  var content: String = ""
  var fileURL: URL?
  var backgroundColorHex: String = "#FFFFFF" // -> 테마
  var windowFrame: Rect?
  var isPinned: Bool = false
  var fontSize: CGFloat = 14
  
  // Thread 1: Fatal error: Composite Coder only supports Keyed Container
  // var windowFrame: CGRect?
  
  init(
    id: NoteEntity.ID,
    createdAt: Date,
    modifiedAt: Date? = nil,
    content: String,
    fileURL: URL? = nil,
    backgroundColorHex: String,
    windowFrame: Rect?
  ) {
    self.createdAt = createdAt
    self.modifiedAt = modifiedAt
    self.content = content
    self.fileURL = fileURL
    self.backgroundColorHex = backgroundColorHex
    self.windowFrame = windowFrame
  }
}
