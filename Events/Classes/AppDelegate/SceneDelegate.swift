//
//  SceneDelegate.swift
//  Events
//
//  Created by Igor Hmara on 6/2/21.
//  Copyright © 2021 Soft. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private let bgTaskService: BGTaskService? = {
        #if targetEnvironment(simulator)
          return nil
        #else
          return BGTaskService()
        #endif
    }()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
  
        guard let windowScene = (scene as? UIWindowScene) else { return }
              
        let tabBarController = UITabBarController()
        tabBarController.tabBar.accessibilityIdentifier = EventsAccessibility.TabBar.id
        tabBarController.viewControllers = buildTabBarViewControllers()
        
        UITabBar.appearance().tintColor = .japaneseLaurel

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        bgTaskService?.registerBackgroundRefreshing()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        bgTaskService?.scheduleAppRefresh()
    }
}

private extension SceneDelegate {
    func setupTestDataIfNeeded() -> EventsAPIProtocol? {
        let isTest = ProcessInfo.processInfo.environment[TestParameters.isTest] != nil
        var apiEventsAdapter: EventsAPIProtocol?
        if (ProcessInfo.processInfo.environment[TestParameters.infinityRequest] != nil) {
            apiEventsAdapter = InfinityEventsLoadAPIMock()
        }
        else if (ProcessInfo.processInfo.environment[TestParameters.emptyRequestUrl] != nil) {
            apiEventsAdapter = ErrorEventsLoadAPIMock()
        }
        else if (isTest) {
            apiEventsAdapter = EventsAPIMock()
        }
        
        if isTest {
            UserDefaults.clearAll()
        }
        
        return apiEventsAdapter
    }
    
    func buildTabBarViewControllers() -> [UIViewController] {
        let eventsApi: EventsAPIProtocol = setupTestDataIfNeeded() ?? EventsAPI()
        let allEventsAPIAdapter = EventsServiceAdapter(
            apiEvents: EventsAPIAdapter(api: eventsApi),
            cacheEvents: CacheAdapter(),
            favoriteEvents: FavoriteEventsAdapter(),
            lastApiEventsDate: UserDefaults.loadEventsDate,
            refreshTime: 60)
        let allEventsViewModel = EventsViewModel(service: allEventsAPIAdapter)
        let allEventsViewController = ListViewController(viewModel: allEventsViewModel)
        let allEventsTabBarItem = UITabBarItem(title: "Events".localized, image: #imageLiteral(resourceName: "events-tabbar-icon"), tag: 0)
        allEventsTabBarItem.accessibilityIdentifier = EventsAccessibility.TabBar.eventsItem
        allEventsViewController.tabBarItem = allEventsTabBarItem
        
        let favoriteEventsAdapter = FavoriteEventsAdapter()
        let favoriteEventsViewModel = FavoriteEventsViewModel(service: favoriteEventsAdapter)
        let favoriteEventsViewController = ListViewController(viewModel: favoriteEventsViewModel)
        let favoriteEventsTabBarItem = UITabBarItem(title: "Favorite".localized, image:  #imageLiteral(resourceName: "favorites-tabbar-icon"), tag: 1)
        favoriteEventsTabBarItem.accessibilityIdentifier = EventsAccessibility.TabBar.favoritesItem
        favoriteEventsViewController.tabBarItem = favoriteEventsTabBarItem
        
        favoriteEventsViewModel.add(services: UserDefaults.standard, allEventsViewModel.makeWeak())
        allEventsViewModel.add(services: UserDefaults.standard, favoriteEventsViewModel.makeWeak())
        
        return [allEventsViewController, favoriteEventsViewController]
    }
}

