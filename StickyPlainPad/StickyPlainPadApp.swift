//
//  StickyPlainPadApp.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 3/25/25.
//

import SwiftUI
import SwiftData

@main
struct StickyPlainPadApp: App {
  @State private var noteViewModel: NoteViewModel
  
  init() {
    _noteViewModel = State(
      initialValue: NoteViewModel(
        repository: NoteRepositoryImpl(context: Self.sharedModelContainer.mainContext)
      )
    )
  }
  
  static var sharedModelContainer: ModelContainer = {
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
  
  static var sharedModelContainerMemoryOnly: ModelContainer = {
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
  
  var body: some Scene {
    // 디버그용 리스트 창 (목록을 어디에 배치할지 추후 결정)
    Window("List", id: "list") {
      NoteListView(viewModel: noteViewModel)
    }
    .modelContainer(Self.sharedModelContainer)
    
    // 포스트잇 창
    
    WindowGroup("Notes", for: Note.ID.self) { $noteID in
      if let noteID = $noteID.wrappedValue {
        NoteEditView(noteViewModel: noteViewModel, noteID: noteID)
      } else {
        Text("Note is nil.")
      }
    }
    .defaultSize(width: 600, height: 400) // 기본 창 크기 설정
    .windowResizability(.contentSize)
  }
}
