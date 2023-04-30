//
//  roomfinderUITests.swift
//  roomfinderUITests
//
//  Created by Cathryn Lyons on 4/30/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import XCTest

final class roomfinderUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        
        //The following is meant to test the inital view and make sure only expected components exist
        //search Bar on Main Screen should exist
        let destinationField = app.searchFields["Where do you want to go?"]
        XCTAssertTrue(destinationField.exists)
        
        //scan QR on main should exist
        let mainQR = app.searchFields["Where do you want to go?"].buttons["scan qr code"]
        XCTAssertTrue(mainQR.exists)
        
        //Show Path Button should NOT exist
        let pathButton = app/*@START_MENU_TOKEN@*/.buttons["Show Path"].staticTexts["Show Path"]/*[[".buttons[\"Show Path\"].staticTexts[\"Show Path\"]",".staticTexts[\"Show Path\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/
        XCTAssertFalse(pathButton.exists)
        
        //Level picker should exist
        let levelPicker = app/*@START_MENU_TOKEN@*/.maps.containing(.other, identifier:"VKPointFeature").element/*[[".maps.containing(.other, identifier:\"Elevator 7, Elevator\").element",".maps.containing(.other, identifier:\"2258, Office\").element",".maps.containing(.other, identifier:\"2253, Lab\").element",".maps.containing(.other, identifier:\"2256, Lab\").element",".maps.containing(.other, identifier:\"2248, Lab\").element",".maps.containing(.other, identifier:\"2249, Lab\").element",".maps.containing(.other, identifier:\"2040, Classroom\").element",".maps.containing(.other, identifier:\"University of Iowa - Office of Sustainability and the Environment\").element",".maps.containing(.other, identifier:\"2244, Lab\").element",".maps.containing(.other, identifier:\"2243, Lab\").element",".maps.containing(.other, identifier:\"2045, Academic Center\").element",".maps.containing(.other, identifier:\"2235 - Men's Restroom, Restroom\").element",".maps.containing(.other, identifier:\"2301, Lab\").element",".maps.containing(.other, identifier:\"2313, Office\").element",".maps.containing(.other, identifier:\"2325, Lab\").element",".maps.containing(.other, identifier:\"2229, Classroom\").element",".maps.containing(.other, identifier:\"2429, Lab\").element",".maps.containing(.other, identifier:\"2430, Lab\").element",".maps.containing(.other, identifier:\"2320, Academic Center\").element",".maps.containing(.other, identifier:\"2312, Office\").element",".maps.containing(.other, identifier:\"2328, Utility\").element",".maps.containing(.other, identifier:\"2028, Academic Center\").element",".maps.containing(.other, identifier:\"2427, Lab\").element",".maps.containing(.other, identifier:\"2217, Classroom\").element",".maps.containing(.other, identifier:\"2426, Lab\").element",".maps.containing(.other, identifier:\"2425, Utility\").element",".maps.containing(.other, identifier:\"2226, Office\").element",".maps.containing(.other, identifier:\"2220, Lounge\").element",".maps.containing(.other, identifier:\"2215, Utility\").element",".maps.containing(.other, identifier:\"2423, Lab\").element",".maps.containing(.other, identifier:\"2422, Lab\").element",".maps.containing(.other, identifier:\"2141, Office\").element",".maps.containing(.other, identifier:\"Elevator 3, Elevator\").element",".maps.containing(.other, identifier:\"2135, Office\").element",".maps.containing(.other, identifier:\"2401, Office\").element",".maps.containing(.other, identifier:\"2001, Library\").element",".maps.containing(.other, identifier:\"2416, Office\").element",".maps.containing(.other, identifier:\"2130, Office\").element",".maps.containing(.other, identifier:\"2136, Office\").element",".maps.containing(.other, identifier:\"2406, Office\").element",".maps.containing(.other, identifier:\"2126, Stairs\").element",".maps.containing(.other, identifier:\"VKPointFeature\").element"],[[[-1,41],[-1,40],[-1,39],[-1,38],[-1,37],[-1,36],[-1,35],[-1,34],[-1,33],[-1,32],[-1,31],[-1,30],[-1,29],[-1,28],[-1,27],[-1,26],[-1,25],[-1,24],[-1,23],[-1,22],[-1,21],[-1,20],[-1,19],[-1,18],[-1,17],[-1,16],[-1,15],[-1,14],[-1,13],[-1,12],[-1,11],[-1,10],[-1,9],[-1,8],[-1,7],[-1,6],[-1,5],[-1,4],[-1,3],[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        XCTAssertTrue(levelPicker.exists)
        
        //A lab should exist
        let lab = app.otherElements["2244, Lab"]
        XCTAssertTrue(lab.exists)

        //source search should NOT exist
        let popUpSearch = app.searchFields["Search"]
        XCTAssertFalse(popUpSearch.exists)
        
        //Scan QR button in pop up should NOT exist
        let popUpQR = app/*@START_MENU_TOKEN@*/.buttons[" Scan QR Code"].staticTexts[" Scan QR Code"]/*[[".buttons[\" Scan QR Code\"].staticTexts[\" Scan QR Code\"]",".staticTexts[\" Scan QR Code\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/
        XCTAssertFalse(popUpQR.exists)
        
        
        
        //The following is meant to test to see if searching a destination room acts as expected
        //When we search 2258
        destinationField.tap()
        destinationField.typeText("2258")
        app.buttons["search"].tap()
        //The path button should exist
        XCTAssertTrue(pathButton.exists)
        //and we should be on the 2nd floor
        XCTAssertTrue(lab.exists)
        
        //When we search 3231
        destinationField.tap()
        destinationField.typeText(XCUIKeyboardKey.delete.rawValue)
        destinationField.typeText(XCUIKeyboardKey.delete.rawValue)
        destinationField.typeText(XCUIKeyboardKey.delete.rawValue)
        destinationField.typeText(XCUIKeyboardKey.delete.rawValue)
        destinationField.typeText("3231")
        app.buttons["search"].tap()
        //The path button should exist
        XCTAssertTrue(pathButton.exists)
        //and we should be on the 3rd floor
        XCTAssertTrue(app.otherElements["3245, Lab"].exists)
        
        //When we search 1414
        destinationField.tap()
        destinationField.typeText(XCUIKeyboardKey.delete.rawValue)
        destinationField.typeText(XCUIKeyboardKey.delete.rawValue)
        destinationField.typeText(XCUIKeyboardKey.delete.rawValue)
        destinationField.typeText(XCUIKeyboardKey.delete.rawValue)
        destinationField.typeText("1414")
        app.buttons["search"].tap()
        //The path button should exist
        XCTAssertTrue(pathButton.exists)
        //and we should be on the 1st floor
        XCTAssertTrue(app.otherElements["1416, Office"].exists)
                                                                

    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
