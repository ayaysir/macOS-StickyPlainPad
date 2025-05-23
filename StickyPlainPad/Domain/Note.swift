//
//  Note.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 3/29/25.
//

import Foundation

struct Note: Codable, Identifiable, Hashable {
  let id: UUID
  var createdAt: Date
  var modifiedAt: Date?
  var content: String
  var fileURL: URL?
  
  var windowFrame: Rect?
  var isPinned: Bool = false
  var fontSize: CGFloat = 14
  var lastWindowFocusedAt: Date?
  var isWindowOpened: Bool = false
  
  var themeID: UUID?
  var isWindowShrinked: Bool = false
}

struct InitNote: Codable, Identifiable, Hashable {
  let id: UUID
  var content: String
}
