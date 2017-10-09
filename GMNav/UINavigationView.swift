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
import AVFoundation

class UINavigationView: UIView {
    //UI
    var mapView: GMSMapView!
    var instructionLbl = UILabel()
    var durationLbl = UILabel()
    
    //Models
    let speechSynthesizer = AVSpeechSynthesizer() //Voice
    var locationManager = CLLocationManager()
    var zoomLevel: Float = 15.0
    var currentLocation = CLLocation(latitude: 37.344647, longitude: -122.046093)
    var toCoordinateLocation: CLLocationCoordinate2D?
    
    var timer = Timer()
    
    var routePolyline: GMSPolyline! //Blue line
    var currentRoute: GoogleMapsDirections.Response.Route?
    
    var waypoints: [GoogleMapsService.Place]?
    
    func navigateToCoordinate(location: CLLocationCoordinate2D) {
        self.currentRoute = nil
        self.toCoordinateLocation = location
        self.requestDirections()
        
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: {[weak self]   (timer) in
            self?.requestDirections()
        })
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
        initializeInstructionLbls()
    }
    
    private func initializeMapView() {
        let camera = GMSCameraPosition.camera(withLatitude: currentLocation.coordinate.latitude,
                                              longitude: currentLocation.coordinate.longitude,
                                              zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: self.bounds, camera: camera)
        mapView.delegate = self
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
    
    
    private func initializeInstructionLbls() {
        instructionLbl.lineBreakMode = .byWordWrapping
        instructionLbl.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        instructionLbl.numberOfLines = 0
        instructionLbl.textAlignment = .center
        addSubview(instructionLbl)
        instructionLbl.snp.makeConstraints { (make) in
            make.top.equalTo(snp.top).offset(20)
            make.left.equalTo(snp.left)
            make.right.equalTo(snp.right)
        }
        
        durationLbl.textAlignment = .center
        durationLbl.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        durationLbl.font = UIFont.systemFont(ofSize: 17)
        addSubview(durationLbl)
        durationLbl.snp.makeConstraints { (make) in
            make.top.equalTo(instructionLbl.snp.bottom)
            make.left.equalTo(snp.left)
            make.right.equalTo(snp.right)
        }
    }
    
    func  drawPolyline(_ route : String) {
        self.routePolyline?.map = nil
        let path: GMSPath = GMSPath(fromEncodedPath: route)!
        self.routePolyline = GMSPolyline(path: path)
        routePolyline.strokeWidth = 5.0
        routePolyline.geodesic = true
        routePolyline.strokeColor = UIColor.blue
        let waypoint1: GoogleMapsService.Place = .coordinate(coordinate: GoogleMapsService.LocationCoordinate2D(latitude: 37.57, longitude: -122.329660))
        let waypoint2: GoogleMapsService.Place = .coordinate(coordinate: GoogleMapsService.LocationCoordinate2D(latitude: 37.59, longitude: -122.329660))
        let waypoint3: GoogleMapsService.Place = .coordinate(coordinate: GoogleMapsService.LocationCoordinate2D(latitude: 37.398895, longitude: -122.135147))
        waypoints = [waypoint1, waypoint2, waypoint3]
        self.routePolyline.map = self.mapView
    }
    
    func requestDirections() {
        if let location = self.toCoordinateLocation {
            GoogleMapsDirections.direction(fromOriginCoordinate: GoogleMapsService.LocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude), toDestinationCoordinate: GoogleMapsService.LocationCoordinate2D(latitude: location.latitude, longitude: location.longitude), wayPoints: waypoints) { [unowned self]
                (response, error) -> Void in
                // Check Status Code
                guard response?.status == GoogleMapsDirections.StatusCode.ok else {
                    // Status Code is Not OK
                    debugPrint(response?.errorMessage ?? "ISSUE")
                    return
                }
                
                if let response = response {
                    if let route = response.routes.first {
                        self.currentRoute = route
                        if let overview = route.overviewPolylinePoints {
                            self.drawPolyline(overview)
                        }
                        if let step = route.legs.first?.steps.first {
                            if let instructionData = step.htmlInstructions?.data(using: .utf8) {
                                self.instructionLbl.text = try? NSAttributedString(data: instructionData, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil).string
                            }
                            if let duration = step.duration?.text, let distance = step.distance?.text {
                                self.durationLbl.text = "in \(duration), \(distance)"
                            }
                            if let distanceM = step.distance?.value {
                                if distanceM > 400 && distanceM < 500 && distanceM > 150 && distanceM < 250 {
                                    if let maneuver = step.maneuver {
                                        print(maneuver)
                                    }
                                    let string = "\(self.instructionLbl.text!) in \(distanceM) meters"
                                    let speechUtterance = AVSpeechUtterance(string: string)
                                    self.speechSynthesizer.speak(speechUtterance)
                                }
                            }
                        }
                    }
                }
                
                debugPrint("it has \(response?.routes.count ?? 0) routes")
            }
        }
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

extension UINavigationView: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        self.zoomLevel = mapView.camera.zoom
    }
}
