//
//  GlobalVariables.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 4/8/25.
//

import Foundation
import os

// MARK: - Typealiases

typealias CGFloatToVoidCallback = (CGFloat) -> Void
typealias VoidCallback = () -> Void
typealias URLToVoidCallback = (URL) -> Void

// MARK: - Functions

let Log = Logger()

// MARK: - String IDs
extension String {
  static let idThemeNewWindow = "theme-new-window"
  static let idEditorSettingWindow = "editor-setting-window"
  
  static let cfgEditorAutoQuotes           = "cfg_editor_auto_quotes"
  static let cfgEditorAutoDashes           = "cfg_editor_auto_dashes"
  static let cfgEditorAutoSpelling         = "cfg_editor_auto_spelling"
  static let cfgEditorAutoTextReplacement  = "cfg_editor_auto_text_replacement"
  static let cfgEditorAutoDataDetection    = "cfg_editor_auto_data_detection"
  static let cfgEditorAutoLinkDetection    = "cfg_editor_auto_link_detection"
  static let cfgEditorAutoCopyPaste        = "cfg_editor_auto_copy_paste"
}

// MARK: - Constant Variables

let MIN_FONT_SIZE: CGFloat = 8
let MAX_FONT_SIZE: CGFloat = 104
