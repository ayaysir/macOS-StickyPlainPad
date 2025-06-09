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
  
  @AppStorage(.cfgThemeDefaultID) var defaultThemeID: String = ""
  
  init(themeViewModel: ThemeViewModel) {
    _viewModel = State(initialValue: themeViewModel)
  }
  
  var body: some View {
    NavigationSplitView {
      ListArea
      .navigationSplitViewColumnWidth(min: 180, ideal: 200)
      .toolbar { themeToolbar }
    } detail: {
      DetailArea
    }
  }
}

extension ThemeListView {
  // MARK: - Serapated views
  
  @ViewBuilder
  private var DetailArea: some View {
    if let selectedThemeID,
       let theme = viewModel.theme(withID: selectedThemeID) {
      ThemeView(theme: theme, themeViewModel: viewModel)
    } else {
      Text("loc_select_theme")
    }
  }
  
  private var ListArea: some View {
    List(selection: $selectedThemeID) {
      ForEach(viewModel.themes) { theme in
        NavigationLink(value: theme.id) {
          HStack {
            ThemeLabelView(theme: theme)
            if defaultThemeID == theme.id.uuidString {
              Text("loc.default")
                .italic()
                .foregroundStyle(Color.gray)
            }
          }
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
  }
  
  // 분리한 클로저 (ToolbarContent 반환)
  private var themeToolbar: some ToolbarContent {
    ToolbarItemGroup {
      Button {
        addNewTheme()
      } label: {
        Label("loc_add_theme", systemImage: "plus")
      }

  #if DEBUG
      Button("to Json") {
        print(viewModel.themes.encodeToJSON() ?? "-")
      }
  #endif
    }
  }
}

extension ThemeListView {
  // MARK: - View related functions
  
  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      for index in offsets {
        viewModel.deleteTheme(viewModel.themes[index])
      }
    }
  }
  
  private func addNewTheme() {
    viewModel.availableFontMembers(ofFontFamily: "SF Pro")
    
    let newTheme = viewModel.addTheme(
      name: "loc_new_theme".localized,
      backgroundColorHex: "#FFFFFF",
      textColorHex: "#000000",
      fontName: "SF Pro",
      fontSize: 14,
      fontTraits: viewModel.availableFontStyles.first?.dataDescription ?? nil
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
