//
//  ThemeLabelView.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 4/15/25.
//

import SwiftUI

struct ThemeLabelView: View {
  let theme: Theme
  var baseFontOption: Font = .body
  
  var body: some View {
    HStack {
      Rectangle()
        .fill(Color(hex: theme.backgroundColorHex) ?? .black)
        .frame(width: 20)
        .overlay {
          Text("A")
            .font(.custom(theme.fontName, size: 14))
            .foregroundStyle(Color(hex: theme.textColorHex) ?? .white)
        }
      Text(theme.name)
        .font(baseFontOption)
      Spacer()
    }
    .frame(height: 20)
    .frame(maxHeight: 50)
    .contentShape(.rect)
  }
}

#Preview {
  ThemeLabelView(
    theme: .init(
      id: .init(),
      createdAt: .now,
      name: "Test theme",
      backgroundColorHex: "#FFFFFF",
      textColorHex: "#000000",
      fontName: "Impact",
      fontSize: 30
    )
  )
}
