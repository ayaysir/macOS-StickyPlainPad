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
          Button(action: showMenu) {
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
  var searchDetailMenus: [MenuItemInfo] {
    [
      .init(
        title: "영문 대/소문자 무시",
        category: .ignoreCase
      ),
      .init(
        title: "순환 검색",
        category: .cycleSearch
      ),
      .separtor,
      .init(
        title: "다음을 포함",
        category: .findKeywordMode(.contain)
      ),
      .init(
        title: "다음으로 시작",
        category: .findKeywordMode(.startWith)
      ),
      .init(
        title: "전체 단어",
        category: .findKeywordMode(.shouldEntireMatch)
      ),
    ]
  }
  
  func showMenu() {
    let menu = NSMenu()
    let forOBJC = ForOBJC(viewModel: viewModel)
    
    searchDetailMenus.forEach { info in
      if info.category == .separator {
        menu.addItem(.separator())
        return
      }
      
      let menu = menu.addItem(
        withTitle: info.title,
        action: #selector(forOBJC.menuAction),
        keyEquivalent: info.keyEquivalent
      )
      
      menu.target = forOBJC
      menu.tag = info.category.tag
      
      // OBJC 함수에서 뷰모델을 갱신하면 메뉴 상태도 자동 갱신됨
      menu.state = switch info.category {
      case .ignoreCase:
          .off
      case .cycleSearch:
          .off
      case .findKeywordMode(let mode):
        viewModel.findKeywordMode == mode ? .on : .off
      default:
          .off
      }
    }

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
    private var viewModel: FindReplaceViewModel
    
    init(viewModel: FindReplaceViewModel) {
      self.viewModel = viewModel
    }
    
    @objc func menuAction(_ sender: NSMenuItem) {
      switch sender.tag {
      case 0:
        print("ignore case, \(sender.state == .off)")
      case 1:
        print("cycle search")
      case 2:
        // 뷰모델을 갱신하면 메뉴 상태도 자동 갱신됨
        viewModel.findKeywordMode = .contain
      case 3:
        viewModel.findKeywordMode = .startWith
      case 4:
        viewModel.findKeywordMode = .shouldEntireMatch
      default:
        break
      }
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

