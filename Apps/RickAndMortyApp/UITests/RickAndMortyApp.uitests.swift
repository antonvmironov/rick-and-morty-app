import Foundation
import SharedLib
import XCTest
import XCUIAutomation

@testable import RickAndMortyApp
@testable import RickAndMortyEpisodesLib

final class RickAndMortyAppUITests: XCTestCase {
  @MainActor
  func testToSettingsAndBack() async {
    let app = XCUIApplication()
    app.launch()

    app.waitForScreen(title: "Episode List")
    app.waitForButton(RootFeature.A11yIDs.enterSettingsButton).tap()
    app.waitForScreen(title: "Settings")
    app.waitForButton(RootFeature.A11yIDs.exitSettingsButton).tap()
    app.waitForScreen(title: "Episode List")
  }
}

extension XCUIElementQuery {
  subscript<A: A11yIDProvider>(_ provider: A) -> XCUIElement {
    self[provider.a11yID]
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
    XCTAssertTrue(
      navigationBars[title].waitForExistence(timeout: timeout),
      "Awaiting for '\(title)' title to appear",
      file: file,
      line: line,
    )
  }

  @discardableResult
  func waitForButton<A: A11yIDProvider>(
    _ idProvider: A,
    timeout: TimeInterval = 3,
    file: StaticString = #filePath,
    line: UInt = #line
  ) -> XCUIElement {
    let idString = idProvider.a11yID
    let button = buttons[idString]
    XCTAssertTrue(
      button.waitForExistence(timeout: timeout),
      "Awaiting for `\(idString)` title to appear",
      file: file,
      line: line,
    )
    return button
  }
}
