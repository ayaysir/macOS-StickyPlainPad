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
}

// MARK: - Constant Variables

let MIN_FONT_SIZE: CGFloat = 8
let MAX_FONT_SIZE: CGFloat = 104
