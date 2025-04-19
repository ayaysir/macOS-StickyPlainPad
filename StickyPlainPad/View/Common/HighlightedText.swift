//
//  HighlightedText.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 4/20/25.
//


import SwiftUI

struct HighlightedText: View {
  let fullText: String
  let keywords: [String]
  var highlightColor: Color = .red
  var highlightFont: Font = .body.italic()
  var defaultColor: Color = .gray
  var defaultFont: Font = .body.italic()
  var caseSensitive: Bool = false

  var body: some View {
    let attributed = makeHighlightedText()
    return attributed
  }

  private func makeHighlightedText() -> Text {
    var result = Text("")
    var currentIndex = fullText.startIndex

    let matches = allKeywordRanges(in: fullText, for: keywords)

    for match in matches {
      // 일반 텍스트 추가
      if currentIndex < match.range.lowerBound {
        let normalText = String(fullText[currentIndex..<match.range.lowerBound])
        result = result + Text(normalText).font(defaultFont).foregroundStyle(defaultColor)
      }

      // 강조 텍스트 추가
      let highlighted = String(fullText[match.range])
      result = result + Text(highlighted)
        .foregroundColor(highlightColor)
        .font(highlightFont)

      currentIndex = match.range.upperBound
    }

    // 마지막 나머지 텍스트 추가
    if currentIndex < fullText.endIndex {
      let remaining = String(fullText[currentIndex...])
      result = result + Text(remaining).font(defaultFont).foregroundStyle(defaultColor)
    }

    return result
  }

  private func allKeywordRanges(in text: String, for keywords: [String]) -> [(range: Range<String.Index>, keyword: String)] {
    var results: [(Range<String.Index>, String)] = []

    for keyword in keywords {
      var searchStart = text.startIndex
      while let range = text.range(of: keyword, options: .caseInsensitive, range: searchStart..<text.endIndex) {
        results.append((range, keyword))
        searchStart = range.upperBound
      }
    }

    // 겹침 방지: 앞에 나오는 순서로 정렬
    return results.sorted { (lhs, rhs) in
      let (range1, _) = lhs
      let (range2, _) = rhs
      return range1.lowerBound < range2.lowerBound
    }
  }
}
