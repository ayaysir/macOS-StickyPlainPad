//
//  FindReplaceInnerView.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 4/18/25.
//

import SwiftUI

struct FindReplaceInnerView: View {
  // @Binding var isPresented: Bool
  @Binding var viewModel: FindReplaceViewModel
  @State private var showReplaceArea = false
  
  var body: some View {
    ZStack {
      VStack(spacing: 2) {
        HStack(spacing: 2) {
          Button(action: {}) {
            Text("Options")
            Image(systemName: "chevron.down")
          }
          TextField("Find...", text: $viewModel.findKeyword)
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
    Button(action: { viewModel.isSearchWindowPresented = false }) {
      Text("완료")
    }
    .buttonStyle(.borderedProminent)
  }
}

extension FindReplaceInnerView {
  func showMenu() {
    let menu = NSMenu()
    let forOBJC = ForOBJC()
    
    menu.addItem(withTitle: "영문 대/소문자 무시", action: #selector(forOBJC.menuAction(_:)), keyEquivalent: "")
    menu.addItem(withTitle: "순환 검색", action: #selector(forOBJC.menuAction(_:)), keyEquivalent: "")
    menu.addItem(NSMenuItem.separator())
    menu.addItem(withTitle: "다음을 포함", action: #selector(forOBJC.menuAction(_:)), keyEquivalent: "")
    menu.addItem(withTitle: "다음으로 시작", action: #selector(forOBJC.menuAction(_:)), keyEquivalent: "")
    menu.addItem(withTitle: "전체 단어", action: #selector(forOBJC.menuAction(_:)), keyEquivalent: "")
    menu.addItem(NSMenuItem.separator())
    menu.addItem(withTitle: "패턴 삽입", action: #selector(forOBJC.menuAction(_:)), keyEquivalent: "")
    
    // 현재 포커스된 뷰 기준 위치에 메뉴 표시
    if let window = NSApp.keyWindow,
       let contentView = window.contentView {
      let mouseLocation = NSEvent.mouseLocation
      let locationInWindow = window.convertFromScreen(NSRect(origin: mouseLocation, size: .zero)).origin
      let locationInView = contentView.convert(locationInWindow, from: nil)
      
      menu.popUp(positioning: nil, at: locationInView, in: contentView)
    }
  }
  
  class ForOBJC {
    @objc func menuAction(_ sender: NSMenuItem) {
      print("선택된 항목: \(sender.title)")
    }
  }
  
}

#Preview {
  @Previewable @State var isShow = false
  @Previewable @State var viewModel = FindReplaceViewModel()
  
  FindReplaceInnerView(
    viewModel: $viewModel
  )
}

