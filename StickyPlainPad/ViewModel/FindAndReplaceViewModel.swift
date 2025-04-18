//
//  FindAndReplaceViewModel.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 4/19/25.
//

import Foundation

enum FindKeywordMode {
  case contain // ~을 포함
  case startWith // ~로 시작
  case shouldEntireMatch // 단어가 일치하는 경우에만
}

@Observable
final class FindAndReplaceViewModel {
  var isSearchWindowPresented = false
  
  var text = "" // 전체 텍스트
  var findKeyword = "" // 찾는 단어
  var findKeywordMode: FindKeywordMode = .contain // 찾기 모드 선택
  
  var resultRanges: [NSRange] {
    guard !findKeyword.isEmpty else {
      return []
    }

    let nsText = text as NSString
    let fullRange = NSRange(location: 0, length: nsText.length)
    var foundRanges: [NSRange] = []

    switch findKeywordMode {
    case .contain:
      var searchRange = fullRange
      
      while true {
        let range = nsText.range(of: findKeyword, options: [], range: searchRange)
        if range.location != NSNotFound {
          foundRanges.append(range)
          // 단어에서 겹치는 부분이 있다면 패스: 예) 검색어를 검색 "검색어의검색어" -> 1로 카운트
          // let nextLocation = range.location + range.length
          
          // 겹치는 부분이 있어도 검사: 예) 검색어를 검색 "검색어의검색어" -> 2로 카운트
          let nextLocation = range.location + 1
          
          if nextLocation >= nsText.length {
            break
          }
          
          searchRange = NSRange(location: nextLocation, length: nsText.length - nextLocation)
        } else {
          break
        }
      }

    case .startWith:
      var searchRange = fullRange
      while true {
        let range = nsText.range(of: findKeyword, options: [], range: searchRange)
        
        if range.location != NSNotFound {
          if range.location == 0 {
            foundRanges.append(range)
          } else {
            let prevChar = nsText.character(at: range.location - 1)
            if let scalar = UnicodeScalar(prevChar), Character(scalar).isWhitespace {
              foundRanges.append(range)
            }
          }
          
          let nextLocation = range.location + range.length
          if nextLocation >= nsText.length {
            break
          }
          searchRange = NSRange(location: nextLocation, length: nsText.length - nextLocation)
        } else {
          break
        }
      }

    case .shouldEntireMatch:
      let wordSeparators = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
      let words = text.components(separatedBy: wordSeparators)
      var location = 0

      for word in words {
        let trimmed = word.trimmingCharacters(in: .whitespaces)
        if trimmed == findKeyword {
          let range = nsText.range(of: trimmed, options: [], range: NSRange(location: location, length: nsText.length - location))
          if range.location != NSNotFound {
            foundRanges.append(range)
            location = range.location + range.length
          }
        } else {
          let range = nsText.range(of: word, options: [], range: NSRange(location: location, length: nsText.length - location))
          if range.location != NSNotFound {
            location = range.location + range.length
          }
        }
      }
    }

    return foundRanges
  }
  
  var currentResultRangeIndex: Int?
}
