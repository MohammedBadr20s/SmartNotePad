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
        vc.viewModel.loadAndListen()
        self.navigationController.viewControllers.append(vc)
    }
    
    
}

extension NotePadCoordinator: NoteNavigateDelegate {
    func navigateToLocation(delegate: LocationDelegate) {
        let vc = LocationViewController.instantiate()
        vc.delegate = delegate
        vc.backDelegate = self
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    func navigateToNotesDetailsScreen(note: NoteModel?) {
        let vc = NotesDetailsVC.instantiate()
        vc.note = note
        vc.backDelegate = self
        vc.navigationDelegate = self
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    
}
extension NotePadCoordinator: BackDelegate {
    func back() {
        navigationController.popViewController(animated: true)
        if childCoordinalors.count > 0 {
            childCoordinalors.removeLast()
        }
    } 
}
