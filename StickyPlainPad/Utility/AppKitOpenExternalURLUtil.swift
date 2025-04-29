//
//  AppKitOpenExternalURLUtil.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 4/30/25.
//

import AppKit

func openWebsite(_ urlString: String) {
  if let url = URL(string: urlString) {
    NSWorkspace.shared.open(url)
  }
}

func shareAppURL(_ urlString: String) {
  guard let url = URL(string: urlString) else  {
    return
  }
  
  let picker = NSSharingServicePicker(items: [url])
  
  // 현재 앱의 key window를 기준으로 공유창 표시
  if let window = NSApp.keyWindow,
     let contentView = window.contentView {
    picker.show(relativeTo: .zero, of: contentView, preferredEdge: .minY)
  }
}

func openEmailApp() {
  let versionString = Bundle.main.appVersionString
  let subject = "loc_email_subject".localized
  let body = "loc_email_body".localizedFormat(versionString)

  // URL encoding
  let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
  let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

  if let url = URL(string: "mailto:\(MAKER_MAIL)?subject=\(encodedSubject)&body=\(encodedBody)") {
    NSWorkspace.shared.open(url)
  }
}
