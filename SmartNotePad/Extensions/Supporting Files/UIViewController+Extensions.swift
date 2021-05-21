//
//  UIViewController+Extensions.swift
//  SmartNotePad
//
//  Created by GoKu on 19/05/2021.
//

import UIKit


extension UIViewController {
    
    func navigationbarAddNoteButton(selector: Selector?) {
        let addImage = UIImage(named: "plus")?.withRenderingMode(.alwaysOriginal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: addImage, style: .plain, target: self, action: selector)
    }
    func showToast(message: String, status: Theme, position: SwiftMessages.PresentationStyle, duration: SwiftMessages.Duration = .seconds(seconds: 2)) {
        DispatchQueue.main.async {
            guard let _ = UIApplication.shared.keyWindow else { return }
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
