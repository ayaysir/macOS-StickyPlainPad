//
//  FindAndReplaceInnerView.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 4/18/25.
//

import SwiftUI

struct FindAndReplaceInnerView: View {
  @Binding var isPresented: Bool
  @State private var showReplaceArea = false
  
  var body: some View {
    ZStack {
      VStack(spacing: 2) {
        HStack(spacing: 2) {
          Button(action: {}) {
            Text("Options")
            Image(systemName: "chevron.down")
          }
          TextField("Find...", text: .constant(""))
            .clipShape(RoundedRectangle(cornerRadius: 10))
          
          Button(action: {}) {
            Image(systemName: "chevron.left")
          }
          Button(action: {}) {
            Image(systemName: "chevron.right")
          }
          if showReplaceArea {
            Spacer()
          } else {
            buttonComplete
          }
          Toggle("Replace", isOn: $showReplaceArea)
        }
        
        if showReplaceArea {
          HStack(spacing: 2) {
            TextField("Replace...", text: .constant(""))
              .clipShape(RoundedRectangle(cornerRadius: 10))
            Button(action: {}) {
              Text("Replace")
            }
            Button(action: {}) {
              Text("All")
            }
            Spacer()
            buttonComplete
          }
        }
      }
      .padding(5)
    }
    .background(.clear)
  }
  
  var buttonComplete: some View {
    Button(action: { isPresented = false }) {
      Text("완료")
    }
    .buttonStyle(.borderedProminent)
  }
}

#Preview {
  @Previewable @State var isShow = false
  FindAndReplaceInnerView(isPresented: $isShow)
}

