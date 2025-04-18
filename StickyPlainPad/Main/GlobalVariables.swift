//
//  GlobalVariables.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 4/8/25.
//

import Foundation

// MARK: - Typealiases

typealias CGFloatToVoidCallback = (CGFloat) -> Void
typealias VoidCallback = () -> Void
typealias URLToVoidCallback = (URL) -> Void

// MARK: - Dummy Functions

let PureVoid: VoidCallback = { }

// MARK: - Variables

let MIN_FONT_SIZE: CGFloat = 8
let MAX_FONT_SIZE: CGFloat = 104
