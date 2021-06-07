//
//  BGTaskService.swift
//  Events
//
//  Created by Igor Hmara on 6/6/21.
//  Copyright © 2021 Soft. All rights reserved.
//

import Foundation
import BackgroundTasks

/// BGTaskService is needed for managing refreshing events in the background
struct BGTaskService {
    private let kTaskIdentifier = "com.soft.Events.refresh"
    private let eventsAPI = EventsAPI()
    
    func registerBackgroundRefreshing() {
        // MARK: Registering Launch Handlers for Tasks
        BGTaskScheduler.shared.register(forTaskWithIdentifier: kTaskIdentifier, using: nil) { task in
            guard let bgAppRefreshTask = task as? BGAppRefreshTask else { return }
            self.handleAppRefresh(task: bgAppRefreshTask)
        }
    }
    
    private func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh()

        eventsAPI.getEvents { (result) in
            switch result {
            case .success(let events):
                UserDefaults.events = events
                UserDefaults.loadEventsDate = Date()
                task.setTaskCompleted(success: true)
            case .failure:
                task.setTaskCompleted(success: false)
            }
        }
    }
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: kTaskIdentifier)
        // Fetch no earlier than 60 minutes from now
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60)
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
}
