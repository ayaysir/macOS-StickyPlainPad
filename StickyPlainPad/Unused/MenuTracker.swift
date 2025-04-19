//
//  MenuTracker.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 4/10/25.
//

import AppKit

class MenuTracker: NSObject {
  static let shared = MenuTracker()
  
  var colorItems: [NSMenuItem] = []
  
  func setupThemeMenus() {
    guard let mainMenu = NSApplication.shared.mainMenu else {
      Log.error("메인 메뉴를 찾을 수 없습니다.")
      return
    }

    // "테마" 메뉴 찾기
    guard let themeMenuItem = mainMenu.items.first(where: { $0.title == "테마" }) else {
      Log.error("테마 메뉴를 찾을 수 없습니다.")
      return
    }
    
    // "테마" 하위 메뉴 생성
    colorItems = [
      makeColorItem(title: "노란색", key: "1", color: .yellow),
      makeColorItem(title: "파란색", key: "2", color: .cyan),
      makeColorItem(title: "초록색", key: "3", color: .green),
      makeColorItem(title: "분홍색", key: "4", color: .systemPink),
      makeColorItem(title: "보라색", key: "5", color: .purple),
      makeColorItem(title: "회색", key: "6", color: .gray),
    ]
    
    colorItems.forEach {
      if !themeMenuItem.doesContain($0) {
        themeMenuItem.submenu?.addItem($0)
      }
    }
    themeMenuItem.submenu?.update()
  }
  
  func makeColorItem(title: String, key: String, color: NSColor) -> NSMenuItem {
    let item = NSMenuItem(title: title, action: #selector(changeColor(_:)), keyEquivalent: key)
    item.target = self
    item.representedObject = color
    item.image = makeColorImageWithText(color: color)
    return item
  }
  
  func makeColorImageWithText(color: NSColor, text: String = "A") -> NSImage {
    let size = NSSize(width: 20, height: 20)
    let image = NSImage(size: size)
    
    image.lockFocus()

    // 배경 사각형 그리기
    color.setFill()
    NSBezierPath(rect: NSRect(origin: .zero, size: size)).fill()

    // 텍스트 스타일 설정
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .center

    let attributes: [NSAttributedString.Key: Any] = [
      .foregroundColor: NSColor.white,
      .font: NSFont.systemFont(ofSize: 12),
      .paragraphStyle: paragraphStyle
    ]

    let attributedString = NSAttributedString(string: text, attributes: attributes)

    // 텍스트 위치 계산
    let textSize = attributedString.size()
    let textRect = NSRect(
      x: (size.width - textSize.width) / 2,
      y: (size.height - textSize.height) / 2,
      width: textSize.width,
      height: textSize.height
    )

    // 텍스트 그리기
    attributedString.draw(in: textRect)

    image.unlockFocus()
    return image
  }

  @objc func changeColor(_ sender: NSMenuItem) {
    // 체크 상태 설정
    for item in colorItems {
      item.state = .off
    }
    sender.state = .on

    if let selectedColor = sender.representedObject as? NSColor {
      Log.info("색상 선택됨: \(selectedColor)")
      // 여기서 원하는 동작 수행 (예: 앱 테마 색 변경 등)
    }
  }

}

extension MenuTracker: NSMenuDelegate {
  func menuWillOpen(_ menu: NSMenu) {
    if menu.title == "테마" {
      setupThemeMenus()
    }
  }
}
