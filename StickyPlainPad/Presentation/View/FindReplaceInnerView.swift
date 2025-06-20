//
//  FindReplaceInnerView.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 4/18/25.
//

import SwiftUI

struct FindReplaceInnerView: View {
  @Bindable var viewModel: FindReplaceViewModel
  @FocusState private var isFindFieldFocused: Bool
  @FocusState private var isReplaceFieldFocused: Bool
  
  var body: some View {
    ZStack {
      VStack(spacing: 2) {
        HStack(spacing: 2) {
          Button(action: showMenu) {
            Text("loc_options")
            Image(systemName: "chevron.down")
          }
          ZStack(alignment: .trailing) {
            TextField("loc_find_ellipsis", text: $viewModel.findKeyword)
              .clipShape(RoundedRectangle(cornerRadius: 10))
              .focused($isFindFieldFocused)
              .onKeyPress(.tab) {
                if viewModel.isReplaceAreaPresented {
                  isReplaceFieldFocused = true
                  return .handled
                }
                
                return .ignored
              }
            Text("\(viewModel.resultRanges.count)")
              .padding(.trailing, 10)
              .foregroundStyle(.gray.opacity(0.5))
          }
          
          Button(action: viewModel.goToPreviousResult) {
            Image(systemName: "chevron.left")
          }
          
          Button(action: viewModel.goToNextResult) {
            Image(systemName: "chevron.right")
          }
          
          if !viewModel.isReplaceAreaPresented {
            buttonComplete
          }
          
          Spacer()
          
          Toggle("loc_replace", isOn: $viewModel.isReplaceAreaPresented)
        }
        
        if viewModel.isReplaceAreaPresented {
          HStack(spacing: 2) {
            TextField("loc_replace_ellipsis", text: $viewModel.replaceKeyword)
              .clipShape(RoundedRectangle(cornerRadius: 10))
              .focused($isReplaceFieldFocused)
            // 따로 지정하지 않아도 저절로 첫번째 TextField로 돌아감
            Button {
              viewModel.replaceCurrent()
              isReplaceFieldFocused = false
            } label: {
              Text("loc_replace")
            }
            Button {
              viewModel.replaceAll()
              isReplaceFieldFocused = false
            } label: {
              Text("loc_all")
            }
            Spacer()
            buttonComplete
          }
        }
      }
      .padding(5)
    }
    .background(.clear)
    .onAppear {
      if viewModel.isSearchWindowPresented {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
          isFindFieldFocused = true
        }
      }
    }
    .onDisappear {
      isFindFieldFocused = false
    }
    // ESC 버튼 누르면 실행됨
    .onExitCommand(perform: escape)
    .onChange(of: viewModel.isReplaceAreaPresented) { _, newValue in
      if !newValue, isReplaceFieldFocused {
        isReplaceFieldFocused = false
        isFindFieldFocused = true
      }
    }
  }
  
  var buttonComplete: some View {
    Button(action: escape) {
      Text("loc_done")
    }
    .buttonStyle(.borderedProminent)
  }
}

extension FindReplaceInnerView {
  var searchDetailMenus: [MenuItemInfo] {
    [
      .init(
        title: "loc_ignore_case".localized,
        category: .ignoreCase
      ),
      .init(
        title: "loc_cycle_search".localized,
        category: .cycleSearch
      ),
      .separtor,
      .init(
        title: "loc_contains".localized,
        category: .findKeywordMode(.contain)
      ),
      .init(
        title: "loc_starts_with".localized,
        category: .findKeywordMode(.startWith)
      ),
      .init(
        title: "loc_whole_word".localized,
        category: .findKeywordMode(.shouldEntireMatch)
      ),
    ]
  }

  private func escape() {
    viewModel.isSearchWindowPresented = false
    viewModel.isSearchOrReplaceCompletedOnce = true
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
        viewModel.isIgnoreCaseOn ? .on : .off
      case .cycleSearch:
        viewModel.isCycleSearchOn ? .on : .off
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
        // ignore cases
        viewModel.isIgnoreCaseOn.toggle()
      case 1:
        // cycle search
        viewModel.isCycleSearchOn.toggle()
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
  @Previewable @Bindable var viewModel = FindReplaceViewModel()
  
  FindReplaceInnerView(
    viewModel: viewModel
  )
}

