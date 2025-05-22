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
      HeaderSection
      
      List {
        DefaultThemeButton
        ThemeButtonList
      }
      .buttonStyle(.plain)
    }
  }
}

extension NoteThemeSelectView {
  private var HeaderSection: some View {
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
  }
  
  private var DefaultThemeButton: some View {
    Button(action: {
      updateThemeToNil()
      dismiss()
    }) {
      ThemeLabelView(
        theme: .init(
          id: .init(),
          createdAt: .now,
          name: "loc_restore_default_theme".localized,
          backgroundColorHex: "#FCF4A7",
          textColorHex: "#000000",
          fontName: "SF Pro",
          fontSize: 15
        )
      )
    }
  }
  
  private var ThemeButtonList: some View {
    ForEach(themeViewModel.themes) { theme in
      Button(action: {
        updateTheme(themeID: theme.id)
        dismiss()
      }) {
        ThemeLabelView(theme: theme)
      }
    }
  }
}

extension NoteThemeSelectView {
  private func updateTheme(themeID: Theme.ID) {
    note.themeID = themeID
    note = noteViewModel.updateNote(note)
  }
  
  private func updateThemeToNil() {
    note.themeID = nil
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
