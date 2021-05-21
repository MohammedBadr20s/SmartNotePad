//
//  LocationViewController.swift
//  SimpleMath
//
//  Created by Mbadr on 25/04/2021.
//

import UIKit
import GoogleMaps
import CoreLocation

protocol LocationDelegate {
    func getLocationInfo(selectedLocation: CLLocationCoordinate2D, distance: Double, address: String)
}

class LocationViewController: BaseViewController {
    
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addressLabel: UILabel!
    var backDelegate: BackDelegate?
    var locationManager: CLLocationManager?
    let geocoder = GMSGeocoder()
    var currentLocation: CLLocationCoordinate2D?
    var delegate: LocationDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func ConfigureUI() {
        self.SetupCoreLocations()
    }
    //Setup Locations
    func SetupCoreLocations() {
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
        self.mapView.isMyLocationEnabled = true
        self.mapView.settings.myLocationButton = true
        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 10)
        checkLocationAuthorization(manager: self.locationManager!)
        mapView.delegate = self
        GMSMarker().tracksViewChanges = false
        GMSMarker().tracksInfoWindowChanges = false
        print("Google Maps License \(GMSServices.openSourceLicenseInfo())")
    }
    
    
    //Check Location Authorization Function
    func checkLocationAuthorization(manager: CLLocationManager) {
        if CLLocationManager.locationServicesEnabled() {
            switch manager.authorizationStatus {
            case .notDetermined:
                print("No access")
                manager.requestWhenInUseAuthorization()
                break
            case  .restricted, .denied:
                showOpenSettingsAlerts()
                break
            case .authorizedAlways, .authorizedWhenInUse:
                print("Full Access")
                manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
                manager.requestLocation()
            @unknown default:
                break
            }
        } else {
            print("Location services are not enabled")
            showOpenSettingsAlerts()
        }
    }
}


extension LocationViewController: CLLocationManagerDelegate {
    //Native Delegate Function whenever
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.checkLocationAuthorization(manager: manager)
    }
    //Native Delegate Function whenever a fail happens during getting location
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.showToast(message: "Failed to get user's location: \(error.localizedDescription)", status: .info, position: .bottom)
    }
    /*Native Delegate Function of CLLocation Manager whenever LocationRequest or
     StartLocationUpdates() Function is running this function gets the latest location
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        //This Condition to get the first location it fetches once the maps loaded which means your current Location
        if self.currentLocation == nil {
            self.currentLocation = location.coordinate
        }
        refreshMap(location: location.coordinate)
    }
    
    //RefreshMap Function
    func refreshMap(location: CLLocationCoordinate2D) {
        self.mapView.clear()
        let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 15)
        self.mapView.animate(to: camera)
        // Creates a marker in the center of the map.
        self.markLocation(coordinates: location)
    }
    /*Show Alert when Status of Locations service is Denied or restricted
     to ask user to go to setting to enable Location Service for our app
     */
    private func showOpenSettingsAlerts() {
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
        self.present(alert, animated: true, completion: nil)
    }
}

extension LocationViewController: GMSMapViewDelegate {
    //Handling didTap on Specific Location on Map Function
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
        self.showToast(message: "You tapped at \(coordinate.latitude.round(places: 2)),\(coordinate.longitude.round(places: 2)) long press to Select Different Location", status: .info, position: .bottom)
    }
    //Handling Long Press on Specific Location on Map Function
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        refreshMap(location: coordinate)
    }
    //Handling Native Google Maps My Location Button
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        refreshMap(location: mapView.myLocation!.coordinate)
        return true
    }
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        self.mapView.clear()
    }
    //Adding Marker to the Location
    func markLocation(coordinates: CLLocationCoordinate2D) {
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
                self.addressLabel.text = result.lines?[0] ?? ""
                self.addressLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                marker.map = self.mapView
                if let currentLocation = self.currentLocation {
                    let selectedLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
                    let currentLocationCLLocation = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
                    
                    let distanceInMeters = Double(selectedLocation.distance(from: currentLocationCLLocation))
                    self.delegate?.getLocationInfo(selectedLocation: coordinates, distance: distanceInMeters, address: self.addressLabel.text ?? "")
                }
                
            }
        }
    }
}
