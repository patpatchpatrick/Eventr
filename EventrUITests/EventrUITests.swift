//
//  EventrUITests.swift
//  EventrUITests
//
//  Created by Patrick Doyle on 5/13/19.
//  Copyright © 2019 Patrick Doyle. All rights reserved.
//

import XCTest

class EventrUITests: XCTestCase {

    let testUserName = "test1234@hotmail.com"
    let testPassword = "blahblah"
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    

    func testValidLoginSuccess() {
        
        
        let app = XCUIApplication()
        let loginButton = app.buttons["LOGIN"]
        loginButton.tap()
        
        let window = app.children(matching: .window).element(boundBy: 0)
        let usernameField = app.textFields["Username"]
        XCTAssertTrue(usernameField.exists)
        usernameField.tap()
        usernameField.typeText(testUserName)
        let passwordField = app.textFields["Password"]
        XCTAssertTrue(passwordField.exists)
        window.tap()
        passwordField.tap()
        passwordField.typeText(testPassword)
        loginButton.tap()
        let searchButton = app.buttons["SearchButton"]
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: searchButton, handler: nil)
        waitForExpectations(timeout: 7, handler: nil)
        
    }


}
