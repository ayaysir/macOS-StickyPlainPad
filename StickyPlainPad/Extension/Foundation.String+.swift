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
  
  /// 키워드 기준으로 약 1/5 지점에 키워드를 위치시키며 최대 maxLength 글자 반환
  func excerpt(around keyword: String, maxLength: Int = 50) -> String? {
    guard let range = self.range(of: keyword, options: .caseInsensitive) else {
      return nil // 키워드가 없으면 nil
    }

    if self.count <= maxLength {
      return self
    }

    let keywordStartIndex = range.lowerBound
    let keywordPosition = self.distance(from: self.startIndex, to: keywordStartIndex)

    // 기준 위치: maxLength의 1/5 지점
    let desiredKeywordStartPosition = maxLength / 5

    // 키워드가 너무 앞에 있으면 앞 50자 잘라서 반환
    if keywordPosition <= desiredKeywordStartPosition {
      let end = self.index(self.startIndex, offsetBy: maxLength, limitedBy: self.endIndex) ?? self.endIndex
      return String(self[self.startIndex..<end])
    }

    // 그렇지 않으면 키워드를 desiredKeywordStartPosition에 위치시키도록 앞뒤 잘라내기
    let startOffset = keywordPosition - desiredKeywordStartPosition
    let startIndex = self.index(self.startIndex, offsetBy: startOffset)
    let endIndex = self.index(startIndex, offsetBy: maxLength, limitedBy: self.endIndex) ?? self.endIndex

    return String(self[startIndex..<endIndex])
  }
}
