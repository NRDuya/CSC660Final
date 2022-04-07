//
//  TableRestroomViewController.swift
//  Restroom Review
//

import UIKit
import CoreLocation
import Cosmos

protocol TableRestroomDelegate: AnyObject {
    func selectRestroom(restroom: Restroom)
}

class RestroomTableViewCell: UITableViewCell {
    @IBOutlet weak var restroomTitle: UILabel!
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var reviewAmount: UILabel!
    @IBOutlet weak var distance: UILabel!
    
}

class TableRestroomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var restroomTableView: UITableView!
    weak var delegate: TableRestroomDelegate? = nil
    var currentLocation: CLLocation?
    var showRestroom: IndexPath?
    var restrooms: [Restroom] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        restroomTableView.delegate = self
        restroomTableView.dataSource = self
        if let showRestroom = showRestroom {
            restroomTableView.selectRow(at: showRestroom, animated: true, scrollPosition: .top)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let restroom = restrooms[indexPath.row]
        delegate?.selectRestroom(restroom: restroom)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        restrooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RestroomTableViewCell") as? RestroomTableViewCell else {
            return UITableViewCell()
        }
        let restroom = restrooms[indexPath.row]
        
        cell.restroomTitle?.text = restroom.name
        
        if let currentLocation = currentLocation {
            let restroomGeoPoint = restroom.location
            let restroomCoords = CLLocation(latitude: restroomGeoPoint.latitude, longitude: restroomGeoPoint.longitude)
            let distance = Double(currentLocation.distance(from: restroomCoords))
            let distanceMi = distance / 1609
            let roundedDistance = round(distanceMi * 100) / 100.0
            cell.distance?.text = "\(roundedDistance) mi"
        }
        return cell
    }
}
