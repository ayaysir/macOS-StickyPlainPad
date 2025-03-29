//
//  Note.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 3/29/25.
//

import Foundation
import SwiftUICore

struct Note: Codable, Identifiable, Hashable {
  let id: UUID
  var createdAt: Date
  var modifiedAt: Date?
  var content: String
  var fileURL: URL?
  var backgroundColorHex: String = "#FFFFFF"
  var windowFrame: CGRect?
}

extension Note {
  var backgroundColor: Color? {
    .init(hex: backgroundColorHex)
  }
}
