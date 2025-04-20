//
//  Foundation.Bundle+.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 4/21/25.
//

import Foundation

extension Bundle {
  var appVersionString: String {
    let version = infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
    let build = infoDictionary?["CFBundleVersion"] as? String ?? "?"
    return "\(version) (\(build))"
  }
}
