import Foundation
import XCUIAutomation
import XCTest

@testable import RickAndMortyApp

final class RickAndMortyAppUITests: XCTestCase {

  @MainActor
  func testHelloWorldButtonShowsDone() async {
    let app = XCUIApplication()
    app.launch()

    let helloWorldButton = app.buttons["hello world"]
    XCTAssertTrue(helloWorldButton.waitForExistence(timeout: 3), "Button with id 'hello world' should exist")
    helloWorldButton.tap()

    let doneElement = app.otherElements["done"]
    XCTAssertTrue(doneElement.waitForExistence(timeout: 3), "Element with id 'done' should appear within 3 seconds")
  }
}
