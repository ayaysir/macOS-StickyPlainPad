//
//  TextFileIO.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 4/17/25.
//

import Foundation

/// 텍스트 파일을 자동 인코딩 감지로 읽어서 문자열로 반환합니다.
/// 실패 시 nil 반환
func readTextFileAutoEncoding(at url: URL) -> String? {
  var usedEncoding: String.Encoding = .utf8

  do {
    let text = try String(contentsOf: url, usedEncoding: &usedEncoding)
    print("감지된 인코딩: \(usedEncoding)")
    return text
  } catch {
    print("파일 읽기 실패:", error.localizedDescription)
    return nil
  }
}

/// 텍스트를 url에 저장
func saveToURL(
  text: String,
  to url: URL,
  atomically useAuxiliaryFile: Bool = true,
  encoding enc: String.Encoding = .utf8
) throws {
  try text.write(to: url, atomically: useAuxiliaryFile, encoding: enc)
  print("저장 완료: \(url.path)")
}
