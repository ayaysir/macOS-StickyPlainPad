//
//  ThemeViewModelTests.swift
//  StickyPlainPadTests
//
//  Created by 윤범태 on 4/10/25.
//

import XCTest
@testable import StickyPlainPad

final class ThemeViewModelTests: XCTestCase {
  var viewModel: ThemeViewModel!
  var mockRepository: MockThemeRepository!

  override func setUp() {
    super.setUp()
    mockRepository = MockThemeRepository()
    viewModel = ThemeViewModel(repository: mockRepository)
  }

  override func tearDown() {
    viewModel = nil
    mockRepository = nil
    super.tearDown()
  }

  func testAddTheme() {
    viewModel.addTheme(name: "Dark", backgroundColorHex: "#000000", textColorHex: "#FFFFFF")

    XCTAssertEqual(viewModel.themes.count, 1)
    XCTAssertEqual(viewModel.themes.first?.name, "Dark")
  }

  func testUpdateTheme() {
    viewModel.addTheme(name: "Light", backgroundColorHex: "#FFFFFF", textColorHex: "#000000")
    var theme = viewModel.themes.first!
    theme.name = "Updated Light"

    viewModel.updateTheme(theme)

    XCTAssertEqual(viewModel.themes.first?.name, "Updated Light")
    XCTAssertNotNil(viewModel.themes.first?.modifiedAt)
  }

  func testDeleteTheme() {
    viewModel.addTheme(name: "ToDelete", backgroundColorHex: "#FF0000", textColorHex: "#000000")
    let theme = viewModel.themes.first!

    viewModel.deleteTheme(theme)

    XCTAssertTrue(viewModel.themes.isEmpty)
  }

  func testFetchAllThemes() {
    mockRepository.themes = [
      Theme(id: UUID(), createdAt: .now, modifiedAt: nil, name: "Red", backgroundColorHex: "#FF0000", textColorHex: "#000000"),
      Theme(id: UUID(), createdAt: .now, modifiedAt: nil, name: "Green", backgroundColorHex: "#00FF00", textColorHex: "#000000")
    ]

    viewModel.fetchAllThemes()

    XCTAssertEqual(viewModel.themes.count, 2)
    XCTAssertEqual(viewModel.themes.map(\.name), ["Red", "Green"])
  }
}

class MockThemeRepository: ThemeRepository {
  var themes: [Theme] = []

  func fetchAll() -> [Theme] {
    return themes
  }

  func add(_ theme: Theme) {
    themes.append(theme)
  }

  func update(_ theme: Theme) {
    if let index = themes.firstIndex(where: { $0.id == theme.id }) {
      themes[index] = theme
    }
  }

  func delete(_ theme: Theme) {
    themes.removeAll { $0.id == theme.id }
  }
}
