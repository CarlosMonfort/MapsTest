//
//  MapViewController.swift
//  Maps Test
//
//  Created by Carlos Monfort Gómez on 30/11/2018.
//  Copyright © 2018 Carlos Monfort Gómez. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var switchView: UISwitch!
    @IBOutlet weak var routesButton: UIButton!
    
    // MARK: - Variables
    let locationManager = CLLocationManager()
    var initialLocation: CLLocation!
    let regionRadius: CLLocationDistance = 1000
    var model: MapModel!
    var isAppTracking = false
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("mapVCTitle", comment: "")
        configView()
        checkLocationServices()
        model = MapModel()
        mapView.delegate = self
        isAppTracking = switchView.isOn
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    // MARK: - IBActions
    @IBAction func switchStateChange(_ sender: Any) {
        isAppTracking.toggle()
        if isAppTracking {
            model.startSavingRoute()
        } else {
            model.saveRoute()
        }
    }
    
    @IBAction func routesButtonPressed(_ sender: Any) {
        if model.routes.count > 0 {
            performSegue(withIdentifier: "routesSegue", sender: nil)
        } else {
            presentAlert(title: NSLocalizedString("warning", comment: ""), message: NSLocalizedString("noRoutes", comment: ""))
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let routesTVC = segue.destination as? RoutesTableViewController else { return }
        routesTVC.model = model
    }
    
    // MARK: - Methods
    fileprivate func setUpLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    fileprivate func checkSetUpLocationManager() {
        let state = UIApplication.shared.applicationState
        switch state {
        case .active:
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        case .background:
            if isAppTracking {
                locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
                locationManager.startMonitoringSignificantLocationChanges()
                locationManager.pausesLocationUpdatesAutomatically = true
            } else {
                locationManager.stopUpdatingLocation()
            }
        case .inactive:
            locationManager.stopUpdatingLocation()
        }
    }
    
    fileprivate func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setUpLocationManager()
            checkLocationAuthoritation()
        } else {
            presentAlert(title: NSLocalizedString("warning", comment: ""), message: NSLocalizedString("noPermission", comment: ""))
        }
    }
    
    @objc func willResignActive(_ notification: Notification) {
        checkSetUpLocationManager()
    }
    
    fileprivate func configView() {
        routesButton.setTitle(NSLocalizedString("routesButton", comment: ""), for: .normal)
        routesButton.tintColor = UIColor.white
        routesButton.backgroundColor = UIColor.black
        trackLabel.text = NSLocalizedString("trackLabel", comment: "")
    }
    
    func presentAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: nil)
        alert.addAction(okAction)
        alert.preferredAction = okAction
        present(alert, animated: true, completion: nil)
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        updateLocation(locations: locations)
    }
    
    func updateLocation(locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("\(location.coordinate.latitude), \(location.coordinate.longitude)")
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        model.saveLocations(center, isAppTracking)
        loadMap(region)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthoritation()
    }
    
    func centerMapOnLocation() {
        if let location = locationManager.location?.coordinate {
            let coordinateRegion = MKCoordinateRegion.init(center: location, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
            mapView.setRegion(coordinateRegion, animated: true)
        }
    }
    
    fileprivate func startUpdatingLocation() {
        mapView.showsUserLocation = true
        locationManager.startUpdatingLocation()
    }
    
    func checkLocationAuthoritation() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            presentAlert(title: NSLocalizedString("warning", comment: ""), message: NSLocalizedString("noPermission", comment: ""))
        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
            startUpdatingLocation()
        case .authorizedAlways:
            startUpdatingLocation()
            locationManager.allowsBackgroundLocationUpdates = true
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        let renderer = MKPolylineRenderer(polyline: polyline)
        if isAppTracking {
            renderer.strokeColor = .green
        } else {
            renderer.strokeColor = .black
        }
        renderer.lineWidth = 4
        return renderer
    }
    
    func polyLine() -> MKPolyline {
        var currentLocations: [CLLocationCoordinate2D]?
        if isAppTracking {
            currentLocations = model.currentRoute
        } else {
            currentLocations = model.locations
        }
        guard let locations = currentLocations else {
            return MKPolyline()
        }
        return MKPolyline(coordinates: locations, count: locations.count)
    }
    
    func loadMap(_ region: MKCoordinateRegion) {
        var currentLocations: [CLLocationCoordinate2D]?
        if isAppTracking {
            currentLocations = model.currentRoute
        } else {
            currentLocations = model.locations
        }
        guard let locations = currentLocations, locations.count > 0 else { return }
        mapView.setRegion(region, animated: true)
        mapView.removeOverlays(mapView.overlays)
        mapView.addOverlay(polyLine())
    }
}

