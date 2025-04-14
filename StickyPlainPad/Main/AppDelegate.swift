//
//  AppDelegate.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 4/10/25.
//

import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
  
  func applicationDidFinishLaunching(_ notification: Notification) {
    
  }
  
  func applicationWillTerminate(_ notification: Notification) {
    // Dock 아이콘 -> 종료의 경우 익스포트된 독립 앱으로 작동 여부 확인
    
    // 모든 윈도우 닫기
    for window in NSApp.windows {
      window.isReleasedWhenClosed = true
      window.close()
    }
  }
  
  func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
    // 모든 floating 윈도우 닫기
    for window in NSApp.windows {
      if window.level == .floating {
        window.close()
      }
    }
    
    // 0.1초후 종료: 약간의 지연을 줄 수도 있음 (안정성 향상 목적)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      NSApp.reply(toApplicationShouldTerminate: true)
    }
    
    return .terminateLater
  }
}

extension AppDelegate {
  
  func hideTitleBar() {
    NSApplication.shared.windows.forEach { window in
      window.titlebarAppearsTransparent = true
      window.titleVisibility = .hidden
      
      window.isMovableByWindowBackground = true
      
      // window.standardWindowButton(.closeButton)?.isHidden = true
      // window.standardWindowButton(.miniaturizeButton)?.isHidden = true
      // window.standardWindowButton(.zoomButton)?.isHidden = true
      
      // window.styleMask.remove(.titled) // 타이틀바 제거
      // window.styleMask.insert(.fullSizeContentView) // 전체 콘텐츠 뷰 활성화
      
      /*
       print(window.styleMask.contains(.borderless)) // t
       print(window.styleMask.contains(.closable)) // t
       print(window.styleMask.contains(.docModalWindow)) // f
       print(window.styleMask.contains(.fullScreen)) // f
       print(window.styleMask.contains(.fullSizeContentView)) // t
       print(window.styleMask.contains(.hudWindow)) // f
       print(window.styleMask.contains(.miniaturizable)) // t
       print(window.styleMask.contains(.nonactivatingPanel)) // f
       print(window.styleMask.contains(.resizable)) // t
       print(window.styleMask.contains(.titled)) // t
       print(window.styleMask.contains(.unifiedTitleAndToolbar)) // f
       print(window.styleMask.contains(.utilityWindow)) // f
       
       print(window.canBecomeKey, window.canBecomeMain)
       */
    }
  }
}
