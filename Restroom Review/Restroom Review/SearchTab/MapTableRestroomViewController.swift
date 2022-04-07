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
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchAreaButton: UIButton!
    @IBOutlet weak var userLocationButton: UIButton!
    @IBOutlet weak var restroomMapView: MKMapView!
    var restroomAddress: MKMapItem?
    let locationManager = CLLocationManager()
    var restrooms: [Restroom] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        restroomMapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()

        if let restroomAddress = restroomAddress {
            let coordinates = restroomAddress.placemark.coordinate
            let regionRadius: CLLocationDistance = 1000
            let coordinateRegion = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
            restroomMapView.setRegion(coordinateRegion, animated: false)
            restroomMapView.setCenter(coordinates, animated: false)
            loadRestroomsFromMapLocation()
        } else if CLLocationManager.locationServicesEnabled() {
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
        loadRestroomsFromMapLocation()
    }
    
    @IBAction func userLocationPressed(_ sender: UIButton) {
        if let coordinate = locationManager.location?.coordinate {
            restroomMapView.setCenter(coordinate, animated: false)
            userLocationButton.isHidden = true
        }
    }
    
    func showRestroomTable(showRestroom: IndexPath?) {
        guard let restroomTableVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TableRestroomViewController")
                as? TableRestroomViewController else {
            return
        }
        restroomTableVC.delegate = self
        restroomTableVC.restrooms = restrooms
        if let showRestroom = showRestroom {
            restroomTableVC.showRestroom = showRestroom
        }
        if let location = locationManager.location?.coordinate {
            restroomTableVC.currentLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        }
        
        let nav = UINavigationController(rootViewController: restroomTableVC)
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 24
        }
        present(nav, animated: true, completion: nil)
    }
    
    func loadRestroomsFromMapLocation() {
        restroomMapView.removeAnnotations(restroomMapView.annotations)
        let center = restroomMapView.centerCoordinate
        let region = restroomMapView.region
        
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
                        annotation.subtitle = restroom.address
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let chooseAddressVC = segue.destination as? SelectAddressViewController {
            chooseAddressVC.delegate = self
        }
        
        if let restroomVC = segue.destination as? RestroomViewController {
            if let restroom = sender as? Restroom {
                restroomVC.restroom = restroom
            } else if let restroomID = sender as? String {
                restroomVC.restroomID = restroomID
            }
        }
    }
}


extension MapTableRestroomViewController: UISearchBarDelegate, SelectAddressDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        performSegue(withIdentifier: "ChooseAddressSegue", sender: self)
    }
    
    func selectAddress(address: MKMapItem) {
        let coordinates = address.placemark.coordinate
        restroomMapView.setCenter(coordinates, animated: false)
        loadRestroomsFromMapLocation()
    }
}


extension MapTableRestroomViewController: TableRestroomDelegate {
    func selectRestroom(restroom: Restroom) {
        // Dismiss the restroom table bottom sheet controller
        dismiss(animated: true, completion: nil)
        performSegue(withIdentifier: "ToRestroomSegue", sender: restroom)
    }
}


extension MapTableRestroomViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        searchAreaButton.isHidden = false
        userLocationButton.isHidden = restroomMapView.isUserLocationVisible
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isEqual(restroomMapView.userLocation) {
            return nil
        }
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
        annotationView.markerTintColor = UIColor.blue
        annotationView.glyphImage = UIImage(named: "icons8-toilet-bowl-50")
        return annotationView
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
        restroomMapView.setRegion(region, animated: false)
        
        loadRestroomsFromMapLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Error - locationManager: \(error.localizedDescription)")
    }
}
