//
//  EventsUITests.swift
//  EventsUITests
//
//  Created by Igor Hmara on 6/2/21.
//  Copyright © 2021 Soft. All rights reserved.
//

import XCTest

class EventsUITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
    }
    
    func testEventsLoader() {
        let app = XCUIApplication()
        app.launchEnvironment = [TestParameters.infinityRequest: "\(true)", TestParameters.isTest: "\(true)"]
        app.launch()
                
        let inProgressActivityIndicator = app.activityIndicators[EventsAccessibility.activityIndicator]
        
        XCTAssertTrue(inProgressActivityIndicator.exists)
    }
    
    func testEventsNoDataLabel() {
        let app = XCUIApplication()
        app.launchEnvironment = [TestParameters.infinityRequest: "\(true)", TestParameters.isTest: "\(true)"]
        app.launch()
             
        let noDataLabel = app.staticTexts[EventsAccessibility.eventsListNoDataLabel]
        XCTAssertTrue(noDataLabel.exists)
    }
    
    func testFavoritesNoDataLabel() {
        let app = XCUIApplication()
        app.launchEnvironment = [TestParameters.infinityRequest: "\(true)", TestParameters.isTest: "\(true)"]
        app.launch()
        
        app.tabBars[EventsAccessibility.TabBar.id].buttons[EventsAccessibility.TabBar.favoritesItem].tap()
             
        let noDataLabel = app.staticTexts[EventsAccessibility.eventsListNoDataLabel]
        XCTAssertTrue(noDataLabel.exists)
    }
    
    func testTabBarApp() {
        let app = XCUIApplication()
        app.launch()
        let tabBar = app.tabBars[EventsAccessibility.TabBar.id]
        XCTAssertTrue(tabBar.exists)
    }
    
    func testTwoTabs() {
        let app = XCUIApplication()
        app.launch()

        let tabBar = app.tabBars[EventsAccessibility.TabBar.id]
        let eventsTabBarItem = tabBar.buttons[EventsAccessibility.TabBar.eventsItem]
        XCTAssertTrue(eventsTabBarItem.exists)

        let favoriteTabBarItem = tabBar.buttons[EventsAccessibility.TabBar.favoritesItem]
        XCTAssertTrue(favoriteTabBarItem.exists)
    }
    
    func testEventsTableBehaviour() {
        let app = XCUIApplication()
        app.launchEnvironment = [TestParameters.isTest: "\(true)"]
        app.launch()
            
        let cell = app.tables.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.exists)

        let title = cell.staticTexts[EventsAccessibility.EventCell.title]
        XCTAssertTrue(title.exists)
        XCTAssertTrue("Gordon Lightfoot" == title.label)

        let details = cell.staticTexts[EventsAccessibility.EventCell.detailsLabel]
        XCTAssertTrue(details.exists)
        XCTAssertTrue("Sun, 06 Jun 2021 10:30" == details.label)

        let eventActionButton = cell.buttons[EventsAccessibility.EventCell.actionButton]
        XCTAssertTrue(eventActionButton.exists)

        XCTAssertTrue(eventActionButton.label == "unfavorite icon")
        eventActionButton.tap()

        expectation(for: NSPredicate(format: "label == %@", "favorite icon"), evaluatedWith: eventActionButton, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(eventActionButton.label == "favorite icon")
    }
    
    func testAddAndRemoveEventToFavorites() {
        let app = XCUIApplication()
        app.launchEnvironment = [TestParameters.isTest: "\(true)"]
        app.launch()
        
        let tabBar = app.tabBars[EventsAccessibility.TabBar.id]
        let favoriteTabBarItem = tabBar.buttons[EventsAccessibility.TabBar.favoritesItem]
        favoriteTabBarItem.tap()
            
        var favoriteFirstCell = app.tables.children(matching: .cell).element(boundBy: 0)
        XCTAssertFalse(favoriteFirstCell.exists)
        
        let eventsTabBarItem = tabBar.buttons[EventsAccessibility.TabBar.eventsItem]
        eventsTabBarItem.tap()
        
        let eventsFirstCell = app.tables.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(eventsFirstCell.exists)
        
        let eventActionButton = eventsFirstCell.buttons[EventsAccessibility.EventCell.actionButton]
        eventActionButton.tap()

        expectation(for: NSPredicate(format: "label == %@", "favorite icon"), evaluatedWith: eventActionButton, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        favoriteTabBarItem.tap()
        favoriteFirstCell = app.tables.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(favoriteFirstCell.exists)
        
        let favoritesActionButton = favoriteFirstCell.buttons[EventsAccessibility.EventCell.actionButton]
        XCTAssertTrue(favoritesActionButton.exists)
        favoritesActionButton.tap()
        
        expectation(for: NSPredicate(format: "exists == 0"), evaluatedWith: favoriteFirstCell, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        let favoriteFirstCell1 = app.tables.children(matching: .cell).element(boundBy: 0)
        XCTAssertFalse(favoriteFirstCell1.exists)
    }

    func testEventsOpenBrowser() {
        let app = XCUIApplication()
        app.launchEnvironment = [TestParameters.isTest: "\(true)"]
        app.launch()
            
        let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")

        let eventCellBeforeTap = app.tables.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(eventCellBeforeTap.exists)
        eventCellBeforeTap.tap()

        let run = safari.wait(for: .runningForeground, timeout: 5)
        XCTAssertTrue(run)
    }
    
    func testFavoriteEventsOpenBrowser() {
        let app = XCUIApplication()
        app.launchEnvironment = [TestParameters.isTest: "\(true)"]
        app.launch()
        
        let eventsFirstCell = app.tables.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(eventsFirstCell.exists)
        
        let eventActionButton = eventsFirstCell.buttons[EventsAccessibility.EventCell.actionButton]
        eventActionButton.tap()

        expectation(for: NSPredicate(format: "label == %@", "favorite icon"), evaluatedWith: eventActionButton, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        let tabBar = app.tabBars[EventsAccessibility.TabBar.id]
        let favoriteTabBarItem = tabBar.buttons[EventsAccessibility.TabBar.favoritesItem]
        favoriteTabBarItem.tap()
        let favoriteFirstCell = app.tables.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(favoriteFirstCell.exists)
        
        let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")

        favoriteFirstCell.tap()
            
        let run = safari.wait(for: .runningForeground, timeout: 5)
        XCTAssertTrue(run)
    }
    
    func testErrorAlert() {
        let app = XCUIApplication()
                app.launchEnvironment = [TestParameters.emptyRequestUrl: "\(true)", TestParameters.isTest: "\(true)"]
        app.launch()
        
        let errorAlert = app.alerts["Error"]
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: errorAlert, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(errorAlert.exists)

        let okButton = errorAlert.scrollViews.otherElements.buttons["OK"]
        XCTAssertTrue(okButton.exists)
        okButton.tap()
        
        expectation(for: NSPredicate(format: "exists == 0"), evaluatedWith: errorAlert, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertFalse(errorAlert.exists)                
    }
    
    func testLaunchPerformance() {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
}
