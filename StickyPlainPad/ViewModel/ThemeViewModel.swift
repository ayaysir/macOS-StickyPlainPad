//
//  ThemeViewModel.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 4/10/25.
//

import Foundation
import AppKit

@Observable
class ThemeViewModel {
  private let repository: ThemeRepository

  // 외부에서 바인딩 가능한 Theme 목록
  private(set) var themes: [Theme] = []
  
  var availableFonts: [String] {
    NSFontManager.shared.availableFontFamilies
  }

  init(repository: ThemeRepository) {
    self.repository = repository
    fetchAllThemes()
  }

  func fetchAllThemes() {
    themes = repository.fetchAll()
  }
  
  func theme(withID id: Theme.ID) -> Theme? {
    themes.first(where: { $0.id == id })
  }
  
  func themeExists(withName name: String) -> Bool {
    themes.contains { $0.name == name }
  }

  @discardableResult
  func addTheme(
    name: String,
    backgroundColorHex: String,
    textColorHex: String,
    fontName: String,
    fontSize: CGFloat
  ) -> Theme {
    let theme = Theme(
      id: UUID(),
      createdAt: .now,
      modifiedAt: nil,
      name: name,
      backgroundColorHex: backgroundColorHex,
      textColorHex: textColorHex,
      fontName: fontName,
      fontSize: fontSize
    )
    
    repository.add(theme)
    fetchAllThemes()
    
    return theme
  }
  
  @discardableResult
  func addTheme(from theme: Theme) -> Theme {
    repository.add(theme)
    fetchAllThemes()
    
    return theme
  }

  func updateTheme(_ theme: Theme) {
    var updated = theme
    updated.modifiedAt = .now
    repository.update(updated)
    fetchAllThemes()
  }
  
  func updateTheme(
    id: Theme.ID,
    name: String? = nil,
    backgroundColorHex: String? = nil,
    textColorHex: String? = nil,
    fontName: String? = nil,
    fontSize: CGFloat? = nil
  ) {
    guard var updated = theme(withID: id) else {
      print(#function, "Error: theme not found.")
      return
    }
    
    updated.modifiedAt = .now
    
    if let name {
      updated.name = name
    }

    if let backgroundColorHex {
      updated.backgroundColorHex = backgroundColorHex
    }

    if let textColorHex {
      updated.textColorHex = textColorHex
    }
    
    if let fontName {
      updated.fontName = fontName
    }
    
    if let fontSize {
      updated.fontSize = fontSize
    }

    repository.update(updated)
    fetchAllThemes()
  }

  func deleteTheme(_ theme: Theme) {
    repository.delete(theme)
    fetchAllThemes()
  }
}
