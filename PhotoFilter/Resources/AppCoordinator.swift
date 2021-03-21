//
//  AppCoordinator.swift
//  PhotoFilter
//
//  Created by Bilal Durnagöl on 5.03.2021.
//

import UIKit

class AppCoordinator {
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let vc = PhotoLibraryVC()
        let nav = UINavigationController(rootViewController: vc)
        window.rootViewController = nav
        window.rootViewController?.view.backgroundColor = .systemBackground
        window.makeKeyAndVisible()
    }
}
