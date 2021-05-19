//
//  Constants.swift
//  SmartNotePad
//
//  Created by GoKu on 19/05/2021.
//

import UIKit

enum Constants: String {
    case token
    case AppleLanguages
    case currentUser
    case categories
    case googleAPIKey
    case environment
}


enum Environment: String {
    case Default = ""
    case Development = "Dev URL"
    case Production = "Prod URL"
    
    func changeTo() {
        UserDefaults.standard.setValue(self.rawValue, forKey: Constants.environment.rawValue)
        UserDefaults.standard.synchronize()
    }
    func current() -> Environment? {
        return Environment(rawValue: UserDefaults.standard.value(forKey: Constants.environment.rawValue) as! String)
    }
}

enum AppLanguages: String{
    case en, ar
}
