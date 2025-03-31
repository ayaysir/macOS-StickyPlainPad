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
            // openWindow(value: note.id)
            NoteEditWindowMananger.shared.open(
              noteViewModel: viewModel,
              noteID: note.id,
              previewText: note.content
            )
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
      // viewModel.notes.forEach {
      //   openWindow(value: $0.id)
      // }
    }
  }
  
  private func addItem() {
    let newPos = NoteEditWindowMananger.shared.newWindowPos
    let firstPos = NoteEditWindowMananger.shared.newWindowPosFirst
    let windowSize = NoteEditWindowMananger.shared.windowSize
    
    var firstWindowFrame: Rect {
      .init(
        originX: newPos?.x ?? firstPos.x ,
        originY: newPos?.y ?? firstPos.y,
        width: windowSize.width,
        height: windowSize.height
      )
    }
    
    withAnimation {
      let id = viewModel.addEmptyNote(windowFrame: firstWindowFrame)
      NoteEditWindowMananger.shared.appendCreateWindowCount()
      
      NoteEditWindowMananger.shared.open(
        noteViewModel: viewModel,
        noteID: id
      )
    }
  }
  
  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      for index in offsets {
        viewModel.deleteNote(index: index)
      }
    }
  }
}

extension NoteListView {

}

#Preview {
  NoteListView(
    context: .forPreviewContext
  )
}
