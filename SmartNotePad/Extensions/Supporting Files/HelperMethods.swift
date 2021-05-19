//
//  HelperMethods.swift
//  CharityProject
//
//  Created by D-TAG on 5/15/19.
//  Copyright © 2019 D-tag. All rights reserved.
//

import UIKit


struct SocialNetworkUrl {
    let scheme: String
    let page: String
    
    func openPage() {
        let schemeUrl = NSURL(string: scheme)!
        if UIApplication.shared.canOpenURL(schemeUrl as URL) {
            UIApplication.shared.open(schemeUrl as URL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(NSURL(string: page)! as URL)
        }
    }
}

enum SocialNetwork {
    case WhatsApp, Twitter, Instagram, SnapChat
    func url() -> SocialNetworkUrl {
        switch self {
        case .Twitter: return SocialNetworkUrl(scheme: "twitter:///TwitterID", page: "https://twitter.com/TwitterID")
        case .SnapChat: return SocialNetworkUrl(scheme: "snapchat://add/Snapchat ID", page: "https://www.snapchat.com/add/Snapchat ID")
        case .WhatsApp: return SocialNetworkUrl(scheme: "https://wa.me/MobileNumber", page: "https://wa.me/MobileNumber")
        case .Instagram: return SocialNetworkUrl(scheme: "instagram://Instagram ID", page:"https://www.instagram.com/Instagram ID")
        }
    }
    func openPage() {
        self.url().openPage()
    }
}
