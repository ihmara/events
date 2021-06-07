//
//  EventsService.swift
//  Events
//
//  Created by Igor Hmara on 6/4/21.
//  Copyright © 2021 Soft. All rights reserved.
//

import Foundation

protocol EventsService {
    func loadEvents(completion: @escaping (Result<[EventCellViewModel], Error>) -> Void)
}

extension EventsService {
    func considerFavorite(_ favorite: EventsService) -> EventsService {
        EventsWithFavorite(events: self, favoriteEvents: favorite)
    }
}

///getting events from api
struct EventsAPIAdapter: EventsService {
    let api: EventsAPIProtocol
    
    func loadEvents(completion: @escaping (Result<[EventCellViewModel], Error>) -> Void) {
        api.getEvents { (result) in
            switch result {
            case .success(let events):
                let eventCellViewModels = events.map{ EventCellViewModel(event: $0) }
                completion(.success(eventCellViewModels))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

///composition of two services. 1. getting events 2.getting favorite 3. select favorite events and update all events accroding to favorite
struct EventsWithFavorite: EventsService {
    let events: EventsService
    let favoriteEvents: EventsService
    
    func loadEvents(completion: @escaping (Result<[EventCellViewModel], Error>) -> Void) {
        events.loadEvents { result in
            switch result {
            case .success(let eventCellViewModels):
                favoriteEvents.loadEvents { favoriteEventsResult in
                    switch favoriteEventsResult {
                    case .success(let favoriteEventCellViewModels):
                        let favoriteSetEvents = Set(favoriteEventCellViewModels.map({ $0.event }))
                        /// updated event cell view models depends on favorite events
                        let newEventCellViewModels = eventCellViewModels.map {
                            EventCellViewModel(event: $0.event, isSelected: favoriteSetEvents.contains($0.event))
                        }
                        completion(.success(newEventCellViewModels))
                        
                    case .failure:
                        completion(.success(eventCellViewModels))
                    }
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

///refresh time(in minutes) - how long we should take events from cache instead of api.
///lastApiEventsDate - date of last time of getting events from api
class EventsServiceAdapter: EventsService {
    private let apiEvents: EventsService
    private let cacheEvents: EventsService
    private var lastApiEventsDate: Date?
    private let refreshTime: Int
    
    init(apiEvents: EventsService,
         cacheEvents: EventsService,
         favoriteEvents: EventsService,
         lastApiEventsDate: Date? = nil,
         refreshTime: Int) {
        self.apiEvents = apiEvents.considerFavorite(favoriteEvents)
        self.cacheEvents = cacheEvents.considerFavorite(favoriteEvents)
        self.lastApiEventsDate = lastApiEventsDate
        self.refreshTime = refreshTime
    }

    func loadEvents(completion: @escaping (Result<[EventCellViewModel], Error>) -> Void) {
        loadEvents { (result, _) in
            completion(result)
        }
    }
    
    func loadEvents(
        force: Bool = false,
        completion: @escaping (Result<[EventCellViewModel], Error>, _ lastApiEventsDate: Date?) -> Void) {
        
        let timeFromPreviousApiCall: Int = abs(Int((lastApiEventsDate?.timeIntervalSinceNow ?? 0) / 60))
        if force || lastApiEventsDate == nil || timeFromPreviousApiCall  > refreshTime {
            apiEvents.loadEvents { [weak self] (result) in
                switch result {
                case .success(let eventCellViewModels):
                    self?.lastApiEventsDate = Date()
                    completion(.success(eventCellViewModels), self?.lastApiEventsDate)
                case .failure(let error):
                    completion(.failure(error), self?.lastApiEventsDate)
                }
            }
        }
        else {
            cacheEvents.loadEvents { [weak self] (result) in
                switch result {
                case .success(let eventCellViewModels):
                    completion(.success(eventCellViewModels), self?.lastApiEventsDate)
                case .failure(let error):
                    completion(.failure(error), self?.lastApiEventsDate)
                }
            }
        }
    }
}

///getting all events from local storage
struct CacheAdapter: EventsService {
    func loadEvents(completion: @escaping (Result<[EventCellViewModel], Error>) -> Void) {
        let events = UserDefaults.events
        let eventCellViewModels = events.map{ EventCellViewModel(event: $0) }
        completion(.success(eventCellViewModels))
    }
}

///getting favorite events only from local storage
struct FavoriteEventsAdapter: EventsService {
    func loadEvents(completion: @escaping (Result<[EventCellViewModel], Error>) -> Void) {
        let events = UserDefaults.favoriteEvents
        let eventCellViewModels = events.map{ EventCellViewModel(event: $0, isSelected: true) }
        completion(.success(eventCellViewModels))
    }
}
