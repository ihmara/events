//
//  EventsViewModel.swift
//  Events
//
//  Created by Igor Hmara on 6/3/21.
//  Copyright © 2021 Soft. All rights reserved.
//

import Foundation

protocol ListViewModeling {
    var view: EventsListViewable? { get set }
    var rows: [CellViewModeling] { get }
    var needShowRefreshControl: Bool { get }
    var noDataText: String? { get }
    func refreshDataSource(force: Bool)
    func processAccessoryViewButtonAction(for indexPath: IndexPath)
    func processCellAction(for indexPath: IndexPath)
}

final class EventsViewModel {
    weak var view: EventsListViewable?
    var rows: [CellViewModeling] { eventCellViewModels }
    private(set) var needShowRefreshControl = true
    var noDataText: String? { "No events".localized }

    private(set) var favoriteEventsServices: [FavoriteEventsService] = []

    private let service: EventsServiceAdapter
    private var eventCellViewModels: [EventCellViewModel] = []
    
    init(service: EventsServiceAdapter) {
        self.service = service
    }
}

extension EventsViewModel: ListViewModeling {
    func refreshDataSource(force: Bool) {
        view?.showActivityIndicator(withText: nil)
        service.loadEvents(force: force) { [weak self] (result, eventsApiCallDate) in
            self?.view?.hideActivityIndicator()
            if force {
                self?.view?.didFinishRefreshDataSource()
            }
            
            switch result {
            case .success(let eventCellViewModels):
                let sortedEventCellViewModels = eventCellViewModels.sorted(by: EventCellViewModel.sorting)
                
                UserDefaults.events = sortedEventCellViewModels.map{ $0.event }
                UserDefaults.loadEventsDate = eventsApiCallDate
                self?.eventCellViewModels = sortedEventCellViewModels
                self?.view?.reloadUI()
            case .failure:
                self?.view?.showAlert("Something went wrong while getting events",
                                      title: "Error".localized,
                                      handler: nil)
            }
        }
    }
    
    func processCellAction(for indexPath: IndexPath) {
        let eventCellViewModel = eventCellViewModels[indexPath.row]
        guard let urlString = eventCellViewModel.event.url,
              let url = URL(string: urlString) else {
            view?.showAlert("There isn't web url for current event",
                            title: "Error".localized,
                            handler: nil)
            return
        }
        
        view?.openBrowser(url: url)
    }
    
    func processAccessoryViewButtonAction(for indexPath: IndexPath) {
        let eventCellViewModel = eventCellViewModels[indexPath.row]
        if eventCellViewModel.isSelected {
            ///notify all favorite subsribers that item was removed and all of them should process ths
            for service in favoriteEventsServices {
                service.removeFromFavorite(eventCellViewModel.event)
            }
        }
        else {
            for service in favoriteEventsServices {
                service.addToFavorite(eventCellViewModel.event)
            }
        }
        eventCellViewModel.isSelected.toggle()
        view?.reloadTable(indexPathes: [indexPath], isRemoving: false)
    }
}

extension EventsViewModel: FavoriteEventsService {
    func addToFavorite(_ event: Event) {
        guard let rowIndex = eventCellViewModels.firstIndex(where: { $0.event ==  event}) else { return }
        let indexPath = IndexPath(row: rowIndex, section: 0)
        view?.reloadTable(indexPathes: [indexPath], isRemoving: false)
    }
    
    func removeFromFavorite(_ event: Event) {
        guard let rowIndex = eventCellViewModels.firstIndex(where: { $0.event ==  event}) else { return }
        let eventCellViewModel = eventCellViewModels[rowIndex]
        eventCellViewModel.isSelected.toggle()
        let indexPath = IndexPath(row: rowIndex, section: 0)
        view?.reloadTable(indexPathes: [indexPath], isRemoving: false)
    }
}

extension EventsViewModel: FavoriteEventsServicesManagable {
    func add(services: FavoriteEventsService...) {
        favoriteEventsServices.append(contentsOf: services)
    }
}
