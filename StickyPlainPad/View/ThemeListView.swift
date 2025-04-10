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
            navLabel(theme: theme)
          }
          // NavigationLink {
          //   ThemeView(theme: theme, themeViewModel: viewModel)
          // } label: {
          //   navLabel(theme: theme)
          // }
          .contextMenu {
            Button {
              viewModel.deleteTheme(theme)
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
          Button {
            addNewTheme()
          } label: {
            Label("Add Theme", systemImage: "plus")
          }
        }
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
      Text("테마를 선택하세요")
    }
  }
  
  private func navLabel(theme: Theme) -> some View {
    HStack {
      Rectangle()
        .fill(Color(hex: theme.backgroundColorHex) ?? .black)
        .frame(width: 20)
        .overlay {
          Text("A")
            .foregroundStyle(Color(hex: theme.textColorHex) ?? .white)
        }
      Text(theme.name)
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
      name: "New Theme",
      backgroundColorHex: "#FFFFFF",
      textColorHex: "#000000"
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
