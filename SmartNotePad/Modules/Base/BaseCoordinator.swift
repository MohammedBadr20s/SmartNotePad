//
//  BaseCoordinator.swift
//  SmartNotePad
//
//  Created by GoKu on 19/05/2021.
//

import UIKit
import RxSwift

class BaseCoordinator: Coordinator {
    var childCoordinalors: [Coordinator] = []
    private var navigationController: UINavigationController
    private let bag = DisposeBag()
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start(backDelegate: BackDelegate?) {}
    
    
    func navigate(window: UIWindow?) {
        self.navigationController = UINavigationController()
//        self.navigationController.isNavigationBarHidden = true
        let coordinator = NotePadCoordinator(navigationController: self.navigationController)
        self.childCoordinalors.append(coordinator)
        coordinator.start(backDelegate: nil)
        window?.rootViewController?.removeFromParent()
        window?.rootViewController = self.navigationController
        window?.makeKeyAndVisible()
    }
}
