//
//  MainSearchViewController.swift
//  

import UIKit
import MapKit

class MainSearchViewController: UIViewController, UISearchBarDelegate, AddRestroomDelegate, SelectAddressDelegate {
    let restroomModel = RestroomModel()
    @IBOutlet weak var searchBar: UISearchBar!

    @IBAction func unwindSearch(_ segue: UIStoryboardSegue) {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        performSegue(withIdentifier: "ChooseAddressSearchSegue", sender: self)
    }

    func addRestroom(restroom: Restroom) {
        let newRestroomID = restroomModel.createRestroom(restroom: restroom)
        restroom.documentID = newRestroomID
        dismiss(animated: true, completion: nil)
        performSegue(withIdentifier: "ToRestroomSegue", sender: restroom)
    }
    
    func selectAddress(address: MKMapItem) {
        performSegue(withIdentifier: "ToRestroomMapSegue", sender: address)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addRestroomVC = segue.destination as? AddRestroomViewController {
            addRestroomVC.delegate = self
        }
        
        if let restroomVC = segue.destination as? RestroomViewController {
            if let restroom = sender as? Restroom {
                restroomVC.restroom = restroom
            } else if let restroomID = sender as? String {
                restroomVC.restroomID = restroomID
            }
        }
        
        if let selectAddressVC = segue.destination as? SelectAddressViewController {
            selectAddressVC.delegate = self
        }
        
        if let restroomMapVC = segue.destination as? MapTableRestroomViewController {
            if let sender = sender as? MKMapItem {
                restroomMapVC.restroomAddress = sender
            }
        }
    }
}
