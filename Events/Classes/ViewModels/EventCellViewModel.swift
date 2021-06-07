//
//  EventCellViewModel.swift
//  Events
//
//  Created by Igor Hmara on 6/3/21.
//  Copyright © 2021 Soft. All rights reserved.
//

import Foundation

final class EventCellViewModel: CellViewModeling {
    let reusableIdentifier: String
    let title: String?
    let details: String?
    
    let event: Event
    var isSelected: Bool
    
    init(event: Event,
         isSelected: Bool = false,
         reusableIdentifier: String = EventCell.defaultReuseIdentifier) {
        self.title = event.title
        self.details = event.date?.dateAndTime
        self.reusableIdentifier = reusableIdentifier
        
        self.event = event
        self.isSelected = isSelected
    }
}

extension EventCellViewModel {
    static var sorting: (EventCellViewModel, EventCellViewModel) -> Bool = { (eventViewModel1, eventViewModel2) in
        return Event.sorting(eventViewModel1.event, eventViewModel2.event)
    }
}
