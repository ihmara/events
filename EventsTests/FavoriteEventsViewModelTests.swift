//
//  FavoriteEventsViewModelTests.swift
//  EventsTests
//
//  Created by Igor Hmara on 6/7/21.
//  Copyright © 2021 Soft. All rights reserved.
//

import XCTest
@testable import Events

class FavoriteEventsViewModelTests: XCTestCase {
    private let eventsApi = EventsAPIMock()
    
    private lazy var allEventsViewModel: EventsViewModel = {
        let allEventsAPIAdapter = EventsServiceAdapter(
            apiEvents: EventsAPIAdapter(api: eventsApi),
            cacheEvents: CacheAdapter(),
            favoriteEvents: FavoriteEventsAdapter(),
            lastApiEventsDate: UserDefaults.loadEventsDate,
            refreshTime: 60)
        let eventsViewModel = EventsViewModel(service: allEventsAPIAdapter)
        eventsViewModel.refreshDataSource(force: true)
        return eventsViewModel
    }()
    
    private lazy var favoriteEventsViewModel: FavoriteEventsViewModel = {
        let favoriteEventsAdapter = FavoriteEventsAdapter()
        let favoriteEventsViewModel = FavoriteEventsViewModel(service: favoriteEventsAdapter)
        return favoriteEventsViewModel
    }()
    
    override func setUp() {
        favoriteEventsViewModel.add(services: UserDefaults.standard, allEventsViewModel.makeWeak())
        allEventsViewModel.add(services: UserDefaults.standard, favoriteEventsViewModel.makeWeak())
    }
    
    func testNeedShowRefreshControll() {
        XCTAssertFalse(favoriteEventsViewModel.needShowRefreshControl)
    }
    
    func testEventsText() {
        XCTAssertTrue(favoriteEventsViewModel.noDataText == "No favorite events".localized)
    }
    
    func testFavoritesViewModelLogic() {
        UserDefaults.clearAll()
        XCTAssertTrue(favoriteEventsViewModel.rows.isEmpty)
        
        favoriteEventsViewModel.refreshDataSource(force: true)
        XCTAssertTrue(favoriteEventsViewModel.rows.isEmpty)

        let firstIndexPath = IndexPath(row: 0, section: 0)
        allEventsViewModel.processAccessoryViewButtonAction(for: firstIndexPath)
        
        XCTAssertFalse(favoriteEventsViewModel.rows.isEmpty)

        guard let firstFavoriteViewModel = favoriteEventsViewModel.rows.first as? EventCellViewModel else {
            return XCTAssertTrue(false)
        }
        
        XCTAssertTrue(firstFavoriteViewModel.isSelected)
        favoriteEventsViewModel.processAccessoryViewButtonAction(for: firstIndexPath)
        
        XCTAssertTrue(favoriteEventsViewModel.rows.isEmpty)
    }
    
    func testAddToFavorite() {
        let date = Date()
        let event1 = Event(id: 1, title: "Title1", date: date, url: nil)
        let event2 = Event(id: 2, title: "Title2", date: date, url: nil)

        UserDefaults.clearAll()
        favoriteEventsViewModel.addToFavorite(event1)
        favoriteEventsViewModel.addToFavorite(event2)
        XCTAssertTrue(favoriteEventsViewModel.rows.count == 2)
    }
}
