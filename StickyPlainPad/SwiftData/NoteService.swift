//
//  NoteService.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 3/29/25.
//

import Foundation
import SwiftData

@MainActor func fetchNote(by id: NoteEntity.ID) -> NoteEntity? {
  let context = StickyPlainPadApp.sharedModelContainer.mainContext
  let predicate = #Predicate<NoteEntity> { $0.id == id }
  let descriptor = FetchDescriptor<NoteEntity>(predicate: predicate)
  
  return try? context.fetch(descriptor).first
}
