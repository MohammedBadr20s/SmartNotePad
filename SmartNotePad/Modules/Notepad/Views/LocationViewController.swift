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
    
    //MARK:- Outlets
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addressLabel: UILabel!
    
    //MARK:- Properties
    var backDelegate: BackDelegate?
    var locationManager: LocationManager?
    var currentLocation: CLLocationCoordinate2D?
    var delegate: LocationDelegate?
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func ConfigureUI() {
        self.title = "Pick Location"
        self.locationManager = LocationManager(locationManager: CLLocationManager(), coreLocationDelegate: self, googleMapsDelegate: self, mapView: self.mapView, viewController: self)
    }
    
    
    //Handling Getting Address of Current or Selected Location and refreshes Address UI and Location Delegate
    func handleAddressUI(location: CLLocationCoordinate2D, address: String?) {
        self.addressLabel.text = address
        self.addressLabel.textColor = .AccentColor
        
        if let currentLocation = self.currentLocation {
            let selectedLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            let currentLocationCLLocation = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
            
            let distanceInMeters = Double(selectedLocation.distance(from: currentLocationCLLocation))
            self.delegate?.getLocationInfo(selectedLocation: location, distance: distanceInMeters, address: self.addressLabel.text ?? "")
        }
    }
}

//MARK:- Location Manager Delegate Functions
extension LocationViewController: CLLocationManagerDelegate {
    
    //Native Delegate Function whenever
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.locationManager?.checkLocationAuthorization(manager: manager, viewController: self)
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
        self.locationManager?.refreshMap(location: location.coordinate, mapView: self.mapView, completion: { (address: String?) in
            self.handleAddressUI(location: location.coordinate, address: address)
        })
    }
    
}
//MARK:- Googe Maps Delegate Functions
extension LocationViewController: GMSMapViewDelegate {
    
    //Handling didTap on Specific Location on Map Function
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
        self.showToast(message: "You tapped at \(coordinate.latitude.round(places: 2)),\(coordinate.longitude.round(places: 2)) long press to Select Different Location", status: .info, position: .bottom)
    }
    
    //Handling Long Press on Specific Location on Map Function
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        
        self.locationManager?.refreshMap(location: coordinate, mapView: self.mapView, completion: { (address: String?) in
            self.handleAddressUI(location: coordinate, address: address)
        })
    }
//    //Refreshing map when u stay at specific position
//    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
//        self.locationManager?.refreshMap(location: position.target, mapView: self.mapView, completion: { (address: String?) in
//            self.handleAddressUI(location: position.target, address: address)
//        })
//    }
    //Handling Native Google Maps My Location Button
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        if let location = mapView.myLocation?.coordinate {
            self.locationManager?.refreshMap(location: location, mapView: self.mapView, completion: { (address: String?) in
                self.handleAddressUI(location: location, address: address)
            })
        }
        return true
    }
    
    //Clears the Maps from markers everytime it will move
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        self.mapView.clear()
    }
    
}
