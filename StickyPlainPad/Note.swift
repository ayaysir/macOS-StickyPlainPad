//
//  Item 2.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 3/25/25.
//

import Foundation
import SwiftData
import SwiftUICore

@Model
final class Note {
  var createdTimestamp: Date
  var modifiedTimestamp: Date?
  var content: String
  var fileURL: URL?
  var backgroundColorHex: String
  var windowFrame: CGRect?
  
  init(
    createdTimestamp: Date,
    modifiedTimestamp: Date? = nil,
    content: String,
    fileURL: URL? = nil,
    backgroundColorHex: String,
    windowFrame: CGRect? = nil
  ) {
    self.createdTimestamp = createdTimestamp
    self.modifiedTimestamp = modifiedTimestamp
    self.content = content
    self.fileURL = fileURL
    self.backgroundColorHex = backgroundColorHex
    self.windowFrame = windowFrame
  }
}
