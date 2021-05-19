//
//  Coordinator.swift
//  SmartNotePad
//
//  Created by GoKu on 19/05/2021.
//

import UIKit

protocol Coordinator {
    
    var childCoordinalors: [Coordinator] { get set }
    
    init(navigationController: UINavigationController)
    
    func start(backDelegate: BackDelegate?)
    
}

protocol ChildCoordinator: Coordinator {
    init(navigationController: UINavigationController, parentNavigationController: UINavigationController)
}


protocol BackDelegate: class {
    func back()
}
