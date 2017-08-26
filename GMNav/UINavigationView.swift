//
//  NavigationView.swift
//  GMNav
//
//  Created by MacBook Pro on 8/26/17.
//  Copyright © 2017 ATAMAN Community. All rights reserved.
//

import UIKit
import GoogleMaps
import SnapKit

class UINavigationView: UIView {
    
    var locationManager = CLLocationManager()
    var mapView: GMSMapView!
    var zoomLevel: Float = 15.0
    var currentLocation = CLLocation(latitude: 40.670594, longitude: -73.957055)
    var routePolyline: GMSPolyline!
    
    func navigateToCoordinate(location: CLLocationCoordinate2D) {
        
        GoogleMapsDirections.direction(fromOriginCoordinate: GoogleMapsService.LocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude), toDestinationCoordinate: GoogleMapsService.LocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)) {
            (response, error) -> Void in
            // Check Status Code
            guard response?.status == GoogleMapsDirections.StatusCode.ok else {
                // Status Code is Not OK
                debugPrint(response?.errorMessage ?? "ISSUE")
                return
            }
            
            if let response = response {
                if let route = response.routes.first {
                    if let overview = route.overviewPolylinePoints {
                        self.drawPolyline(overview)
                    }
                }
            }
            
            debugPrint("it has \(response?.routes.count ?? 0) routes")
        }
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        initializeMapView()
        initializeLocationManager()
    }
    
    private func initializeMapView() {
        let camera = GMSCameraPosition.camera(withLatitude: currentLocation.coordinate.latitude,
                                              longitude: currentLocation.coordinate.longitude,
                                              zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: self.bounds, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        addSubview(mapView)
        mapView.snp.makeConstraints { (make) in
            make.left.equalTo(snp.left)
            make.top.equalTo(snp.top)
            make.right.equalTo(snp.right)
            make.bottom.equalTo(snp.bottom)
        }
    }
    
    private func initializeLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    
    func  drawPolyline(_ route : String) {
        let path: GMSPath = GMSPath(fromEncodedPath: route)!
        self.routePolyline = GMSPolyline(path: path)
        routePolyline.strokeWidth = 5.0
        routePolyline.geodesic = true
        routePolyline.strokeColor = UIColor.blue
        self.routePolyline.map = self.mapView
    }
}

extension UINavigationView : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations.last!
        let camera = GMSCameraPosition.camera(withLatitude: self.currentLocation.coordinate.latitude,
                                              longitude: self.currentLocation.coordinate.longitude,
                                              zoom: zoomLevel)
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}
