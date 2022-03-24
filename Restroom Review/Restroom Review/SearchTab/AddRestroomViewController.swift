//
//  AddRestroomViewController.swift
//  Restroom Review
//

import UIKit
import GeoFire

protocol AddRestroomDelegate: AnyObject {
    func addRestroom(restroom: Restroom)
}

class AddRestroomViewController: UIViewController  {

    weak var delegate: AddRestroomDelegate? = nil
    
    @IBOutlet weak var restroomName: UITextField!
    @IBOutlet weak var restroomStreet: UITextField!
    @IBOutlet weak var restroomSuite: UITextField!
    @IBOutlet weak var restroomCity: UITextField!
    @IBOutlet weak var restroomPhone: UITextField!
    
    @IBAction func addRestroomClicked(_ sender: UIButton) {
        guard let name: String = restroomName.text, !name.isEmpty else {
            return
        }
        guard let street: String = restroomStreet.text, !street.isEmpty else {
            return
        }
        guard let suite: String = restroomSuite.text else {
            return
        }
        guard let city: String = restroomCity.text, !city.isEmpty else {
            return
        }
        guard let phone: String = restroomPhone.text else {
            return
        }
        let latitude = 51.5074
        let longitude = 0.12780
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let hash = GFUtils.geoHash(forLocation: location)

        let newRestroom: Restroom = Restroom(name: name, location: nil, phone: phone, hours: nil)
        
        delegate?.addRestroom(restroom: newRestroom)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    


}
