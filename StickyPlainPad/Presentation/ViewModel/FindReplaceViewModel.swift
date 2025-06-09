//
//  FindReplaceViewModel.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 4/19/25.
//

import Foundation

@Observable
final class FindReplaceViewModel {
  var isSearchWindowPresented = false
  var isReplaceAreaPresented = false
  var isSearchOrReplaceCompletedOnce = false
  
  /*
   currentResultRangeIndex가 0이 되는 조건
   1. findKeyword 변경
   2. findKeywordMode 변경
   3. isIgnoreCaseOn 변경
   4. isCycleSearchOn 변경
   
   text: 검색 및 대체 모드일 때는 텍스트를 변경할 수 없어야함
   */
  
  // TODO: - text 제거 및 리팩토링 (이거 제거하면 빨간색 엄청뜸)
  var text = "" // 전체 텍스트
  
  // 찾는 단어
  var findKeyword = "" {
    didSet { currentResultRangeIndex = 0 }
  }
  
  // 대체할 단어
  var replaceKeyword = ""
  
  // 찾기 모드 선택
  var findKeywordMode: FindKeywordMode = .contain {
    didSet { currentResultRangeIndex = 0 }
  }
  
  var isIgnoreCaseOn = true {
    didSet { currentResultRangeIndex = 0 }
  }
  
  var isCycleSearchOn = true {
    didSet { currentResultRangeIndex = 0 }
  }
  
  var resultRanges: [NSRange] {
    getResultRanges()
  }
  
  private(set) var currentResultRangeIndex = 0
  
  func goToNextResult() {
    guard !resultRanges.isEmpty else {
      currentResultRangeIndex = 0
      return
    }
    
    let next = currentResultRangeIndex + 1
    if next < resultRanges.count {
      currentResultRangeIndex = next
    } else if isCycleSearchOn {
      currentResultRangeIndex = 0
    } // else: 범위 넘어가면 그대로 유지
  }
  
  func goToPreviousResult() {
    guard !resultRanges.isEmpty else {
      currentResultRangeIndex = 0
      return
    }
    
    let prev = currentResultRangeIndex - 1
    if prev >= 0 {
      currentResultRangeIndex = prev
    } else if isCycleSearchOn {
      currentResultRangeIndex = resultRanges.count - 1
    }
  }
  
  func replaceCurrent() {
    guard isReplaceAreaPresented else {
      return
    }
    guard !resultRanges.isEmpty else {
      return
    }
    guard currentResultRangeIndex >= 0,
          currentResultRangeIndex < resultRanges.count else {
      return
    }

    let nsText = NSMutableString(string: text)
    let range = resultRanges[currentResultRangeIndex]
    nsText.replaceCharacters(in: range, with: replaceKeyword)
    text = nsText as String
  }

  func replaceAll() {
    guard isReplaceAreaPresented else {
      return
    }
    guard !resultRanges.isEmpty else {
      return
    }

    let nsText = NSMutableString(string: text)

    for range in resultRanges.reversed() {
      nsText.replaceCharacters(in: range, with: replaceKeyword)
    }

    text = nsText as String
  }
}

extension FindReplaceViewModel {
  private func getResultRanges() -> [NSRange] {
    guard !findKeyword.isEmpty else {
      return []
    }

    let nsText = text as NSString
    let fullRange = NSRange(location: 0, length: nsText.length)
    var foundRanges: [NSRange] = []
    
    // 대소문자 무시 여부
    let options: NSString.CompareOptions = isIgnoreCaseOn ? [.caseInsensitive] : []

    switch findKeywordMode {
    case .contain:
      var searchRange = fullRange
      
      while true {
        let range = nsText.range(of: findKeyword, options: options, range: searchRange)
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
        let range = nsText.range(of: findKeyword, options: options, range: searchRange)
        
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
        let trimmedCase = isIgnoreCaseOn ? trimmed.lowercased() : trimmed
        let findKeywordCase = isIgnoreCaseOn ? findKeyword.lowercased() : findKeyword
        
        if trimmedCase == findKeywordCase {
          let range = nsText.range(
            of: trimmed,
            options: options,
            range: NSRange(
              location: location,
              length: nsText.length - location
            )
          )
          
          if range.location != NSNotFound {
            foundRanges.append(range)
            location = range.location + range.length
          }
        } else {
          let range = nsText.range(
            of: word,
            options: options,
            range: NSRange(
              location: location,
              length: nsText.length - location
            )
          )
          
          if range.location != NSNotFound {
            location = range.location + range.length
          }
        }
      }
    }
    
    return foundRanges
  }
}
