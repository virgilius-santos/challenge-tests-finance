//
//  SceneDelegate.swift
//  FinanceApp
//
//  Created by Willian Policiano on 22/03/22.
//

import UIKit
import Core

class HomeLoaderFetcherAdapter: HomeFetcher {
    let homeLoader: HomeLoader

    init(homeLoader: HomeLoader) {
        self.homeLoader = homeLoader
    }

    func getHome(completion: @escaping (Result<HomeViewModel, HomeErrorViewModel>) -> Void) {
        homeLoader.getHome { (result: Result<Home, Error>) in
            completion(result.map {
                HomeViewModel(home: $0)
            }.mapError { _ in
                HomeErrorViewModel()
            })
        }
    }
}

extension MainQueueDispatchDecorator: HomeLoader where Decoratee == HomeLoader {
    func getHome(completion: @escaping (HomeLoader.Result) -> Void) {
        decoratee.getHome { result in
            DispatchQueue.dispatchOnMainIfNeeded {
                completion(result)
            }
        }
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)

        let url = URL(string: "https://raw.githubusercontent.com/devpass-tech/challenge-tests-finance/willpoliciano/solutions/devsprint-willian-policiano-1/api/home.json")!

        let homeLoader = MainQueueDispatchDecorator(decoratee: Core.Factory.makeService(url: url))
        let adapter = HomeLoaderFetcherAdapter(homeLoader: homeLoader)
        let viewController = HomeTableViewController(service: adapter)
        viewController.title = "Home"

        let navigationController = UINavigationController(rootViewController: viewController)

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

