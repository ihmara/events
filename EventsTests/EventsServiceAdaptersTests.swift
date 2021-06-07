//
//  EventsServiceAdaptersTests.swift
//  EventsTests
//
//  Created by Igor Hmara on 6/7/21.
//  Copyright © 2021 Soft. All rights reserved.
//

import XCTest
@testable import Events

class EventsServiceAdaptersTests: XCTestCase {
    
    func testCacheEventsAdapter() {
        let event = Event(id: 1, title: "Title", date: Date(), url: nil)
        let sourceEvents = [event]
        UserDefaults.events = sourceEvents
        let adapter = CacheAdapter()
        adapter.loadEvents { (result) in
            switch result {
            case.success(let cellViewModels):
                XCTAssertTrue(cellViewModels.count == sourceEvents.count)
                XCTAssertTrue(cellViewModels.first?.event == event)
            case .failure:
                XCTAssertTrue(false)
            }
        }
    }
    
    func testFavoriteEventsAdapter() {
        let event = Event(id: 1, title: "Title", date: Date(), url: nil)
        let sourceEvents = [event]
        UserDefaults.favoriteEvents = sourceEvents
        let adapter = FavoriteEventsAdapter()
        adapter.loadEvents { (result) in
            switch result {
            case.success(let cellViewModels):
                XCTAssertTrue(cellViewModels.count == sourceEvents.count)
                XCTAssertTrue(cellViewModels.first?.event == event)
            case .failure:
                XCTAssertTrue(false)
            }
        }
    }
    
    func testEventsWithFavoriteAdapter() {
        let event1 = Event(id: 1, title: "Title1", date: Date(), url: nil)
        let event2 = Event(id: 2, title: "Title2", date: Date(), url: nil)
        let cacheEvents = [event1, event2]
        UserDefaults.events = cacheEvents
        UserDefaults.favoriteEvents = [event2]
        
        let cacheAdapter = CacheAdapter()
        let favoritesAdapter = FavoriteEventsAdapter()
        let adapter = cacheAdapter.considerFavorite(favoritesAdapter)
        
        adapter.loadEvents { (result) in
            switch result {
            case.success(let cellViewModels):
                XCTAssertTrue(cellViewModels.count == cacheEvents.count)
                
                guard let unfavoriteCellViewModel = cellViewModels.first else {
                    XCTAssertTrue(false)
                    return
                }
                
                XCTAssertFalse(unfavoriteCellViewModel.isSelected)

                guard let favoriteCellViewModel = cellViewModels.last else {
                    XCTAssertTrue(false)
                    return
                }
                
                XCTAssertTrue(favoriteCellViewModel.isSelected)
                
            case .failure:
                XCTAssertTrue(false)
            }
        }
    }
    
    func testEventsAPIAdapter () {
        let eventsAPI = EventsAPIMock()
        let adapter = EventsAPIAdapter(api: eventsAPI)
        eventsAPI.getEvents { (result) in
            switch result {
            case.success(let events):
                adapter.loadEvents { (result) in
                    switch result {
                    case.success(let cellViewModels):
                        XCTAssertTrue(cellViewModels.count == events.count)
                        XCTAssertTrue(events == cellViewModels.map({ $0.event }))
                    case .failure:
                        XCTAssertTrue(false)
                    }
                }
            case .failure:
                XCTAssertTrue(false)
            }
        }
    }
    
    func testTimeRefreshEventsAdapterIfNoApiEventsDate () {
        let event1 = Event(id: 1, title: "Title1", date: Date(), url: nil)
        let event2 = Event(id: 2, title: "Title2", date: Date(), url: nil)
        let cacheEvents = [event1, event2]
        let favoriteEvents = [event2]

        UserDefaults.events = cacheEvents
        UserDefaults.favoriteEvents = favoriteEvents
        
        let eventsAPIAdapter = FavoriteEventsAdapter()

        let mainAPIAdapter = EventsServiceAdapter(
            apiEvents: eventsAPIAdapter,
            cacheEvents: CacheAdapter(),
            favoriteEvents: eventsAPIAdapter,
            lastApiEventsDate: nil,
            refreshTime: 60)
        
        //in case when lastApiEventsDate is nil in mainAPIAdapter, mainAPIAdapter will take values from apiEvents(eventsAPIAdapter in current case)
        mainAPIAdapter.loadEvents(force: false) { (result, lastGetEventsDate) in
            XCTAssertTrue(lastGetEventsDate != nil)

            switch result {
            case.success(let mainCellViewModels):
                eventsAPIAdapter.loadEvents { (result) in
                    switch result {
                    case.success(let cellViewModels):
                        XCTAssertTrue(cellViewModels.count == mainCellViewModels.count)
                        XCTAssertTrue(cellViewModels.count == favoriteEvents.count)

                        guard let favoriteCellViewModel = mainCellViewModels.last else {
                            XCTAssertTrue(false)
                            return
                        }
                        
                        XCTAssertTrue(favoriteCellViewModel.isSelected)
                           
                    case .failure:
                        XCTAssertTrue(false)
                    }
                }
            case .failure:
                XCTAssertTrue(false)
            }
        }
    }
    
