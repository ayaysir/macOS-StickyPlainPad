//
//  NoteListView.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 3/29/25.
//

import SwiftUI
import SwiftData

struct NoteListView: View {
  @Environment(\.openWindow) private var openWindow
  
  @Environment(\.modelContext) private var modelContext
  @Query private var notes: [Note]
  
  var body: some View {
    VStack {
      List {
        Button(action: addItem) {
          Label("Add", systemImage: "plus")
        }
        
        ForEach(notes) { note in
          Button {
            openWindow(value: note.id)
          } label: {
            Text("\(note.content), \(note.createdTimestamp)")
          }
          .contextMenu {
            Button(role: .destructive) {
              modelContext.delete(note)
            } label: {
              Text("삭제")
            }
          }
        }
        .onDelete(perform: deleteItems)
      }
    }
    .onAppear {
      notes.forEach {
        openWindow(value: $0.id)
      }
    }
  }
  
  private func addItem() {
    withAnimation {
      let newNote = Note(
        createdTimestamp: .now,
        content: generateRandomUppercaseString(),
        backgroundColorHex: "#FFFFFF"
      )
      
      modelContext.insert(newNote)
    }
  }
  
  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      for index in offsets {
        modelContext.delete(notes[index])
      }
    }
  }
  
  func generateRandomUppercaseString(length: Int = 5) -> String {
    let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    return String((0..<length).map { _ in letters.randomElement()! })
  }

}

#Preview {
  NoteListView()
    .modelContainer(for: Note.self, inMemory: true)
}
