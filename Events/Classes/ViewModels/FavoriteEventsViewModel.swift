//
//  EventsViewModel.swift
//  Events
//
//  Created by Igor Hmara on 6/3/21.
//  Copyright © 2021 Soft. All rights reserved.
//

import Foundation

final class FavoriteEventsViewModel {
    weak var view: EventsListViewable?
    var rows: [CellViewModeling] { eventCellViewModels }
    private(set) var needShowRefreshControl = false
    var noDataText: String? { "No favorite events".localized }
    
    private(set) var favoriteEventsServices: [FavoriteEventsService] = []

    private let service: EventsService
    private var eventCellViewModels: [EventCellViewModel] = []

    init(service: EventsService) {
        self.service = service
    }
}

extension FavoriteEventsViewModel: ListViewModeling {
    func refreshDataSource(force: Bool) {
        service.loadEvents { [weak self] result in
            switch result {
            case .success(let eventCellViewModels):
                self?.eventCellViewModels = eventCellViewModels
                self?.view?.reloadUI()
            case .failure:
                self?.view?.showAlert("Something went wrong while getting favorite events".localized,
                                      title: "Error".localized,
                                      handler: nil)
            }
        }
    }
    
    func processCellAction(for indexPath: IndexPath) {
        let eventCellViewModel = eventCellViewModels[indexPath.row]
        guard let urlString = eventCellViewModel.event.url,
              let url = URL(string: urlString) else {
            view?.showAlert("There isn't web url for current event".localized,
                            title: "Error".localized,
                            handler: nil)
            return
        }
        
        view?.openBrowser(url: url)
    }
    
    func processAccessoryViewButtonAction(for indexPath: IndexPath) {
        let eventCellViewModel = eventCellViewModels[indexPath.row]
        ///send notif for all subscribers, that event was removed from favorites
        for service in favoriteEventsServices {
            service.removeFromFavorite(eventCellViewModel.event)
        }
        eventCellViewModels.remove(at: indexPath.row)
        view?.reloadTable(indexPathes: [indexPath], isRemoving: true)
    }
}

extension FavoriteEventsViewModel: FavoriteEventsService {
    func addToFavorite(_ event: Event) {
        ///check if event is already in favorites
        guard eventCellViewModels.first(where: { $0.event == event }) == nil else { return }
        
        ///sorting events by date after adding new one
        let eventCellViewModel = EventCellViewModel(event: event, isSelected: true)
        eventCellViewModels.append(eventCellViewModel)
        eventCellViewModels = eventCellViewModels.sorted(by: EventCellViewModel.sorting)
        
        view?.reloadUI()
    }
    
    func removeFromFavorite(_ event: Event) {
        guard let rowIndex = eventCellViewModels.firstIndex(where: { $0.event ==  event }) else { return }
        eventCellViewModels.remove(at: rowIndex)
        view?.reloadUI()
    }
}

extension FavoriteEventsViewModel: FavoriteEventsServicesManagable {
    func add(services: FavoriteEventsService...) {
        favoriteEventsServices.append(contentsOf: services)
    }
}
