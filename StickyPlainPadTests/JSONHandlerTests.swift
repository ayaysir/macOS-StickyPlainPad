//
//  JSONHandlerTests.swift
//  StickyPlainPadTests
//
//  Created by 윤범태 on 4/20/25.
//

import XCTest
@testable import StickyPlainPad

final class JSONHandlerTests: XCTestCase {
  
  func testDecodeThemesFromJSON() {
    let jsonString = """
    [
      {
        "backgroundColorHex" : "#45F02C",
        "createdAt" : "2025-04-14T14:56:14Z",
        "fontName" : "SF Pro",
        "fontSize" : 20,
        "id" : "C77F884C-469E-456A-9805-B7CE81CAD0E1",
        "modifiedAt" : "2025-04-20T05:34:10Z",
        "name" : "Green",
        "textColorHex" : "#000000"
      },
      {
        "backgroundColorHex" : "#FF5D5D",
        "createdAt" : "2025-04-14T14:59:21Z",
        "fontName" : "Courier New",
        "fontSize" : 64,
        "id" : "B19B0E37-265F-469A-B4CE-6962748ACE0C",
        "modifiedAt" : "2025-04-20T05:34:08Z",
        "name" : "Irregular Console",
        "textColorHex" : "#E9E9E9"
      }
    ]
    """
    
    let themes = [Theme].decodeFromJSON(jsonString, as: [Theme].self)
    
    XCTAssertNotNil(themes, "디코딩 결과가 nil이면 안 됩니다")
    XCTAssertEqual(themes?.count, 2, "Theme는 총 2개여야 합니다")
    XCTAssertEqual(themes?.first?.name, "Green", "첫 번째 테마 이름이 'Green'이어야 합니다")
    
    let expectedDate = ISO8601DateFormatter().date(from: "2025-04-14T14:56:14Z")
    XCTAssertEqual(themes?.first?.createdAt, expectedDate, "첫 번째 테마의 생성일이 올바르지 않습니다")
  }
}
