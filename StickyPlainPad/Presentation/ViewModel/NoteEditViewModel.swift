//
//  NoteEditViewModel.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 6/10/25.
//

import AppKit

@Observable
final class NoteEditViewModel {
  var textView: NSTextView?
  
  // ✅ 삽입 요청 상태
  var pendingInsertText: String? = nil
}
