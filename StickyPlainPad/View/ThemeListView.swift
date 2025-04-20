//
//  ThemeListView.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 4/10/25.
//

import SwiftUI

struct ThemeListView: View {
  @Environment(\.dismissWindow) private var dismissWindow
  @State private var viewModel: ThemeViewModel
  
  @State private var showNewTheme = false
  @State private var selectedThemeID: Theme.ID?
  
  init(themeViewModel: ThemeViewModel) {
    _viewModel = State(initialValue: themeViewModel)
  }
  
  var body: some View {
    NavigationSplitView {
      List(selection: $selectedThemeID) {
        ForEach(viewModel.themes) { theme in
          NavigationLink(value: theme.id) {
            ThemeLabelView(theme: theme)
          }
          .contextMenu {
            Button {
              viewModel.deleteTheme(theme)
            } label: {
              Text("loc_delete_theme")
            }
          }
        }
        .onDelete(perform: deleteItems)
      }
      .navigationSplitViewColumnWidth(min: 180, ideal: 200)
      .toolbar {
        ToolbarItem {
          Button {
            addNewTheme()
          } label: {
            Label("loc_add_theme", systemImage: "plus")
          }
        }
#if DEBUG
        ToolbarItem {
          Button("to Json") {
            print(viewModel.themes.encodeToJSON() ?? "-")
          }
        }
#endif
      }
    } detail: {
      detail
    }
  }
  
  @ViewBuilder
  private var detail: some View {
    if let selectedThemeID,
       let theme = viewModel.theme(withID: selectedThemeID) {
      ThemeView(theme: theme, themeViewModel: viewModel)
    } else {
      Text("loc_select_theme")
    }
  }
  
  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      for index in offsets {
        viewModel.deleteTheme(viewModel.themes[index])
      }
    }
  }
  
  private func addNewTheme() {
    let newTheme = viewModel.addTheme(
      name: "loc_new_theme".localized,
      backgroundColorHex: "#FFFFFF",
      textColorHex: "#000000",
      fontName: "SF Pro",
      fontSize: 14
    )
    
    DispatchQueue.main.async {
      selectedThemeID = newTheme.id
    }
  }
}

#Preview {
  ThemeListView(
    themeViewModel: .init(
      repository: ThemeRepositoryImpl(context: .forPreviewContext)
    )
  )
}
