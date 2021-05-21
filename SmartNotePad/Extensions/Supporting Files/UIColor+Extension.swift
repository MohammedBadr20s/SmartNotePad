//
//  UIColor+Extension.swift
//  AutoPress-IOS
//
//  Created by GoKu on 20/02/2021.
//  Copyright © 2021 Mohammed. All rights reserved.
//

import UIKit


extension UIColor {
    
    @nonobjc class var lightGrey: UIColor {
        return UIColor(named: "lightGrey") ?? .lightGray
    }
    @nonobjc class var AccentColor: UIColor {
        return UIColor(named: "AccentColor") ?? .black
    }
}
