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
  
  @State private var viewModel: NoteViewModel
  @State private var themeViewModel: ThemeViewModel
  
  init(context: ModelContext) {
    _viewModel = State(
      initialValue: NoteViewModel(
        repository: NoteRepositoryImpl(context: context)
      )
    )
    
    _themeViewModel = State(
      initialValue: ThemeViewModel(
        repository: ThemeRepositoryImpl(context: context)
      )
    )
  }
  
  init(viewModel: NoteViewModel, themeViewModel: ThemeViewModel) {
    _viewModel = State(initialValue: viewModel)
    _themeViewModel = State(initialValue: themeViewModel)
  }
  
  var body: some View {
    VStack {
      List {
        Button(action: addItem) {
          Label("Add", systemImage: "plus")
        }
        
        ForEach(viewModel.notes) { note in
          Button {
            // openWindow(value: note.id)
            NoteEditWindowMananger.shared.open(
              noteViewModel: viewModel,
              themeViewModel: themeViewModel,
              note: note,
              previewText: note.content
            )
          } label: {
            Text("\(note.content.truncated()), \(note.createdAt)")
          }
          .buttonStyle(.plain)
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
      viewModel.lastOpenedNotes.forEach { note in
        NoteEditWindowMananger.shared.open(
          noteViewModel: viewModel,
          themeViewModel: themeViewModel,
          note: note,
          previewText: note.content
        )
      }
    }
  }
  
  private func addItem() {
    NoteEditWindowMananger.shared.addEmptyNoteAndOpen(
      noteViewModel: viewModel,
      themeViewModel: themeViewModel
    )
  }
  
  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      for index in offsets {
        viewModel.deleteNote(index: index)
      }
    }
  }
}

#Preview {
  NoteListView(
    context: .forPreviewContext
  )
}
