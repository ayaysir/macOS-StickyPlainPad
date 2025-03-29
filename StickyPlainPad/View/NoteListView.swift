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
  
  // @Environment(\.modelContext) private var modelContext
  // @Query private var notes: [NoteEntity]
  
  @State private var viewModel: NoteViewModel
  
  init(context: ModelContext) {
    _viewModel = State(
      initialValue: NoteViewModel(
        repository: NoteRepositoryImpl(context: context)
      )
    )
  }
  
  init(viewModel: NoteViewModel) {
    _viewModel = State(initialValue: viewModel)
  }
  
  var body: some View {
    VStack {
      List {
        Button(action: addItem) {
          Label("Add", systemImage: "plus")
        }
        
        ForEach(viewModel.notes) { note in
          Button {
            openWindow(value: note.id)
          } label: {
            Text("\(note.content), \(note.createdAt)")
          }
          .contextMenu {
            Button(role: .destructive) {
              viewModel.deleteNote(note)
            } label: {
              Text("삭제")
            }
          }
        }
        .onDelete(perform: deleteItems)
      }
    }
    .onAppear {
      viewModel.notes.forEach {
        openWindow(value: $0.id)
      }
    }
  }
  
  private func addItem() {
    withAnimation {
      viewModel.addEmptyNote()
    }
  }
  
  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      for index in offsets {
        viewModel.deleteNote(index: index)
      }
    }
  }
  
  func generateRandomUppercaseString(length: Int = 5) -> String {
    let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    return String((0..<length).map { _ in letters.randomElement()! })
  }
}

#Preview {
  NoteListView(
    context: .memoryContext
  )
}