    func testTimeRefreshEventsAdapterIfApiEventsDateExpired () {
        let event1 = Event(id: 1, title: "Title1", date: Date(), url: nil)
        let event2 = Event(id: 2, title: "Title2", date: Date(), url: nil)
        let cacheEvents = [event1, event2]
        let favoriteEvents = [event2]

        UserDefaults.events = cacheEvents
        UserDefaults.favoriteEvents = favoriteEvents
        
        let eventsAPIAdapter = FavoriteEventsAdapter()

        let mainAPIAdapter = EventsServiceAdapter(
            apiEvents: eventsAPIAdapter,
            cacheEvents: CacheAdapter(),
            favoriteEvents: eventsAPIAdapter,
            lastApiEventsDate: Date().add(minutes: -61),
            refreshTime: 60)
        
        //in case when currentDate-lastApiEventsDate > 60 we will take values from apiEvents(eventsAPIAdapter in current case)
        mainAPIAdapter.loadEvents(force: false) { (result, lastGetEventsDate) in
            XCTAssertTrue(lastGetEventsDate != nil)

            switch result {
            case.success(let mainCellViewModels):
                eventsAPIAdapter.loadEvents { (result) in
                    switch result {
                    case.success(let cellViewModels):
                        XCTAssertTrue(cellViewModels.count == mainCellViewModels.count)
                        XCTAssertTrue(cellViewModels.count == favoriteEvents.count)

                        guard let favoriteCellViewModel = mainCellViewModels.last else {
                            XCTAssertTrue(false)
                            return
                        }
                        
                        XCTAssertTrue(favoriteCellViewModel.isSelected)
                           
                    case .failure:
                        XCTAssertTrue(false)
                    }
                }
            case .failure:
                XCTAssertTrue(false)
            }
        }
    }
    
    func testTimeRefreshEventsAdapterIfApiEventsDateNoExpired () {
        let event1 = Event(id: 1, title: "Title1", date: Date(), url: nil)
        let event2 = Event(id: 2, title: "Title2", date: Date(), url: nil)
        let cacheEvents = [event1, event2]
        let favoriteEvents = [event2]

        UserDefaults.events = cacheEvents
        UserDefaults.favoriteEvents = favoriteEvents
        
        let eventsAPIAdapter = FavoriteEventsAdapter()
        let cacheAdapter = CacheAdapter()
        let mainAPIAdapter = EventsServiceAdapter(
            apiEvents: eventsAPIAdapter,
            cacheEvents: cacheAdapter,
            favoriteEvents: eventsAPIAdapter,
            lastApiEventsDate: Date().add(minutes: -59),
            refreshTime: 60)
        
        //in case when currentDate-lastApiEventsDate <= 60 we will take values from cacheEvents(cacheAdapter in current case)
        mainAPIAdapter.loadEvents(force: false) { (result, lastGetEventsDate) in
            XCTAssertTrue(lastGetEventsDate != nil)

            switch result {
            case.success(let mainCellViewModels):
                cacheAdapter.loadEvents { (result) in
                    switch result {
                    case.success(let cellViewModels):
                        XCTAssertTrue(cellViewModels.count == mainCellViewModels.count)
                        XCTAssertTrue(cellViewModels.count == cacheEvents.count)

                        guard let unfavoriteCellViewModel = mainCellViewModels.first else {
                            XCTAssertTrue(false)
                            return
                        }
                        
                        XCTAssertFalse(unfavoriteCellViewModel.isSelected)

                        guard let favoriteCellViewModel = mainCellViewModels.last else {
                            XCTAssertTrue(false)
                            return
                        }
                        
                        XCTAssertTrue(favoriteCellViewModel.isSelected)
                           
                    case .failure:
                        XCTAssertTrue(false)
                    }
                }
            case .failure:
                XCTAssertTrue(false)
            }
        }
    }
    
    func testTimeRefreshEventsAdapterIfForceAndNoExpiredApiEventsDate () {
        let event1 = Event(id: 1, title: "Title1", date: Date(), url: nil)
        let event2 = Event(id: 2, title: "Title2", date: Date(), url: nil)
        let cacheEvents = [event1, event2]
        let favoriteEvents = [event2]

        UserDefaults.events = cacheEvents
        UserDefaults.favoriteEvents = favoriteEvents
        
        let eventsAPIAdapter = FavoriteEventsAdapter()

        let mainAPIAdapter = EventsServiceAdapter(
            apiEvents: eventsAPIAdapter,
            cacheEvents: CacheAdapter(),
            favoriteEvents: eventsAPIAdapter,
            lastApiEventsDate: Date(),
            refreshTime: 60)
        
        //in case when currentDate-lastApiEventsDate < 60, we should take data from cacheEvents(CacheAdapter()), but in case with force == true, we will take data from apiEvents(eventsAPIAdapter)
        mainAPIAdapter.loadEvents(force: true) { (result, lastGetEventsDate) in
            XCTAssertTrue(lastGetEventsDate != nil)

            switch result {
            case.success(let mainCellViewModels):
                eventsAPIAdapter.loadEvents { (result) in
                    switch result {
                    case.success(let cellViewModels):
                        XCTAssertTrue(cellViewModels.count == mainCellViewModels.count)
                        XCTAssertTrue(cellViewModels.count == favoriteEvents.count)

                        guard let favoriteCellViewModel = mainCellViewModels.last else {
                            XCTAssertTrue(false)
                            return
                        }
                        
                        XCTAssertTrue(favoriteCellViewModel.isSelected)
                           
                    case .failure:
                        XCTAssertTrue(false)
                    }
                }
            case .failure:
                XCTAssertTrue(false)
            }
        }
    }
}
