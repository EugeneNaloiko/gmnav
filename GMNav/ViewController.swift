//
//  ViewController.swift
//  GMNav
//
//  Created by MacBook Pro on 8/26/17.
//  Copyright © 2017 ATAMAN Community. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    let navigationView = UINavigationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(navigationView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: {
            let waypoint1: GoogleMapsService.Place = .coordinate(coordinate: GoogleMapsService.LocationCoordinate2D(latitude: 37.57, longitude: -122.329660))
            let waypoint2: GoogleMapsService.Place = .coordinate(coordinate: GoogleMapsService.LocationCoordinate2D(latitude: 37.59, longitude: -122.329660))
            let waypoint3: GoogleMapsService.Place = .coordinate(coordinate: GoogleMapsService.LocationCoordinate2D(latitude: 37.398895, longitude: -122.135147))
            let waypoints = [waypoint1, waypoint2, waypoint3]

            self.navigationView.navigateToCoordinate(location: CLLocationCoordinate2D(latitude:37.334453, longitude: -122.036093), throughWaypoints: waypoints) //Simulator
//self.navigationView.navigateToCoordinate(location: CLLocationCoordinate2D(latitude:49.945990, longitude: 36.312958)) //Kharkiv
            
//            self.navigationView.navigateToDestinationPoints(
//                firstDestinationPoint: CLLocationCoordinate2D(latitude: *first_latitude*, longitude: *first_longitude*),
//                                                     secondDestinationPoint: CLLocationCoordinate2D(latitude: *another_latitude*, longitude: *another_longitude*)
//            )
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.navigationView.frame = self.view.bounds
    }
}

