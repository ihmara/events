//
//  LocalStorageTests.swift
//  EventsTests
//
//  Created by Igor Hmara on 6/7/21.
//  Copyright © 2021 Soft. All rights reserved.
//

import XCTest
@testable import Events

class LocalStorageTests: XCTestCase {
    private let event = Event(id: 1, title: "Title", date: Date(), url: nil)
    
    func testEvents() {
        let sourceEvents = [event]
        UserDefaults.events = sourceEvents
        let storageEvents = UserDefaults.events
        
        XCTAssertTrue(sourceEvents.count == storageEvents.count)
        
        guard let storageFirsEvent = storageEvents.first else {
            XCTAssertTrue(false)
            return
        }
        
        XCTAssertTrue(sourceEvents.first == storageFirsEvent)
    }
    
    func testFavoriteEvents() {
        let sourceEvents = [event]
        UserDefaults.favoriteEvents = sourceEvents
        let storageEvents = UserDefaults.favoriteEvents
        
        XCTAssertTrue(sourceEvents.count == storageEvents.count)
        
        guard let storageFirsEvent = storageEvents.first else {
            XCTAssertTrue(false)
            return
        }
        
        XCTAssertTrue(sourceEvents.first == storageFirsEvent)
    }
    
    func testLoadEventsDate() {
        let date = Date()
        UserDefaults.loadEventsDate = date
        XCTAssertTrue(UserDefaults.loadEventsDate == date)
    }
    
    func testAddToFavorite() {
        let favoriteEvent = Event(id: 2, title: "Title2", date: Date(), url: nil)
        
        let storageFavorites = UserDefaults.favoriteEvents
        
        UserDefaults.standard.addToFavorite(favoriteEvent)
        
        XCTAssertTrue(storageFavorites.count == UserDefaults.favoriteEvents.count - 1)
        
        let storageLastFavoriteEvent = UserDefaults.favoriteEvents.last
        
        XCTAssertTrue(storageLastFavoriteEvent == favoriteEvent)
    }
    
    func testRemoveFromFavorites() {
        let favoriteEvent = Event(id: 2, title: "Title2", date: Date(), url: nil)
        UserDefaults.standard.addToFavorite(favoriteEvent)
        UserDefaults.standard.removeFromFavorite(favoriteEvent)

        XCTAssertFalse(UserDefaults.favoriteEvents.contains(favoriteEvent))
    }
}
