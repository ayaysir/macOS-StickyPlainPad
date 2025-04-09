//
//  Theme.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 4/10/25.
//

import Foundation

struct Theme: Codable, Identifiable, Hashable {
  let id: UUID
  var createdAt: Date
  var modifiedAt: Date?
  var name: String
  var backgroundColorHex: String
  var textColorHex: String
  
  // TODO: - 폰트 설정 추가
  
}
