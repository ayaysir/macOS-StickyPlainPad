//
//  NewThemeView.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 4/10/25.
//

import SwiftUI

struct ThemeView: View {
  @Environment(\.dismissWindow) private var dismissWindow
  @State private var viewModel: ThemeViewModel
  
  @State private var name: String = ""
  @State private var backgroundColor = Color.white
  @State private var textColor = Color.black
  
  init(themeViewModel: ThemeViewModel) {
    _viewModel = State(initialValue: themeViewModel)
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("새 테마 추가")
        .font(.title2)
        .padding(.bottom, 8)
      
      TextField("이름", text: $name)
      
      HStack {
        Text("배경색:")
        ColorPicker("", selection: $backgroundColor)
      }
      
      HStack {
        Text("글자색:")
        ColorPicker("", selection: $textColor)
      }
      
      HStack {
        Spacer()
        Button("취소") {
          dismissWindow(id: "theme-new-window")
        }
        
        Button("추가") {
          viewModel.addTheme(
            name: name,
            backgroundColorHex: backgroundColor.toHex() ?? "",
            textColorHex: textColor.toHex() ?? ""
          )
          dismissWindow(id: "theme-new-window")
        }
        .keyboardShortcut(.defaultAction)
      }
    }
    .padding()
    .frame(width: 300)
  }
}

#Preview {
  ThemeView(
    themeViewModel: .init(
      repository: ThemeRepositoryImpl(context: .forPreviewContext)
    )
  )
}
