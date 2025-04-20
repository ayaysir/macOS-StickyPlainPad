//
//  EditorOptionsSettingView.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 4/20/25.
//

import SwiftUI

struct EditorOptionsSettingsView: View {
  @AppStorage(.cfgEditorAutoCopyPaste) private var autoCopyPaste = true
  @AppStorage(.cfgEditorAutoQuotes) private var autoQuotes = false
  @AppStorage(.cfgEditorAutoDashes) private var autoDashes = true
  @AppStorage(.cfgEditorAutoSpelling) private var autoSpelling = false
  @AppStorage(.cfgEditorAutoTextReplacement) private var autoTextReplacement = true
  @AppStorage(.cfgEditorAutoDataDetection) private var autoDataDetection = false
  @AppStorage(.cfgEditorAutoLinkDetection) private var autoLinkDetection = false
  
  var body: some View {
    Form {
      Section(header: Text("loc_text_correction_options").bold()) {
        Divider()
        Toggle("loc_smart_copy_paste", isOn: $autoCopyPaste)
        Toggle("loc_smart_quotes", isOn: $autoQuotes)
        Toggle("loc_smart_dashes", isOn: $autoDashes)
        Toggle("loc_text_replacement", isOn: $autoTextReplacement)
        Toggle("loc_data_detection", isOn: $autoDataDetection)
        Toggle("loc_link_detection", isOn: $autoLinkDetection)
        Divider()
        Toggle("loc_spelling_correction", isOn: $autoSpelling)
        Divider()
        Text("loc_editor_substitution_option_note")
      }
    }
    .padding()
    .frame(width: 400)
  }
}

#Preview {
  EditorOptionsSettingsView()
}
