//
//  MenuItemInfo.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 4/19/25.
//

import Foundation

enum FindKeywordMode: Int {
  case contain // ~을 포함
  case startWith // ~로 시작
  case shouldEntireMatch // 단어가 일치하는 경우에만
}

enum FindReplaceMenuItemCategory: Equatable {
  case ignoreCase, cycleSearch, findKeywordMode(FindKeywordMode), separator
  
  var isFindKeywordMode: Bool {
    if case .findKeywordMode(_) = self {
      true
    } else {
      false
    }
  }
  
  var tag: Int {
    switch self {
    case .ignoreCase:
      0
    case .cycleSearch:
      1
    case .findKeywordMode(let findKeywordMode):
      2 + findKeywordMode.rawValue
    case .separator:
      -99
    }
  }
}

struct MenuItemInfo {
  var title: String
  var selector: Selector? = nil
  var keyEquivalent: String = ""
  var category: FindReplaceMenuItemCategory
  
  static var separtor: MenuItemInfo {
    .init(
      title: "",
      selector: nil,
      keyEquivalent: "",
      category: .separator
    )
  }
}
