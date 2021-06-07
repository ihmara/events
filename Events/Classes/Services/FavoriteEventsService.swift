//
//  FavoriteEventsService.swift
//  Events
//
//  Created by Igor Hmara on 6/4/21.
//  Copyright © 2021 Soft. All rights reserved.
//

import Foundation

///for classes which want to get info about adding and removing favorite events
protocol FavoriteEventsService: AnyObject {
    func addToFavorite(_ event: Event)
    func removeFromFavorite(_ event: Event)
}

///needed to avoid retain cycles between classes, e.g. EventsViewModel and FavoriteEventsViewModel
final class WeakFavoriteEventsService: FavoriteEventsService {
    private(set) weak var service: FavoriteEventsService?
    init(service: FavoriteEventsService) {
        self.service = service
    }
    
    func addToFavorite(_ event: Event) {
        service?.addToFavorite(event)
    }
    
    func removeFromFavorite(_ event: Event) {
        service?.removeFromFavorite(event)
    }
}

///helper to convert any FavoriteEventsService into WeakFavoriteEventsService
extension FavoriteEventsService {
    func makeWeak() -> FavoriteEventsService {
        let weakService = WeakFavoriteEventsService(service: self)
        return weakService
    }
}

///for classes which are going to keep array of other FavoriteEventsService and notify them about add/remove favorites
protocol FavoriteEventsServicesManagable {
    var favoriteEventsServices: [FavoriteEventsService] { get }
    func add(services:  FavoriteEventsService...)
}
