//
//  LocationManager.swift
//  SmartNotePad
//
//  Created by GoKu on 21/05/2021.
//

import UIKit
import GoogleMaps
import CoreLocation


class LocationManager {
        
    private var locationManager: CLLocationManager
    private let geocoder = GMSGeocoder()
    
    init(locationManager: CLLocationManager, coreLocationDelegate: CLLocationManagerDelegate, googleMapsDelegate: GMSMapViewDelegate, mapView: GMSMapView, viewController: UIViewController) {
        self.locationManager = locationManager
        self.locationManager.delegate = coreLocationDelegate
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 10)
        checkLocationAuthorization(manager: self.locationManager, viewController: viewController)
        mapView.delegate = googleMapsDelegate
        GMSMarker().tracksViewChanges = false
        GMSMarker().tracksInfoWindowChanges = false
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
                showOpenSettingsAlerts(viewController: viewController)
                break
            case .authorizedAlways, .authorizedWhenInUse:
                print("Full Access")
                manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
                manager.requestLocation()
                completion?(true)
            @unknown default:
                break
            }
        } else {
            print("Location services are not enabled")
            showOpenSettingsAlerts(viewController: viewController)
        }
    }
    //Reload Map Data Function
    func refreshMap(location: CLLocationCoordinate2D, mapView: GMSMapView, completion: @escaping (_ address: String?) -> Void) {
        mapView.clear()
        let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 15)
        mapView.animate(to: camera)
        // Creates a marker in the center of the map.
        self.markLocation(coordinates: location, mapView: mapView) { (address: String?) in
            print("Address in Refresh Map: \(address)")
            completion(address)
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
    
    //Adding Marker to the Location
    func markLocation(coordinates: CLLocationCoordinate2D, mapView: GMSMapView, completion: @escaping (_ address: String?) -> Void) {
        //getting address data from Coordinates
        geocoder.reverseGeocodeCoordinate(coordinates) { (response, error) in
            guard error == nil else {
                return
            }
            
            if let result = response?.firstResult() {
                let marker = GMSMarker()
                print("\(result)")
                marker.position = coordinates
                marker.title = result.lines?[0]
                marker.snippet = result.thoroughfare
                marker.map = mapView
                let address = result.lines?.first
                completion(address)
            }
        }
    }
}
