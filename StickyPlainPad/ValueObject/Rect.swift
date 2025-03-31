//
//  Rect.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 3/29/25.
//

import Foundation

/// Codable을 준수하는 사각형 구조체
struct Rect: Codable, Hashable {
  var originX: CGFloat
  var originY: CGFloat
  var width: CGFloat
  var height: CGFloat
  
  init(originX: CGFloat, originY: CGFloat, width: CGFloat, height: CGFloat) {
    self.originX = originX
    self.originY = originY
    self.width = width
    self.height = height
  }
  
  init?(cgRect: CGRect?) {
    guard let cgRect else {
      return nil
    }
    
    self.originX = cgRect.origin.x
    self.originY = cgRect.origin.y
    self.width = cgRect.width
    self.height = cgRect.height
  }
  
  // CGRect로 변환할 computed property
  var toCGRect: CGRect {
    get {
      return CGRect(x: originX, y: originY, width: width, height: height)
    }
    set {
      originX = newValue.origin.x
      originY = newValue.origin.y
      width = newValue.size.width
      height = newValue.size.height
    }
  }
}
