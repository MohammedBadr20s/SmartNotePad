//
//  Storyboarded.swift
//  SmartNotePad
//
//  Created by GoKu on 19/05/2021.
//

import UIKit

protocol Storyboarded {
    static func instantiate() -> Self
}

extension Storyboarded where Self: UIViewController {
    static func instantiate(StoryboardName name: String) -> Self {
        let id = String(describing: self)
        let storyboard = UIStoryboard(name: name, bundle: nil)
        //Forced Typecast is safe here because if your controller's class must always match its storyboard ID
        if #available(iOS 13, *){
            return storyboard.instantiateViewController(identifier: id) as! Self
        } else {
            return storyboard.instantiateViewController(withIdentifier: id) as! Self
        }
    }
    
    static func instantiate() -> Self {
        let id = String(describing: self)
        let Nib = UINib(nibName: id, bundle: nil)
        return Nib.instantiate(withOwner: nil, options: nil)[0] as! Self
    }
}
