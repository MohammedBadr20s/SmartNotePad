//
//  NotePadCoordinator.swift
//  SmartNotePad
//
//  Created by GoKu on 19/05/2021.
//

import UIKit


class NotePadCoordinator: Coordinator {
    var childCoordinalors: [Coordinator] = []
    let navigationController: UINavigationController
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start(backDelegate: BackDelegate?) {
        let vc = MyNotesListVC.instantiate()
        vc.navigationDelegate = self
        self.navigationController.viewControllers.append(vc)
    }
    
    
}

extension NotePadCoordinator: NoteNavigateDelegate {
    func navigateToNotesDetailsScreen() {
        let vc = NotesDetailsVC.instantiate()
        
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    
}
