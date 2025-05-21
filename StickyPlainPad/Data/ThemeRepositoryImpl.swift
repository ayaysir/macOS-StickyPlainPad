//
//  ThemeRepositoryImpl.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 4/10/25.
//

import Foundation
import SwiftData

final class ThemeRepositoryImpl: ThemeRepository {
  private let context: ModelContext

  init(context: ModelContext) {
    self.context = context
  }

  func fetchAll() -> [Theme] {
    let descriptor = FetchDescriptor<ThemeEntity>(
      sortBy: [SortDescriptor(\.createdAt)]
    )
    
    return (try? context.fetch(descriptor))?.map { $0.toDomain() } ?? []
  }

  func add(_ theme: Theme) {
    let entity = ThemeEntity(from: theme)
    context.insert(entity)
    try? context.save()
  }

  func update(_ theme: Theme) {
    let descriptor = FetchDescriptor<ThemeEntity>(
      predicate: #Predicate { $0.id == theme.id }
    )
    
    if let entity = try? context.fetch(descriptor).first {
      entity.name = theme.name
      entity.modifiedAt = theme.modifiedAt ?? .now
      entity.backgroundColorHex = theme.backgroundColorHex
      entity.textColorHex = theme.textColorHex
      entity.fontName = theme.fontName
      entity.fontSize = theme.fontSize
      entity.fontTraits = theme.fontTraits
      try? context.save()
    }
  }

  func delete(_ theme: Theme) {
    let descriptor = FetchDescriptor<ThemeEntity>(
      predicate: #Predicate { $0.id == theme.id }
    )
    
    if let entity = try? context.fetch(descriptor).first {
      context.delete(entity)
      try? context.save()
    }
  }
}
