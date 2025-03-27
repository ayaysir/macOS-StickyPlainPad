//
//  ContentView.swift
//  PlainTextEditor-iOS
//
//  Created by 윤범태 on 3/27/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
  @Environment(\.modelContext) private var modelContext
  @Query private var notes: [Note]
  
  @State private var showEditSheet = false
  @State private var updateNote: Note?
  @State private var editText = ""
  
  var body: some View {
    NavigationSplitView {
      List {
        ForEach(notes) { note in
          NavigationLink {
            Text(note.content)
          } label: {
            Text("\(note.content), \(note.createdTimestamp)")
          }
          .contextMenu {
            Button {
              showEditSheet.toggle()
              updateNote = note
              editText = note.content
            } label: {
              Text("업데이트")
            }
            Divider()
            Button(role: .destructive) {
              modelContext.delete(note)
            } label: {
              Text("삭제")
            }
          }
        }
        .onDelete(perform: deleteItems)
      }
      .navigationSplitViewColumnWidth(min: 180, ideal: 200)
      .toolbar {
        ToolbarItem {
          Button(action: {
            showEditSheet.toggle()
            updateNote = nil
          }) {
            Label("Add Item", systemImage: "plus")
          }
        }
      }
      .sheet(isPresented: $showEditSheet) {
        VStack {
          TextEditor(text: $editText)
          Button(updateNote != nil ? "Update" : "Submit") {
            if updateNote != nil {
              updateItem()
            } else {
              addItem()
            }
          }
          .buttonStyle(.borderedProminent)
        }
      }
    } detail: {
      Text("Select an item")
    }
  }
  
  private func addItem() {
    withAnimation {
      let newNote = Note(
        createdTimestamp: .now,
        content: editText,
        backgroundColorHex: "#FFFFFF"
      )
      
      modelContext.insert(newNote)
      showEditSheet.toggle()
      editText = ""
    }
  }
  
  private func updateItem() {
    updateNote?.modifiedTimestamp = .now
    updateNote?.content = editText
    
    showEditSheet.toggle()
    editText = ""
  }
  
  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      for index in offsets {
        modelContext.delete(notes[index])
      }
    }
  }
}

#Preview {
  ContentView()
    .modelContainer(for: Note.self, inMemory: true)
}
