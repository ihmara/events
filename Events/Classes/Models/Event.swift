//
//  Event.swift
//  Events
//
//  Created by Igor Hmara on 6/2/21.
//  Copyright © 2021 Soft. All rights reserved.
//

import Foundation

struct Event: Codable, Hashable {
    let id: Int
    let title: String?
    let date: Date?
    let url: String?
    
    private enum CodingKeys : String, CodingKey {
        case id = "id"
        case title = "title"
        case date = "datetime_utc"
        case url = "url"
    }
}

extension Event {
    static var sorting: (Event, Event) -> Bool = { (event1, event2) in
        let date1 = event1.date ?? Date.distantPast
        let date2 = event2.date ?? Date.distantPast
        if date1 == date2 {
            let title1 = event1.title ?? ""
            let title2 = event2.title ?? ""
            return title1 < title2
        }
        return date1 < date2
    }
}
