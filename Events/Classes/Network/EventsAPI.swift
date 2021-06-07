//
//  EventsAPI.swift
//  Events
//
//  Created by Igor Hmara on 6/2/21.
//  Copyright © 2021 Soft. All rights reserved.
//

import Foundation

protocol EventsAPIProtocol {
    func getEvents(completion: @escaping (Result<[Event], Error>) -> Void)
}

protocol EventsParsingProtocol {
    func parseEventsRawData(_ data: Data, completion: @escaping (Result<[Event], Error>) -> Void)
}

extension EventsParsingProtocol {
    func parseEventsRawData(_ data: Data, completion: @escaping (Result<[Event], Error>) -> Void) {
        do {
            let eventsResponse = try JSONDecoder.default.decode(EventsAPI.Response.self, from: data)
            completion(.success(eventsResponse.events))
        }
        catch {
            completion(.failure(error))
        }
    }
}
    
enum EventsApiError: LocalizedError {
    case emptyUrl
    case noData
    
    var localizedDescription: String {
        switch self {
        case .emptyUrl: return "Empty events url".localized
        case .noData: return "Missing data in events response".localized
        }
    }
}

struct EventsAPI: EventsAPIProtocol, EventsParsingProtocol {
    struct Response: Codable {
        var events : [Event]
    }
    
    let url: URL? = URL(string: "https://api.seatgeek.com/2/events?client_id=MjE3MTU3MjV8MTYxODQxMDMzNS44NzY4MDQ4")

    func getEventsRawData(completion: @escaping (Result<Data?, Error>) -> Void) {
        guard let url = url else { return completion(.failure(EventsApiError.emptyUrl)) }
        
        URLSession.shared.dataTask(with: url, completionHandler: { data, response, error -> Void in
            if let error = error {
                return completion(.failure(error))
            }
            completion(.success(data))
        }).resume()
    }
    
    func getEvents(completion: @escaping (Result<[Event], Error>) -> Void) {
        getEventsRawData { (result) in
            switch result {
            case .success(let data):
                guard let data = data else { return completion(.failure(EventsApiError.noData)) }
                parseEventsRawData(data, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
