//
//  CustomButtons.swift
//  AutoPress-IOS
//
//  Created by MGoKu on 11/23/20.
//  Copyright © 2020 Mohammed. All rights reserved.
//

import UIKit



extension UIButton {
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel?.numberOfLines = 0
    }

    var imageContentMode: ContentMode{
        set{
            self.imageView?.contentMode = newValue
        }
        get{
            guard let contentMode = self.imageView?.contentMode else { return .scaleAspectFit }
            return contentMode
        }
    }
    
    @IBInspectable
    var localizedTitle: String{
        set{
            self.setTitle(newValue.localized(), for: .normal)
        }
        get{
            return self.localizedTitle
        }
    }
}
