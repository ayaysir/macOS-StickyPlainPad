//
//  FindReplaceWindowView.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 4/17/25.
//

import SwiftUI

struct FindReplaceWindowView: View {
  @State private var findText = ""
  @State private var replaceText = ""
  @State private var scopeCurrentNote = true
  @State private var ignoreCase = true

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text("찾기:")
          .frame(width: 80, alignment: .trailing)
        TextField("", text: $findText)
          .textFieldStyle(RoundedBorderTextFieldStyle())
      }

      HStack {
        Text("대체할 단어:")
          .frame(width: 80, alignment: .trailing)
        TextField("", text: $replaceText)
          .textFieldStyle(RoundedBorderTextFieldStyle())
      }

      HStack {
        Text("옵션:")
          .frame(width: 80, alignment: .trailing)

        Picker("", selection: $scopeCurrentNote) {
          Text("현재 메모").tag(true)
          Text("모든 메모").tag(false)
        }
        .pickerStyle(RadioGroupPickerStyle())
        .frame(width: 160, alignment: .leading)

        Toggle("영문 대소문자 무시", isOn: $ignoreCase)
      }

      HStack {
        HStack(spacing: 8) {
          Button("모두 대치") {}
          Button("대치") {}
          Button("대치 및 찾기") {}
        }

        Spacer()

        HStack(spacing: 8) {
          Button("이전") {}
          Button("다음") {}
            .buttonStyle(.borderedProminent)
        }
      }
      .padding(.top, 6)

    }
    .padding(20)
    .frame(width: 450)
    .navigationTitle("찾기")
  }
}

#Preview {
  FindReplaceWindowView()
}
