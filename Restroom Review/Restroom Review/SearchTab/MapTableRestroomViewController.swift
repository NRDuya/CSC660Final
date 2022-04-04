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
    @IBOutlet weak var searchAreaButton: UIButton!
    @IBOutlet weak var restroomMapView: MKMapView!
    let locationManager = CLLocationManager()
    var restrooms: [Restroom] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        restroomMapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
        searchAreaButton.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.stopUpdatingLocation()
        }
    }

    @IBAction func showRestroomTablePressed(_ sender: UIButton) {
        showRestroomTable(showRestroom: nil)
    }
    
    @IBAction func searchAreaPressed(_ sender: UIButton) {
        let center = restroomMapView.centerCoordinate
        let region = restroomMapView.region
        restroomMapView.removeAnnotations(restroomMapView.annotations)
        loadRestroomsFromLocation(center: center, region: region)
    }
    
    func showRestroomTable(showRestroom: IndexPath?) {
        guard let restroomTableVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TableRestroomViewController")
                as? TableRestroomViewController else {
            return
        }
        restroomTableVC.restrooms = restrooms
        if let showRestroom = showRestroom {
            restroomTableVC.showRestroom = showRestroom
        }
        let nav = UINavigationController(rootViewController: restroomTableVC)
        
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 24
        }
        present(nav, animated: true, completion: nil)
    }
    
    func loadRestroomsFromLocation(center: CLLocationCoordinate2D, region: MKCoordinateRegion) {
        let furthest = CLLocation(latitude: center.latitude + (region.span.latitudeDelta / 3),
                                  longitude: center.longitude + (region.span.longitudeDelta / 3))
        let centerLoc = CLLocation(latitude: center.latitude, longitude: center.longitude)
        let radius: Double = Double(centerLoc.distance(from: furthest))
        Task {
            do {
                restrooms = try await restroomModel.getRestroomsByBounds(center: center, radius: radius)
                await MainActor.run {
                    for restroom in restrooms {
                        let annotation = MKPointAnnotation()
                        annotation.title = restroom.name
                        let coordinates = restroom.location
                        annotation.coordinate = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
                        restroomMapView.addAnnotation(annotation)
                    }
                    searchAreaButton.isHidden = true
                }
            } catch {
                print(error)
            }
        }
    }
}


extension MapTableRestroomViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        searchAreaButton.isHidden = false
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else {
            return
        }
        let coordinates = annotation.coordinate
        let geoPointCoord = GeoPoint(latitude: coordinates.latitude, longitude: coordinates.longitude)
        if let restroomIndex = restrooms.firstIndex(where: { $0.location == geoPointCoord }) {
            let restroomPath = IndexPath(row: restroomIndex, section: 0)
            showRestroomTable(showRestroom: restroomPath)
        }
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
}
