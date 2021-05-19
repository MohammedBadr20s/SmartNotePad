//
//  UIViewController+Extensions.swift
//  SmartNotePad
//
//  Created by GoKu on 19/05/2021.
//

import UIKit


extension UIViewController {
    
    func navigationbarBackButton() {
        let backImage = UIImage(named: "back")?.withRenderingMode(.alwaysOriginal)
        navigationController?.navigationBar.backIndicatorImage = backImage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        let barBtn = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        barBtn.tintColor = .darkGray
        navigationItem.backBarButtonItem = barBtn
    }

    func navigationbarAddNoteButton() {
        let addImage = UIImage(named: "plus")?.withRenderingMode(.alwaysOriginal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: addImage, style: .plain, target: self, action: #selector(openAddNoteView))
    }

    @objc private func openAddNoteView() {
        let vc = NotesDetailsVC.instantiate()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
