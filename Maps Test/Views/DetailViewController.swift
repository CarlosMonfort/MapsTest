//
//  DetailViewController.swift
//  Maps Test
//
//  Created by Carlos Monfort Gómez on 02/12/2018.
//  Copyright © 2018 Carlos Monfort Gómez. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceMetersLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Variables
    var model: MapModel!
    var route: Route!

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        startLabel.text = NSLocalizedString("startLabel", comment: "")
        startLabel.font = UIFont.preferredFont(forTextStyle: .title3).bold()
        startTimeLabel.text = route.startTime
        endLabel.text = NSLocalizedString("endLabel", comment: "")
        endLabel.font = UIFont.preferredFont(forTextStyle: .title3).bold()
        endTimeLabel.text = route.endTime
        distanceLabel.text = NSLocalizedString("distanceLabel", comment: "")
        distanceLabel.font = UIFont.preferredFont(forTextStyle: .title3).bold()
        distanceMetersLabel.text = String.localizedStringWithFormat(NSLocalizedString("distanceInMeters", comment: ""), route.getDistance() ?? 0)
        mapView.delegate = self
        loadMap()
    }
}

extension DetailViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = .black
        renderer.lineWidth = 4
        return renderer
    }
    
    func polyLine() -> MKPolyline {
        let locations = route.locations
        return MKPolyline(coordinates: locations, count: locations.count)
    }
    
    private func mapRegion() -> MKCoordinateRegion? {
        let locations = route.locations
        var latitudes = [CLLocationDegrees]()
        var longitudes = [CLLocationDegrees]()
        
        for location in locations {
            latitudes.append(location.latitude)
            longitudes.append(location.longitude)
        }
        
        let maxLat = latitudes.max()!
        let minLat = latitudes.min()!
        let maxLong = longitudes.max()!
        let minLong = longitudes.min()!
        
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLong + maxLong) / 2)
        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.3, longitudeDelta: (maxLong - minLong) * 1.3)
        return MKCoordinateRegion(center: center, span: span)
    }
    
    func loadMap() {
        if let region = mapRegion() {
            mapView.setRegion(region, animated: true)
        }
        mapView.addOverlay(polyLine())
    }
}
