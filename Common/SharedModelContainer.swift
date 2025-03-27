//
//  SharedModelContainer.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 3/27/25.
//

import SwiftData
import Foundation

// 공용 데이터 컨테이너를 설정하는 함수
func appGroupSharedModelContainer() throws -> ModelContainer {
  // App Group 경로 가져오기
  guard let appGroupURL = FileManager.default.containerURL(
    forSecurityApplicationGroupIdentifier: "group.com.bgsmm.UniversalTextEditors"
  ) else {
    throw NSError(
      domain: "SwiftData",
      code: 1,
      userInfo: [NSLocalizedDescriptionKey: "App Group URL을 찾을 수 없습니다."]
    )
  }
  
  // SwiftData 스토어 경로 설정
  let storeURL = appGroupURL.appendingPathComponent("shareddata.store")

  // SwiftData 모델 설정
  // 모델 등록 (사용자 모델에 맞게 수정)
  let schema = Schema(
    [Note.self]
  )
  let configuration = ModelConfiguration(
    url: storeURL,
    cloudKitDatabase: .automatic
  )

  return try ModelContainer(for: schema, configurations: configuration)
}
