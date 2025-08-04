import Foundation
import SharedLib
import XCTest
import XCUIAutomation

@testable import RickAndMortyApp
@testable import RickAndMortyEpisodesLib

@MainActor
final class RickAndMortyAppUITests: XCTestCase {
  let app = XCUIApplication()

  func testToSettingsAndBack() async {
    app.launch()

    app.waitForScreen(title: "Episode List")
    app.buttons[RootFeature.A11yIDs.enterSettingsButton].waitToAppear().tap()
    app.waitForScreen(title: "Settings")
    app.buttons[RootFeature.A11yIDs.exitSettingsButton].waitToAppear().tap()
    app.waitForScreen(title: "Episode List")
  }

  func testToCharacterDetails() async {
    app.launch()

    app.waitForScreen(title: "Episode List")
    app.staticTexts[EpisodeListFeature.A11yIDs.cachedSince].waitToAppear()
    app.buttons[EpisodeListFeature.A11yIDs.episodeRow(id: "3")]
      .waitToAppear()
      .tap()
    app.waitForScreen(title: "Anatomy Park")
  }
}

extension XCUIElementQuery {
  subscript<A: A11yIDProvider>(_ provider: A) -> XCUIElement {
    self[provider.a11yID]
  }
}

extension XCUIElement {
  @discardableResult
  func waitToAppear(
    timeout: TimeInterval = 3,
    file: StaticString = #filePath,
    line: UInt = #line
  ) -> XCUIElement {
    XCTAssertTrue(
      waitForExistence(timeout: timeout),
      "Expected element `\(self)` did not appear in time",
      file: file,
      line: line,
    )
    return self
  }
}

extension XCUIElementTypeQueryProvider {
  var navTitle: XCUIElement {
    navigationBars.element
  }

  func waitForScreen(
    title: String,
    timeout: TimeInterval = 3,
    file: StaticString = #filePath,
    line: UInt = #line
  ) {
    navigationBars[title].waitToAppear(timeout: timeout)
  }
}
