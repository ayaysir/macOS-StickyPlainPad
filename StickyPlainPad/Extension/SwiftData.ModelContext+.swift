//
//  SwiftData.ModelContext+.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 3/30/25.
//

import SwiftData

extension ModelContext {
  @MainActor
  static var mainContext: ModelContext {
    ModelContainer.mainModelContainer.mainContext
  }
  
  @MainActor
  static var forPreviewContext: ModelContext {
    ModelContainer.previewModelContainer.mainContext
  }
}
