//
//  FindAndReplaceViewModelTests.swift
//  StickyPlainPadTests
//
//  Created by 윤범태 on 4/19/25.
//

import XCTest
@testable import StickyPlainPad

final class FindAndReplaceViewModelTests: XCTestCase {
  
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testContainModeFindsAllOccurrences() {
    let viewModel = FindAndReplaceViewModel()
    viewModel.text = "텍스트 테스트 텍스트 텍스트의텍스트를 텍스트로 감쌈 텍스트!"
    viewModel.findKeyword = "텍스트"
    viewModel.findKeywordMode = .contain

    let ranges = viewModel.resultRanges
    // "[텍스트] 테스트 [텍스트] [텍스트]의[텍스트]를 [텍스트]로 감쌈 [텍스트]!"
    XCTAssertEqual(ranges.count, 6)
  }

  func testStartWithModeOnlyMatchesAtStartOfWords() {
    let viewModel = FindAndReplaceViewModel()
    viewModel.text = "텍스트 테스트 텍스트의 텍스트입니다 의텍스트 텍스트로"
    viewModel.findKeyword = "텍스트"
    viewModel.findKeywordMode = .startWith

    let ranges = viewModel.resultRanges
    // "텍스트", "텍스트의", "텍스트입니다", "텍스트로" → 4개만 앞이 공백이거나 시작이므로 매칭
    XCTAssertEqual(ranges.count, 4)
  }

  func testShouldEntireMatchOnlyMatchesExactWords() {
    let viewModel = FindAndReplaceViewModel()
    viewModel.text = "텍스트 테스트 텍스트의 텍스트입니다 텍스트"
    viewModel.findKeyword = "텍스트"
    viewModel.findKeywordMode = .shouldEntireMatch

    let ranges = viewModel.resultRanges
    // 정확히 "텍스트"인 단어만 → 2개
    XCTAssertEqual(ranges.count, 2)
  }

  func testEmptyKeywordReturnsNoResults() {
    let viewModel = FindAndReplaceViewModel()
    viewModel.text = "텍스트 텍스트"
    viewModel.findKeyword = ""
    viewModel.findKeywordMode = .contain

    let ranges = viewModel.resultRanges
    XCTAssertTrue(ranges.isEmpty)
  }
}
