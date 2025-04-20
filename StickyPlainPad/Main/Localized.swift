//
//  Localized.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 4/20/25.
//

import Foundation

extension String {
  var localized: String {
    return NSLocalizedString(self, tableName: "Localizable", value: self, comment: "")
  }
  
  func localizedFormat(_ arguments: CVarArg...) -> String {
    let localizedValue = self.localized
    return String(format: localizedValue, arguments: arguments)
  }
  
  var addEllipsis: String {
    self + "…"
  }
}
