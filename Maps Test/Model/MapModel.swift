//
//  MapModel.swift
//  Maps Test
//
//  Created by Carlos Monfort Gómez on 30/11/2018.
//  Copyright © 2018 Carlos Monfort Gómez. All rights reserved.
//

import Foundation
import CoreLocation

class MapModel {
    
    var locations: [CLLocationCoordinate2D]!
    var routes: [Route]!
    var currentRoute: [CLLocationCoordinate2D]!
    var startTime: String!
    
    init() {
        locations = [CLLocationCoordinate2D]()
        routes = [Route]()
    }
    
    func saveLocationsForRoute(_ newLocation: CLLocationCoordinate2D) {
        currentRoute.append(newLocation)
    }
    
    func saveLocations(_ newLocation: CLLocationCoordinate2D, _ isTracking: Bool) {
        locations.append(newLocation)
        if isTracking {
            saveLocationsForRoute(newLocation)
        }
    }
    
    func startSavingRoute() {
        startTime = getCurrentTimeFormmatted()
        currentRoute = [CLLocationCoordinate2D]()
        guard let currentLocation = locations.last else { return }
        currentRoute.append(currentLocation)
    }
    
    func getCurrentTimeFormmatted() -> String {
        let date = Date()
        let format = DateFormatter()
        format.timeStyle = .long
        let time = format.string(from: date)
        return time
    }
    
    func saveRoute() {
        if currentRoute.count > 0 {
            let endTime = getCurrentTimeFormmatted()
            let route = Route(locations: currentRoute, startAt: startTime, finishedAt: endTime)
            routes.append(route)
            currentRoute.removeAll()
        }
    }
}
