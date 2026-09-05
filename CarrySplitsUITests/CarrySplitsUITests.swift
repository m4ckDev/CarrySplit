import XCTest

final class CarrySplitsUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testCreateSplitPersistsAcrossRelaunch() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.buttons["splits.new"].waitForExistence(timeout: 10))

        let splitName = "UI Persist \(String(UUID().uuidString.prefix(8)))"
        app.buttons["splits.new"].tap()

        let nameField = app.textFields["createSplit.name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5))
        nameField.tap()
        nameField.typeText(splitName)

        let createButton = app.buttons["createSplit.create"]
        XCTAssertTrue(createButton.isEnabled)
        createButton.tap()

        let predicate = NSPredicate(format: "label CONTAINS %@", splitName)
        XCTAssertTrue(app.buttons.matching(predicate).firstMatch.waitForExistence(timeout: 5))

        app.terminate()
        app.launch()

        XCTAssertTrue(app.buttons["splits.new"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons.matching(predicate).firstMatch.waitForExistence(timeout: 10))
    }
}
