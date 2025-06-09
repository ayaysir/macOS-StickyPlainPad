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
  
  @State private var searchText = ""
  var filteredNotes: [Note] {
    if searchText.isEmpty {
      return viewModel.notes
    } else {
      return viewModel.notes.filter {
        // case-insensitive
        $0.content.range(of: searchText, options: .caseInsensitive) != nil
      }
    }
  }
  
  var body: some View {
    VStack {
      List {
        ForEach(filteredNotes) { note in
          Button {
            // openWindow(value: note.id)
            NoteEditWindowManager.shared.open(
              noteViewModel: viewModel,
              themeViewModel: themeViewModel,
              note: note,
              previewText: note.content
            )
          } label: {
            label(note: note)
          }
          .buttonStyle(.plain)
          .contextMenu {
            Button(role: .destructive) {
              let noteID = note.id
              viewModel.deleteNote(note)
              NoteEditWindowManager.shared.closeGhostWindow(noteID: noteID)
            } label: {
              Text("loc_delete_note")
            }
          }
        }
        .onDelete(perform: deleteItems)
      }
      .searchable(text: $searchText, prompt: "loc_search_content")
      .toolbar {
        ToolbarItem {
          Button(action: addItem) {
            Label("loc_add_note", systemImage: "plus")
          }
          .help("loc_add_note")
        }
#if DEBUG
        ToolbarItem {
          Button("to JSON") {
            let simpleNotes = viewModel.notes.map {
              InitNote(id: $0.id, content: $0.content)
            }
            
            print(simpleNotes.encodeToJSON() ?? "-")
          }
        }
#endif
      }
    }
    .onAppear {
      viewModel.lastOpenedNotes.forEach { note in
        NoteEditWindowManager.shared.open(
          noteViewModel: viewModel,
          themeViewModel: themeViewModel,
          note: note,
          previewText: note.content
        )
      }
    }
  }
  
  private func label(note: Note) -> some View {
    VStack(alignment: .leading) {
      HStack {
        if note.content.isEmpty {
          Text("loc_empty_note")
            .italic()
            .foregroundStyle(.gray)
        } else {
          Text(verbatim: note.content.truncated())
        }
        Spacer()
        Text(verbatim: "\(note.createdAt.formatted(date: .long, time: .shortened))")
          .foregroundStyle(.gray)
          .font(.caption)
      }
      if !searchText.isEmpty,
         let excerpt = note.content.excerpt(around: searchText, maxLength: 70)?.replacingOccurrences(of: "\n", with: " ") {
        HighlightedText(
          fullText: "...\(excerpt)...",
          keywords: [searchText]
        )
      }
    }
  }
  
  private func addItem() {
    NoteEditWindowManager.shared.addNewNoteAndOpen(
      noteViewModel: viewModel,
      themeViewModel: themeViewModel
    )
  }
  
  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      for index in offsets {
        let noteID = viewModel.deleteNote(index: index)
        NoteEditWindowManager.shared.closeGhostWindow(noteID: noteID)
      }
    }
  }
  
  private func closeWindow(note: Note) {
    if let window = NoteEditWindowManager.shared.openWindows.first(where: { $0.noteID == note.id }) {
      NoteEditWindowManager.shared.closeWindowAndRemoveFromCommandMenu(window, note: note, noteViewModel: viewModel)
    }
  }
  
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
  
}

#Preview {
  NoteListView(
    context: .forPreviewContext
  )
}
