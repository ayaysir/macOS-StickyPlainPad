//
//  ThemeViewModel.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 4/10/25.
//

import Foundation

@Observable
class ThemeViewModel {
  private let repository: ThemeRepository

  // 외부에서 바인딩 가능한 Theme 목록
  private(set) var themes: [Theme] = []

  init(repository: ThemeRepository) {
    self.repository = repository
    fetchAllThemes()
  }

  func fetchAllThemes() {
    themes = repository.fetchAll()
  }

  func addTheme(name: String, backgroundColorHex: String, textColorHex: String) {
    let theme = Theme(
      id: UUID(),
      createdAt: .now,
      modifiedAt: nil,
      name: name,
      backgroundColorHex: backgroundColorHex,
      textColorHex: textColorHex
    )
    repository.add(theme)
    fetchAllThemes()
  }

  func updateTheme(_ theme: Theme) {
    var updated = theme
    updated.modifiedAt = .now
    repository.update(updated)
    fetchAllThemes()
  }

  func deleteTheme(_ theme: Theme) {
    repository.delete(theme)
    fetchAllThemes()
  }
}
