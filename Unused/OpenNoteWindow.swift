//
//  OpenNoteWindow.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 3/29/25.
//

import AppKit
import SwiftUI

var windowOffset: CGFloat = 0 // 창이 열릴 때마다 증가할 값

func openNoteWindow(id: Note.ID) {
  @Environment(\.openWindow) var openWindow
  openWindow(value: id)

  DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // 창이 뜨는 시간을 고려한 지연
    if let window = NSApp.windows.first(where: { $0.title == "Notes" }) {
      let screenFrame = NSScreen.main?.frame ?? .zero
      let windowSize = CGSize(width: 600, height: 400) // 원하는 창 크기 설정
      
      // 창을 계단식으로 배치
      let xOffset = 40 * windowOffset
      let yOffset = 40 * windowOffset
      
      let origin = CGPoint(
        x: min(screenFrame.origin.x + xOffset, screenFrame.maxX - windowSize.width),
        y: max(screenFrame.maxY - yOffset - windowSize.height, screenFrame.origin.y)
      )
      
      window.setFrame(NSRect(origin: origin, size: windowSize), display: true, animate: true)
      windowOffset += 1 // 다음 창의 오프셋 증가
    }
  }
}
