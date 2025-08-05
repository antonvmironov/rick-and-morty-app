import Foundation
import SharedLib
import XCTest
import XCUIAutomation

@testable import RickAndMortyApp
@testable import RickAndMortyEpisodesLib

/*
 These tests are PoC. They are still connected to network.
 */

@MainActor
final class RickAndMortyAppUITests: XCTestCase {
  let app = XCUIApplication()

  func testDemo() async {
    app.launch()

    app.waitForScreen(title: "Episode List")
    app.staticTexts[EpisodeListFeature.A11yIDs.cachedSince].waitToAppear()
    app.buttons[EpisodeListFeature.A11yIDs.episodeRow(id: "3")]
      .waitToAppear()
      .tap()
    app.waitForScreen(title: "Anatomy Park")
    // wait a bit to make a nice screenshot
    try? await ContinuousClock().sleep(for: .seconds(5))
    app.buttons[EpisodeDetailsFeature.A11yIDs.characterRow(id: "38")]
      .waitToAppear()
      .tap()
    app.waitForScreen(title: "Beth Smith")
    app.buttons[CharacterDetailsFeature.A11yIDs.exportToPDF]
      .waitToAppear()
      .tap()
    app.buttons["header.closeButton"]  // an id for a system share sheet
      .waitToAppear(timeout: 10)
      .tap()
  }

  func testToSettingsAndBack() async {
    app.launch()

    app.waitForScreen(title: "Episode List")
    app.buttons[RootFeature.A11yIDs.enterSettingsButton].waitToAppear().tap()
    app.waitForScreen(title: "Settings")
    app.buttons[RootFeature.A11yIDs.exitSettingsButton].waitToAppear().tap()
    app.waitForScreen(title: "Episode List")
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
