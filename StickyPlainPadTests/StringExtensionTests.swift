//
//  StringExtensionTests.swift
//  StickyPlainPadTests
//
//  Created by 윤범태 on 4/20/25.
//

import XCTest
@testable import StickyPlainPad

final class StringExtensionTests: XCTestCase {
  
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testStringExcerpts() throws {
    let text = """
    But I must explain to you how all this MistAkEn idea of denouncing pleasure and praising pain was born and I will give you a complete account of the system, and expound the actual teachings of the great explorer of the truth, the master-builder of human happiness. No one rejects, dislikes, or avoids pleasure itself, because it is plEaSurE, but because those who do not know how to pursue pleasure rationally encounter consequences that are extremely painful. Nor again is there anyone who loves or pursues or desires to obtain pain of itself, because it is pain, but because occasionally
    """
    let result = text.excerpt(around: "plEaSurE")
    XCTAssertEqual(result, "enouncing pleasure and praising pain was born and ")
    
    let result2 = text.excerpt(around: "mistake", maxLength: 40)
    XCTAssertEqual(result2, "ll this MistAkEn idea of denouncing plea")
  }
  
}
