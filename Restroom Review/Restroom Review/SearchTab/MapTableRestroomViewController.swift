//
//  MapTableRestroomViewController.swift
//  Restroom Review
//
//  Created by Nathaniel Duya on 3/31/22.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseFirestore

class MapTableRestroomViewController: UIViewController {
    let restroomModel = RestroomModel()
    @IBOutlet weak var restroomMapView: MKMapView!
    let locationManager = CLLocationManager()
    var restrooms: [Restroom] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.stopUpdatingLocation()
        }
    }

    @IBAction func showRestroomTable(_ sender: UIButton) {
        let restroomTable = UITableViewController()
        let nav = UINavigationController(rootViewController: restroomTable)
        
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 24
            sheet.largestUndimmedDetentIdentifier = .medium
        }
        present(nav, animated: true, completion: nil)
    }
}

extension MapTableRestroomViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[0] as CLLocation

        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        restroomMapView.setRegion(region, animated: true)
        loadRestroomsFromLocation(center: center, region: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Error - locationManager: \(error.localizedDescription)")
    }
    
    func loadRestroomsFromLocation(center: CLLocationCoordinate2D, region: MKCoordinateRegion) {
        let furthest = CLLocation(latitude: center.latitude + (region.span.latitudeDelta / 3),
                                  longitude: center.longitude + (region.span.longitudeDelta / 3))
        let centerLoc = CLLocation(latitude: center.latitude, longitude: center.longitude)
        let radius: Double = Double(centerLoc.distance(from: furthest))
        Task {
            do {
                print("before \(restrooms)")
                restrooms = try await restroomModel.getRestroomsByBounds(center: center, radius: radius)
                await MainActor.run {
                    for restroom in restrooms {
                        let annotation = MKPointAnnotation()
                        annotation.title = restroom.name
                        let coordinates = restroom.location
                        annotation.coordinate = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
                        restroomMapView.addAnnotation(annotation)
                    }
                }
                print("after \(restrooms)")
            } catch {
                print(error)
            }
        }
    }
}


