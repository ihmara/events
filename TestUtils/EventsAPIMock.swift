//
//  EventsAPIMock.swift
//  Events
//
//  Created by Igor Hmara on 6/6/21.
//  Copyright © 2021 Soft. All rights reserved.
//

import Foundation

enum EventsApiMockError: LocalizedError {
    case noMockFile
    
    var localizedDescription: String {
        switch self {
        case .noMockFile: return "Mock events file wasn't found"
        }
    }
}

struct EventsAPIMock: EventsAPIProtocol, EventsParsingProtocol {
    func getEvents(completion: @escaping (Result<[Event], Error>) -> Void) {
        if let filepath = Bundle.main.path(forResource: "backendResponse", ofType: nil) {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: filepath))
                parseEventsRawData(data, completion: completion)
            } catch {
                completion(.failure(error))
            }
        } else {
            completion(.failure(EventsApiMockError.noMockFile))
        }
    }
}

struct InfinityEventsLoadAPIMock: EventsAPIProtocol, EventsParsingProtocol {
    func getEvents(completion: @escaping (Result<[Event], Error>) -> Void) {}
}

struct ErrorEventsLoadAPIMock: EventsAPIProtocol, EventsParsingProtocol {
    func getEvents(completion: @escaping (Result<[Event], Error>) -> Void) {
        completion(.failure(EventsApiError.emptyUrl))
    }
}
