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
        Button(action: addItem) {
          Label("Add", systemImage: "plus")
        }
        
        ForEach(filteredNotes) { note in
          Button {
            // openWindow(value: note.id)
            NoteEditWindowMananger.shared.open(
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
              viewModel.deleteNote(note)
            } label: {
              Text("삭제")
            }
          }
        }
        .onDelete(perform: deleteItems)
      }
      .searchable(text: $searchText, prompt: "제목, 내용으로 검색")
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
  
  private func label(note: Note) -> some View {
    VStack(alignment: .leading) {
      HStack {
        if note.content.isEmpty {
          Text("Empty Sticker")
            .italic()
            .foregroundStyle(.gray)
        } else {
          Text(verbatim: note.content.truncated())
        }
        Spacer()
        Text(verbatim: "\(note.createdAt)")
          .foregroundStyle(.gray)
          .font(.caption)
      }
      if !searchText.isEmpty,
         let excerpt = note.content.excerpt(around: searchText, maxLength: 70)?.replacingOccurrences(of: "\n", with: " ") {
        let _ = print(note.content.truncated(), excerpt)
        HighlightedText(
          fullText: "...\(excerpt)...",
          keywords: [searchText]
        )
      }
    }
  }
  
  private func addItem() {
    NoteEditWindowMananger.shared.addNewNoteAndOpen(
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
