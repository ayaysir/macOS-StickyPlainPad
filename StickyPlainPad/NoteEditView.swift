//
//  NoteEditView.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 3/29/25.
//

import SwiftUI

struct NoteEditView: View {
  let note: Note
  @State private var currentContent = ""
  
  var body: some View {
    TextEditor(text: $currentContent)
      .onAppear {
        currentContent = note.content
      }
      .onChange(of: currentContent) {
        note.content = currentContent
      }
  }
}

#Preview {
  NoteEditView(
    note: .init(
      createdTimestamp: .now,
      content: "Test",
      backgroundColorHex: "#FFFFFF"
    )
  )
}
