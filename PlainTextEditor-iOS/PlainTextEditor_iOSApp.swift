//
//  PlainTextEditor_iOSApp.swift
//  PlainTextEditor-iOS
//
//  Created by 윤범태 on 3/27/25.
//

import SwiftUI
import SwiftData

@main
struct PlainTextEditor_iOSApp: App {
  var sharedModelContainer: ModelContainer = {
    do {
      return try appGroupSharedModelContainer()
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .modelContainer(sharedModelContainer)
    }
  }
}
