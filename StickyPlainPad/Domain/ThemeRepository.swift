//
//  ThemeRepository.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 4/10/25.
//

protocol ThemeRepository {
  func fetchAll() -> [Theme]
  func add(_ theme: Theme)
  func update(_ theme: Theme)
  func delete(_ theme: Theme)
}
