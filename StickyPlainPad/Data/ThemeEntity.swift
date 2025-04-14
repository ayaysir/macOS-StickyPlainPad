//
//  ThemeEntity.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 4/10/25.
//

import Foundation
import SwiftData

@Model
class ThemeEntity {
  var id: UUID
  var createdAt: Date
  var modifiedAt: Date?
  var name: String
  var backgroundColorHex: String
  var textColorHex: String
  
  var fontName: String
  var fontSize: CGFloat
  var fontTraits: String?

  @Relationship(inverse: \NoteEntity.theme)
  var notes: [NoteEntity] = []

  init(from theme: Theme) {
    self.id = theme.id
    self.createdAt = theme.createdAt
    self.modifiedAt = theme.modifiedAt
    self.name = theme.name
    self.backgroundColorHex = theme.backgroundColorHex
    self.textColorHex = theme.textColorHex
    self.fontName = theme.fontName
    self.fontSize = theme.fontSize
    self.fontTraits = theme.fontTraits
  }

  func toDomain() -> Theme {
    .init(
      id: id,
      createdAt: createdAt,
      modifiedAt: modifiedAt,
      name: name,
      backgroundColorHex: backgroundColorHex,
      textColorHex: textColorHex,
      fontName: fontName,
      fontSize: fontSize,
      fontTraits: fontTraits
    )
  }
}
