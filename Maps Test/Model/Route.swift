//
//  Route.swift
//  Maps Test
//
//  Created by Carlos Monfort Gómez on 02/12/2018.
//  Copyright © 2018 Carlos Monfort Gómez. All rights reserved.
//

import Foundation
import CoreLocation

class Route {
    
    var locations: [CLLocationCoordinate2D]
    var startTime: String
    var endTime: String
    
    init(locations: [CLLocationCoordinate2D], startAt: String, finishedAt: String) {
        self.locations = locations
        self.startTime = startAt
        self.endTime = finishedAt
    }
    
    func getDistance() -> CLLocationDistance? {
        guard let firstLocation = locations.first else { return nil }
        guard let lastLocation = locations.last else { return nil }
        let firstCoordinate = CLLocation(latitude: firstLocation.latitude, longitude: firstLocation.longitude)
        let lastCoordinate = CLLocation(latitude: lastLocation.latitude, longitude: lastLocation.longitude)
        
        let distanceInMeters = firstCoordinate.distance(from: lastCoordinate)
        
        return distanceInMeters
    }
}
