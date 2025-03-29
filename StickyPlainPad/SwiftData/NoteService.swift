//
//  NoteService.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 3/29/25.
//

import Foundation
import SwiftData

@MainActor func fetchNote(by id: Note.ID) -> Note? {
  let context = StickyPlainPadApp.sharedModelContainer.mainContext
  let predicate = #Predicate<Note> { $0.id == id }
  let descriptor = FetchDescriptor<Note>(predicate: predicate)
  
  return try? context.fetch(descriptor).first
}
