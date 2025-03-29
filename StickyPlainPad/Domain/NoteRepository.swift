//
//  NoteRepository.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 3/29/25.
//

import Foundation

protocol NoteRepository {
  func fetchAll() -> [Note]
  func add(_ note: Note)
  func update(_ note: Note)
  func delete(_ note: Note)
}
