//
//  UIWindow+Extensions.swift
//  AutoPress-IOS
//
//  Created by GoKu on 17/02/2021.
//  Copyright © 2021 Mohammed. All rights reserved.
//

import UIKit

extension UIWindow {
    func topViewController() -> UIViewController? {
        
        guard var topController = self.rootViewController else {
            return nil
        }
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        guard let navigation = topController as? UINavigationController, navigation.viewControllers.count > 0 else {
            return topController
        }
        
        topController = navigation.viewControllers.last ?? navigation
        
        while let lastPresintedViewController = navigation.viewControllers.last?.presentedViewController {
            topController = lastPresintedViewController
        }
        
        return topController
    }
    
    
}
