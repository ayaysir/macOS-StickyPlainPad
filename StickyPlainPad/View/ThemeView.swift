//
//  NewThemeView.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 4/10/25.
//

import SwiftUI
import Combine

/*
 main: environment, vm, stored property, body { TopView().{modifier...} }
 ext1: 분리된 view element
 ext2: init, view related function
 ext3: utility function
 */

struct ThemeView: View {
  @Environment(\.dismissWindow) private var dismissWindow
  let theme: Theme
  @Bindable var themeViewModel: ThemeViewModel
  @State private var showDuplicateAlert = false
  @FocusState private var isNameFocused: Bool
  @State private var selectedFontName: String = ""
  @State private var selectedFontMember: FontMember? = nil
  // Combine Subject
  @StateObject private var debounce = DebounceController()
  
  @State private var themeName = ""
  @State private var backgroundColor: Color = .white
  @State private var textColor: Color = .black
  
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      PreviewSection
      ThemeNameSection
      Divider()
      ColorSection
      Divider()
      FontSection
    }
    .padding()
    .onAppear(perform: setup)
    /*
     문제점
     of: theme로 하면 외부 영향에 의해 계속 호출됨, id만 변경되었을때로 제한
     */
    .onChange(of: theme.id, setup)
    .onChange(of: isNameFocused, updateThemeNameIfUnfocused)
    .onChange(of: backgroundColor) {
      debounce.backgroundColor.subject.send()
    }
    .onChange(of: textColor) {
      debounce.textColor.subject.send()
    }
    .onChange(of: themeName) {
      debounce.themeName.subject.send()
    }
    .onReceive(debounce.backgroundColor.publisher, perform: updateBackgroundColor)
    .onReceive(debounce.textColor.publisher, perform: updateTextColor)
    .onReceive(debounce.themeName.publisher, perform: updateThemeName)
    .onChange(of: selectedFontName, updateFontName)
    .onChange(of: selectedFontMember, updateFontMember)
  }
}

extension ThemeView {
  // MARK: - View elements
  
  private var PreviewSection: some View {
    VStack {
      Text("loc_preview")
        .font(.title3)
        .fontWeight(.semibold)
      ZStack(alignment: .top) {
        backgroundColor
        Text("loc_adjust_font_size_instruction")
        .multilineTextAlignment(.leading)
        .font(.custom(selectedFontMember?.postScriptName ?? selectedFontName, size: 17)
        )
        .foregroundStyle(textColor)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(5)
      }
      .frame(height: 150)
    }
  }
  
  private var ThemeNameSection: some View {
    HStack {
      Text("loc_theme_name")
        .font(.title3)
        .fontWeight(.semibold)
      TextField("loc_enter_theme_name", text: $themeName)
        .focused($isNameFocused)
        .onSubmit(updateThemeName)
        .padding()
    }
  }
  
  private var ColorSection: some View {
    VStack(alignment: .leading) {
      Text("loc_color_settings")
        .font(.title3)
        .fontWeight(.semibold)
      
      HStack {
        Text("loc_background_color_colon")
        ColorPicker("", selection: $backgroundColor)
      }
      
      HStack {
        Text("loc_text_color_colon")
        ColorPicker("", selection: $textColor)
      }
      
      Spacer()
    }
  }
  
  private var FontSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("loc_font_settings")
        .font(.title3)
        .fontWeight(.semibold)
      
      Picker("loc_font", selection: $selectedFontName) {
        ForEach(themeViewModel.availableFonts, id: \.self) { fontTitleStr in
          Text(fontTitleStr)
            .font(Font.custom(fontTitleStr, size: 14))
            .tag(fontTitleStr)
        }
      }
      
      Picker("loc_font_style", selection: $selectedFontMember) {
        ForEach(themeViewModel.availableFontStyles, id: \.self) { fontStyle in
          Text(fontStyle.displayName)
            .font(Font.custom(fontStyle.postScriptName, size: 14))
            .tag(fontStyle)
        }
      }
      
      Spacer()
    }
  }
}

extension ThemeView {
  // MARK: - Init methods
  
  private func setup() {
    setThemeNameAndColors()
    setFonts()
    moveFocusToTextField()
  }
  
  private func setThemeNameAndColors() {
    themeName = theme.name
    backgroundColor = .init(hex: theme.backgroundColorHex) ?? .white
    textColor = .init(hex: theme.textColorHex) ?? .black
  }
  
  private func setFonts() {
    selectedFontName = theme.fontName
    setFontTraitsPicker()
  }
  
  private func setFontTraitsPicker() {
    themeViewModel.availableFontMembers(ofFontFamily: selectedFontName)
    selectedFontMember = theme.fontMember ?? themeViewModel.availableFontStyles.first
  }
  
  private func moveFocusToTextField() {
    if theme.name.contains("New Theme") {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        isNameFocused = true
      }
    }
  }
  
  // MARK: - Data update methods
  
  private func updateThemeNameIfUnfocused() {
    if !isNameFocused {
      updateThemeName()
    }
  }
  
  private func updateThemeName() {
    themeViewModel.updateTheme(
      id: theme.id,
      name: themeName
    )
  }
  
  private func updateBackgroundColor() {
    themeViewModel.updateTheme(
      id: theme.id,
      backgroundColorHex: backgroundColor.toHex()
    )
  }
  
  private func updateTextColor() {
    themeViewModel.updateTheme(
      id: theme.id,
      textColorHex: textColor.toHex()
    )
  }
  
  private func updateFontName() {
    setFontTraitsPicker()
    
    themeViewModel.updateTheme(
      id: theme.id,
      fontName: selectedFontName
    )
  }
  
  private func updateFontMember() {
    guard let selectedFontMember else {
      return
    }

    themeViewModel.updateTheme(
      id: theme.id,
      fontTraits: selectedFontMember.dataDescription
    )
  }
}

private class DebounceController: ObservableObject {
  class SubjectDebounce<T: Subject> {
    var subject: T
    private var seconds = 0.1
    lazy var publisher = makeDebounce(subject: subject, seconds: 0.1)
    
    init(subject: T, seconds: Double = 0.1) {
      self.subject = subject
      self.seconds = seconds
    }
    
    private func makeDebounce(subject: T, seconds: Double) -> Publishers.Debounce<T, RunLoop> {
      subject.debounce(
        for: .seconds(seconds),
        scheduler: RunLoop.main
      )
    }
  }
  
  let backgroundColor = SubjectDebounce(subject: PassthroughSubject<Void, Never>())
  let textColor = SubjectDebounce(subject: PassthroughSubject<Void, Never>())
  let themeName = SubjectDebounce(subject: PassthroughSubject<Void, Never>(), seconds: 0.5)
}

#Preview {
  ThemeView(
    theme: .init(
      id: .init(),
      createdAt: .now,
      name: "rksk",
      backgroundColorHex: "#FFFFFF",
      textColorHex: "#000000",
      fontName: "Gullim",
      fontSize: 20,
      fontTraits: ""
    ),
    themeViewModel: .init(
      repository: ThemeRepositoryImpl(
        context: .forPreviewContext
      )
    )
  )
}
