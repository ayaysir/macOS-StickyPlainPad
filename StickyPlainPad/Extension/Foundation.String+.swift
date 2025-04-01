//
//  String+.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 4/1/25.
//

import Foundation

extension String {
  func truncated(to maxLength: Int = 50) -> String {
    // 모든 줄바꿈 문자를 스페이스 한 칸으로 치환
    let singleLine = self.replacingOccurrences(of: "\n", with: " ")
    
    // 전체 길이가 maxLength 이내라면 그대로 반환
    guard singleLine.count > maxLength else {
      return singleLine
    }
    
    // maxLength가 초과하는 경우, 42자까지 잘라서 "..." 추가
    let endIndex = singleLine.index(singleLine.startIndex, offsetBy: maxLength - 3)
    
    return String(singleLine[..<endIndex]) + "..."
  }
}
