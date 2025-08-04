import Foundation
import SharedLib
import XCTest
import XCUIAutomation

@testable import RickAndMortyApp
@testable import RickAndMortyEpisodesLib

final class RickAndMortyAppUITests: XCTestCase {
  @MainActor
  func testHelloWorldButtonShowsDone() async {
    let app = XCUIApplication()
    app.launch()

    let settingsButton = app.buttons[RootFeature.A11yIDs.enterSettingsButton]
    XCTAssertTrue(
      settingsButton.waitForExistence(timeout: 3),
      "Button with id 'hello world' should exist"
    )
    settingsButton.tap()

    try? await Task.sleep(for: .seconds(10))
  }
}

extension XCUIElementQuery {
  subscript<A: A11yIDProvider>(_ provider: A) -> XCUIElement {
    self[provider.a11yID]
  }
}
