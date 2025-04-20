//
//  NoteThemeSelectView.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 4/15/25.
//

import SwiftUI

struct NoteThemeSelectView: View {
  @Environment(\.dismiss) var dismiss
  @Environment(\.openWindow) var openWindow
  
  @Binding private var note: Note
  @State private var noteViewModel: NoteViewModel
  @State private var themeViewModel: ThemeViewModel
  
  init(
    note: Binding<Note>,
    noteViewModel: NoteViewModel,
    themeViewModel: ThemeViewModel
  ) {
    _note = note
    _noteViewModel = State(initialValue: noteViewModel)
    _themeViewModel = State(initialValue: themeViewModel)
  }
  
  var body: some View {
    VStack {
      HStack {
        Text("loc_select_theme")
          .font(.title2)
        Button(action: { openWindow(id: .idThemeNewWindow) }) {
          Text("loc_theme_manager_ellipsis")
        }
        Spacer()
        Button(action: dismiss.callAsFunction) {
          Text("loc_close")
        }
      }
      .padding()
      List {
        ForEach(themeViewModel.themes) { theme in
          Button(action: {
            updateTheme(themeID: theme.id)
            dismiss()
          }) {
            ThemeLabelView(theme: theme)
          }
        }
      }
      .buttonStyle(.plain)
    }
  }
  
  private func updateTheme(themeID: Theme.ID) {
    note.themeID = themeID
    note = noteViewModel.updateNote(note)
  }
}

#Preview {
  NoteThemeSelectView(
    note: .constant(.init(
      id: .init(),
      createdAt: .now,
      content: "Content"
    )),
    noteViewModel: .init(
      repository: NoteRepositoryImpl(
        context: .forPreviewContext
      )
    ),
    themeViewModel: .init(
      repository: ThemeRepositoryImpl(
        context: .forPreviewContext
      )
    )
  )
}
