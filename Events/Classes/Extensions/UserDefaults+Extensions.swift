//
//  UserDefaults+Extensions.swift
//  Events
//
//  Created by Igor Hmara on 6/3/21.
//  Copyright © 2021 Soft. All rights reserved.
//

import Foundation

private extension UserDefaults {
    enum Keys {
        static let events = "eventsKey"
        static let favoriteEvents = "favoriteEventsKey"
        static let loadEventsDate = "loadEventsDateKey"
    }
    
    func save(events: [Event], key: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(events) {
            set(encoded, forKey: key)
        }
    }
    
    func getEvents(for key: String) -> [Event] {
        guard let data = object(forKey: key) as? Data else {
            return []
        }
        
        let decoder = JSONDecoder()
        let events = try? decoder.decode([Event].self, from: data)
        return events ?? []
    }

    var events: [Event] {
        get {
            getEvents(for: Keys.events)
        }
        set {
            save(events: newValue, key: Keys.events)
        }
    }
    
    var favoriteEvents: [Event] {
        get {
            getEvents(for: Keys.favoriteEvents)
        }
        set {
            save(events: newValue, key: Keys.favoriteEvents)
        }
    }
    
    var loadEventsDate: Date? {
        get {
            object(forKey: Keys.loadEventsDate) as? Date
        }
        set {
            set(newValue, forKey: Keys.loadEventsDate)
        }
    }
}

extension UserDefaults {
    static var favoriteEvents: [Event] {
        get {
            standard.favoriteEvents
        }
        set {
            standard.favoriteEvents = newValue
        }
    }
    
    static var events: [Event] {
        get {
            standard.events
        }
        set {
            standard.events = newValue
        }
    }
    
    static var loadEventsDate: Date? {
        get {
            standard.loadEventsDate
        }
        set {
            standard.loadEventsDate = newValue
        }
    }
    
    static func clearAll() {
        let defaults = standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
}

extension UserDefaults: FavoriteEventsService {
    func addToFavorite(_ event: Event) {
        var favoriteEvents = self.favoriteEvents
        favoriteEvents.append(event)
        favoriteEvents = favoriteEvents.sorted(by: Event.sorting)
        self.favoriteEvents = favoriteEvents
    }
    
    func removeFromFavorite(_ event: Event) {
        var favoriteEvents = self.favoriteEvents
        guard let index = favoriteEvents.firstIndex(of: event) else { return }
        favoriteEvents.remove(at: index)
        self.favoriteEvents = favoriteEvents
    }
}
