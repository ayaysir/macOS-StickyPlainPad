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
  
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack {
        Text("이름")
        TextField("테마 이름을 입력하세요.", text: $themeName)
          .focused($isNameFocused)
          .padding()
      }
      
      ZStack(alignment: .top) {
        backgroundColor
        Text("""
          글자 크기는 스티커에서 트랙패드를 확대하거나
          단축키 command와 [+], [-] 버튼을 눌러
          조정할 수 있습니다.
          """)
        .foregroundStyle(textColor)
        .multilineTextAlignment(.leading)
        .padding(8)
      }
      .frame(height: 150)
      
      HStack {
        Text("배경색:")
        ColorPicker("", selection: $backgroundColor)
      }
      
      HStack {
        Text("글자색:")
        ColorPicker("", selection: $textColor)
      }
      
    }
    .padding()
    .frame(width: 300)
    .onAppear {
      initColors()
      moveFoucsToTextField()
    }
    /*
     문제점
     of: theme로 하면 외부 영향에 의해 계속 호출됨, id만 변경되었을때로 제한
     */
    .onChange(of: theme.id) {
      initColors()
      moveFoucsToTextField()
      // print("ThemeView: OnChange")
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
  }
  
  private func initColors() {
    themeName = theme.name
    backgroundColor = .init(hex: theme.backgroundColorHex) ?? .white
    textColor = .init(hex: theme.textColorHex) ?? .black
  }
  
  private func moveFoucsToTextField() {
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
      textColorHex: "#000000"
    ),
    themeViewModel: .init(
      repository: ThemeRepositoryImpl(
        context: .forPreviewContext
      )
    )
  )
}
