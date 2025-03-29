//
//  SwiftData.ModelContainer+.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 3/30/25.
//

import SwiftData

extension ModelContainer {
  /*
   ModelContainer를 computed property로 만들면 안됨: EXC_BREAKPOINT 에러 발생
   */
  static let mainModelContainer: ModelContainer = {
    let schema = Schema([
      NoteEntity.self,
    ])
    
    let modelConfiguration = ModelConfiguration(
      schema: schema,
      isStoredInMemoryOnly: false
    )
    
    do {
      return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()
  
  static let previewModelContainer: ModelContainer = {
    let schema = Schema([
      NoteEntity.self,
    ])
    
    let modelConfiguration = ModelConfiguration(
      schema: schema,
      isStoredInMemoryOnly: true
    )
    
    do {
      return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()
}
