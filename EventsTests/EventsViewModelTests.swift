//
//  EventsViewModelTests.swift
//  EventsTests
//
//  Created by Igor Hmara on 6/7/21.
//  Copyright © 2021 Soft. All rights reserved.
//

import XCTest
@testable import Events

class EventsViewModelTests: XCTestCase {
    private let eventsApi = EventsAPIMock()
    
    private lazy var allEventsViewModel: EventsViewModel = {
        let allEventsAPIAdapter = EventsServiceAdapter(
            apiEvents: EventsAPIAdapter(api: eventsApi),
            cacheEvents: CacheAdapter(),
            favoriteEvents: FavoriteEventsAdapter(),
            lastApiEventsDate: UserDefaults.loadEventsDate,
            refreshTime: 60)
        return EventsViewModel(service: allEventsAPIAdapter)
    }()
    
    func testCellViewModelsCount() {
        XCTAssertTrue(allEventsViewModel.rows.isEmpty == true)

        allEventsViewModel.refreshDataSource(force: true)

        eventsApi.getEvents { [weak self] (result) in
            switch result {
            case .success(let events):
                XCTAssertTrue(self?.allEventsViewModel.rows.count == events.count)
            case .failure:
                XCTAssertTrue(false)
            }
        }
    }
    
    func testNeedShowRefreshControll() {
        XCTAssertTrue(allEventsViewModel.needShowRefreshControl)
    }
    
    func testEventsText() {
        XCTAssertTrue(allEventsViewModel.noDataText == "No events".localized)
    }
    
    func testDataSourceTypeAndOrder() {
        allEventsViewModel.refreshDataSource(force: true)
        
        guard let cellEventsViewModels = allEventsViewModel.rows as? [EventCellViewModel] else {
            return XCTAssertTrue(false)
        }

        eventsApi.getEvents { (result) in
            switch result {
            case .success(let events):
                let sortedEvents = events.sorted(by: Event.sorting)
                guard let firstEvent = sortedEvents.first else {
                    return XCTAssertTrue(false)
                }
                
                XCTAssertTrue(cellEventsViewModels.first?.event == firstEvent)
                
                guard let lastEvent = sortedEvents.last else {
                    return XCTAssertTrue(false)
                }
                
                XCTAssertTrue(cellEventsViewModels.last?.event == lastEvent)
            case .failure:
                XCTAssertTrue(false)
            }
        }
    }
    
    func testAddToFavoriteAction() {
        UserDefaults.clearAll()
        allEventsViewModel.refreshDataSource(force: true)
        
        let firstIndexPath = IndexPath(row: 0, section: 0)
        allEventsViewModel.processAccessoryViewButtonAction(for: firstIndexPath)
        guard let firstCellViewModel = allEventsViewModel.rows.first as? EventCellViewModel else {
            return XCTAssertTrue(false)
        }
        
        XCTAssertTrue(firstCellViewModel.isSelected)

        allEventsViewModel.processAccessoryViewButtonAction(for: firstIndexPath)
        
        XCTAssertFalse(firstCellViewModel.isSelected)
    }
    
    func testSavingEventsIntoLocalStorage() {
        UserDefaults.clearAll()
        XCTAssertTrue(UserDefaults.events.isEmpty)
        allEventsViewModel.refreshDataSource(force: true)
        
        eventsApi.getEvents { (result) in
            switch result {
            case .success(let events):
                XCTAssertTrue(UserDefaults.events.count == events.count)
            case .failure:
                XCTAssertTrue(false)
            }
        }
    }
    
    func testSavingLastGetEventsDateIntoLocalStorage() {
        UserDefaults.clearAll()
        XCTAssertTrue(UserDefaults.loadEventsDate == nil)
        allEventsViewModel.refreshDataSource(force: true)
        XCTAssertTrue(UserDefaults.loadEventsDate != nil)
    }
    
    func testFavoriteEventsServicesManagableAddMethod() {
        let favoriteEventsAdapter: EventsService = FavoriteEventsAdapter()
        let favoriteEventsViewModel = FavoriteEventsViewModel(service: favoriteEventsAdapter)
        
        allEventsViewModel.add(services: UserDefaults.standard, favoriteEventsViewModel.makeWeak())
        
        XCTAssertTrue(allEventsViewModel.favoriteEventsServices.first is UserDefaults)
        
        guard let weakFavoriteEventsViewModel = allEventsViewModel.favoriteEventsServices.last as? WeakFavoriteEventsService, weakFavoriteEventsViewModel.service === favoriteEventsViewModel else {
            XCTAssertTrue(false)
            return
        }
        
        XCTAssertTrue(true)
    }
    
    func testProcessingRemoveFromFavorites() {
        UserDefaults.clearAll()
        allEventsViewModel.refreshDataSource(force: true)

        let favoriteEventsAdapter: EventsService = FavoriteEventsAdapter()
        let favoriteEventsViewModel = FavoriteEventsViewModel(service: favoriteEventsAdapter)
        
        allEventsViewModel.add(services: favoriteEventsViewModel.makeWeak())
        favoriteEventsViewModel.add(services: allEventsViewModel.makeWeak())
        
        let firstIndexPath = IndexPath(row: 0, section: 0)
        allEventsViewModel.processAccessoryViewButtonAction(for: firstIndexPath)

        favoriteEventsViewModel.processAccessoryViewButtonAction(for: firstIndexPath)
        
        guard let firstCellViewModel = allEventsViewModel.rows.first as? EventCellViewModel else {
            return XCTAssertTrue(false)
        }
        
        XCTAssertFalse(firstCellViewModel.isSelected)
    }
}
