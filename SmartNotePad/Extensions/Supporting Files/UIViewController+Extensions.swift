//
//  UIViewController+Extensions.swift
//  SmartNotePad
//
//  Created by GoKu on 19/05/2021.
//

import UIKit


extension UIViewController {
    
    func navigationbarAddNoteButton(selector: Selector?) {
        let addImage = UIImage(named: "plus")?.withRenderingMode(.alwaysTemplate)
        let addBtn = UIBarButtonItem(image: addImage, style: .plain, target: self, action: selector)
        addBtn.tintColor = .AccentColor
        navigationItem.rightBarButtonItem = addBtn
    }
    
    func addEditAndDeleteButtons(deleteBtnSelector: Selector?, editBtnSelector: Selector?) {
        let deleteBtn = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: deleteBtnSelector)
        deleteBtn.tintColor = .red
        let editBtn = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: editBtnSelector)
        editBtn.tag = 10
        editBtn.tintColor = .AccentColor
        navigationItem.rightBarButtonItems = [deleteBtn, editBtn]
    }
    
    func showToast(message: String, status: Theme, position: SwiftMessages.PresentationStyle, duration: SwiftMessages.Duration = .seconds(seconds: 2)) {
        DispatchQueue.main.async {
            let success = MessageView.viewFromNib(layout: .cardView)
            success.configureTheme(status, iconStyle: .default)
            success.configureDropShadow()
            success.configureContent(title: "", body: message)
            success.button?.isHidden = true
            success.titleLabel?.isHidden = true
            var successConfig = SwiftMessages.defaultConfig
            successConfig.duration = duration
            successConfig.presentationStyle = .bottom
            successConfig.presentationContext = .automatic
            SwiftMessages.show(config: successConfig, view: success)
        }
    }
    
    
}
