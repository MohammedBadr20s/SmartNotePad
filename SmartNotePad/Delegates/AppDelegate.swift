//
//  AppDelegate.swift
//  SmartNotePad
//
//  Created by GoKu on 19/05/2021.
//

import UIKit
import GoogleMaps
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        #if PROD
            print("Production Environment build")
        #elseif Dev
            print("Dev Environment build")
        #elseif DEBUG
            print("Local Development build")
        #endif
        
        Injection.register()
        guard #available(iOS 13, *) else {
            let nvc = UINavigationController()
            BaseCoordinator(navigationController: nvc).navigate(window: window)
            return true
        }
        IQKeyboardManager.shared.enable = true
        GMSServices.provideAPIKey("AIzaSyCWqqwZFgfz2izrtj9ObPNdlW7PzbAeDdE")

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

