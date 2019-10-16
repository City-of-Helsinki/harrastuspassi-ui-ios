//
//  HarrastuspassiUITests.swift
//  HarrastuspassiUITests
//
//  Created by Eetu Kallio on 12/06/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import XCTest

class HarrastuspassiUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        app = XCUIApplication();
        app.launch();

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testJsonValueRepresentation() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        
        
                
        
    }

}
