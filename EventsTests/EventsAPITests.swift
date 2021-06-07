//
//  EventsAPITests.swift
//  EventsTests
//
//  Created by Igor Hmara on 6/2/21.
//  Copyright © 2021 Soft. All rights reserved.
//

import XCTest
@testable import Events

final class EventsAPITests: XCTestCase {
    let eventsAPI = EventsAPI()

    func testUrl() {
        guard let url = URL(string: "https://api.seatgeek.com/2/events?client_id=MjE3MTU3MjV8MTYxODQxMDMzNS44NzY4MDQ4") else {
            XCTAssert(true, "Tests events url shouldn't be empty")
            return
        }
        
        XCTAssertTrue(eventsAPI.url == url, "Incorrect events url")
    }
    
    func testEventsRawDataExists() {
        waitForResponse { [weak self] (completionClosure) in
            self?.eventsAPI.getEventsRawData { (result) in
                switch result {
                case .success(let data):
                    XCTAssert(data != nil, "Events data exists")
                    completionClosure(nil)
                case .failure(let error):
                    completionClosure(error)
                }
            }
        }
    }
    
    func testEventsRawDataHasCorrectFormat() {
        waitForResponse { [weak self] (completionClosure) in
            self?.eventsAPI.getEventsRawData { (result) in
                switch result {
                case .success(let data):
                    guard let data = data else {
                        XCTAssert(false, "Events data don't exist")
                        return
                    }
                    self?.eventsAPI.parseEventsRawData(data, completion: { (parsingResult) in
                        switch parsingResult {
                        case .failure:
                            XCTAssert(false, "Events raw data has incorrected format")
                        default:
                            break
                        }
                        completionClosure(nil)
                    })
                case .failure(let error):
                    completionClosure(error)
                }
            }
        }
    }
    
    func testEventsLoading() {
        waitForResponse { [weak self] (completionClosure) in
            self?.eventsAPI.getEvents { (result) in
                switch result {
                case .success(let events):
                    XCTAssertFalse(events.isEmpty, "Get events response should not be empty")
                    completionClosure(nil)
                case .failure(let error):
                    completionClosure(error)
                }
            }
        }
    }
}
