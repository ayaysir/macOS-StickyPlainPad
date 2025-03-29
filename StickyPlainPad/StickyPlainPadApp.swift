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
  @State private var windowOffsets: [Note.ID: CGSize] = [:]
  
  static var sharedModelContainer: ModelContainer = {
    let schema = Schema([
      Note.self,
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
  
  var body: some Scene {
    // 디버그용 리스트 창 (목록을 어디에 배치할지 추후 결정)
    Window("List", id: "list") {
      NoteListView()
    }
    .modelContainer(Self.sharedModelContainer)
    
    // 포스트잇 창
    WindowGroup("Notes", for: Note.ID.self) { $noteID in
      if let noteID, let note = fetchNote(by: noteID) {
        NoteEditView(note: note)
          // .frame(width: 600, height: 400) // 창 크기 설정
          // .offset(windowOffsets[noteID] ?? .zero) // 계단식 배치
          // .onAppear {
          //   if windowOffsets[noteID] == nil {
          //     let offsetValue = CGFloat(windowOffsets.count) * 40
          //     windowOffsets[noteID] = CGSize(width: offsetValue, height: -offsetValue)
          //   }
          // }
      } else {
        Text("Note is nil.")
      }
    }
    .defaultSize(width: 600, height: 400) // 기본 창 크기 설정
    .windowResizability(.contentSize)
  }
}
