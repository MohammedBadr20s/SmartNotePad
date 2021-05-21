//
//  BaseViewController.swift
//  SmartNotePad
//
//  Created by GoKu on 19/05/2021.
//

import UIKit
import CoreLocation

class BaseViewController: UIViewController, Storyboarded {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        ConfigureUI()
    }
    
    
    func ConfigureUI() {
        
    }
    
    
    //Check Location Authorization Function
    func checkLocationAuthorization(manager: CLLocationManager, viewController: UIViewController, completion: ((_ success: Bool?) -> Void)? = nil) {
        if CLLocationManager.locationServicesEnabled() {
            switch manager.authorizationStatus {
            case .notDetermined:
                print("No access")
                manager.requestWhenInUseAuthorization()
                break
            case  .restricted, .denied:
                print("Location Restricted or denied Settings pop up will appear")
                showOpenSettingsAlerts(viewController: viewController)
                break
            case .authorizedAlways, .authorizedWhenInUse:
                print("Full Access")
                completion?(true)
            @unknown default:
                break
            }
        } else {
            print("Location services are not enabled")
            showOpenSettingsAlerts(viewController: viewController)
        }
    }
    
    /*Show Alert when Status of Locations service is Denied or restricted
     to ask user to go to setting to enable Location Service for our app
     */
    private func showOpenSettingsAlerts(viewController: UIViewController) {
        // if Disabled location features
        let alert = UIAlertController(title: "Allow Location Access", message: "Smart Note Pad needs access to show your location. Turn on Location Services in your device settings.", preferredStyle: UIAlertController.Style.alert)
        
        // Button to Open Settings
        alert.addAction(UIAlertAction(title: "Settings", style: UIAlertAction.Style.default, handler: { action in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)")
                })
            }
        }))
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
}
