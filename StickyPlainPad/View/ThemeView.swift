//
//  NewThemeView.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 4/10/25.
//

import SwiftUI

struct ThemeView: View {
  @Environment(\.dismissWindow) private var dismissWindow
  let theme: Theme
  @State var themeViewModel: ThemeViewModel
  
  @State private var themeName = "Unknown"
  @State private var backgroundColor: Color = .white
  @State private var textColor: Color = .black
  
  @State private var showDuplicateAlert = false
  @FocusState private var isNameFocused: Bool
  
  @State private var selectedFontName: String = ""
  
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("loc_preview")
        .font(.title3)
        .fontWeight(.semibold)
      ZStack(alignment: .top) {
        backgroundColor
        Text("loc_adjust_font_size_instruction")
        .multilineTextAlignment(.leading)
        .font(.custom(selectedFontName, size: 17))
        .foregroundStyle(textColor)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(5)
      }
      .frame(height: 150)
      
      HStack {
        Text("loc_theme_name")
          .font(.title3)
          .fontWeight(.semibold)
        TextField("loc_enter_theme_name", text: $themeName)
          .focused($isNameFocused)
          .padding()
      }
      
      Divider()
      
      VStack(alignment: .leading) {
        Text("loc_color_settings")
          .font(.title3)
          .fontWeight(.semibold)
        
        HStack {
          Text("loc_background_color_colon")
          ColorPicker("", selection: $backgroundColor)
        }
        
        HStack {
          Text("loc_text_color_colon")
          ColorPicker("", selection: $textColor)
        }
        Spacer()
      }
      
      Divider()
      
      VStack(alignment: .leading, spacing: 10) {
        Text("loc_font_settings")
          .font(.title3)
          .fontWeight(.semibold)
        
        Picker("loc_font", selection: $selectedFontName) {
          ForEach(themeViewModel.availableFonts, id: \.self) { fontTitleStr in
            Text(fontTitleStr)
              .font(Font.custom(fontTitleStr, size: 14))
              .tag(fontTitleStr)
          }
        }
        
        Spacer()
      }
    }
    .padding()
    .onAppear {
      initColors()
      initFonts()
      moveFocusToTextField()
    }
    /*
     문제점
     of: theme로 하면 외부 영향에 의해 계속 호출됨, id만 변경되었을때로 제한
     */
    .onChange(of: theme.id) {
      initColors()
      initFonts()
      moveFocusToTextField()
    }
    .onChange(of: themeName) {
      themeViewModel.updateTheme(id: theme.id, name: themeName)
    }
    .onChange(of: backgroundColor) {
      themeViewModel.updateTheme(
        id: theme.id,
        backgroundColorHex: backgroundColor.toHex()
      )
    }
    .onChange(of: textColor) {
      themeViewModel.updateTheme(
        id: theme.id,
        textColorHex: textColor.toHex()
      )
    }
    .onChange(of: selectedFontName) {
      themeViewModel.updateTheme(
        id: theme.id,
        fontName: selectedFontName
      )
    }
  }
  
  private func initColors() {
    themeName = theme.name
    backgroundColor = .init(hex: theme.backgroundColorHex) ?? .white
    textColor = .init(hex: theme.textColorHex) ?? .black
  }
  
  private func initFonts() {
    selectedFontName = theme.fontName
  }
  
  private func moveFocusToTextField() {
    if theme.name.contains("New Theme") {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        isNameFocused = true
      }
    }
  }
}

#Preview {
  ThemeView(
    theme: .init(
      id: .init(),
      createdAt: .now,
      name: "rksk",
      backgroundColorHex: "#FFFFFF",
      textColorHex: "#000000",
      fontName: "Gullim",
      fontSize: 20,
      fontTraits: ""
    ),
    themeViewModel: .init(
      repository: ThemeRepositoryImpl(
        context: .forPreviewContext
      )
    )
  )
}
