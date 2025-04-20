//
//  JSONHandler.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 4/20/25.
//

import Foundation

extension Encodable {
  func encodeToJSON(prettyPrinted: Bool = true, iso8601Dates: Bool = true) -> String? {
    let encoder = JSONEncoder()
    
    if prettyPrinted {
      encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }
    
    if iso8601Dates {
      encoder.dateEncodingStrategy = .iso8601
    }

    do {
      let data = try encoder.encode(self)
      return String(data: data, encoding: .utf8)
    } catch {
      Log.error("❌ JSON 인코딩 실패: \(error)")
      return nil
    }
  }
}

extension Decodable {
  static func decodeFromJSON<T: Decodable>(_ jsonString: String, as type: T.Type = T.self, iso8601Dates: Bool = true) -> T? {
    let decoder = JSONDecoder()

    if iso8601Dates {
      decoder.dateDecodingStrategy = .iso8601
    }

    guard let data = jsonString.data(using: .utf8) else {
      print("❌ JSON 문자열을 Data로 변환 실패")
      return nil
    }

    do {
      return try decoder.decode(T.self, from: data)
    } catch {
      print("❌ JSON 디코딩 실패: \(error)")
      return nil
    }
  }
}
