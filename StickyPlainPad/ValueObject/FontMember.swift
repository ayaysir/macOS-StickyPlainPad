//
//  FontMember.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 5/22/25.
//

import Foundation

struct FontMember: Codable, Identifiable, Hashable {
  var id: String {
    dataDescription
  }
  
  let displayName: String
  let postScriptName: String
  let weight: Int
  let traits: UInt
  
  var dataDescription: String {
    [
      displayName,
      postScriptName,
      "\(weight)",
      "\(traits)"
    ].joined(separator: "&&")
  }
  
  static func fromDataDescription(_ dataDescription: String) -> Self? {
    guard !dataDescription.isEmpty else {
      return nil
    }
    
    let component = dataDescription.split(separator: "&&")
    guard component.count == 4,
          let weight = Int(component[2]),
          let traits = UInt(component[3]) else {
      return nil
    }
    
    return Self(
      displayName: String(component[0]),
      postScriptName: String(component[1]),
      weight: weight,
      traits: traits
    )
  }
}
