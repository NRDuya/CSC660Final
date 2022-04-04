//
//  SearchViewController.swift
//  
//

import UIKit

class SearchViewController: UIViewController, AddRestroomDelegate {
    let restroomModel = RestroomModel()
    let searchController = UISearchController()
    
    @IBAction func unwindSearch(_ segue: UIStoryboardSegue) {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.searchController = searchController
    }

    func addRestroom(restroom: Restroom) {
        let newRestroomID = restroomModel.createRestroom(restroom: restroom)
        restroom.documentID = newRestroomID
        dismiss(animated: true, completion: nil)
        performSegue(withIdentifier: "ToRestroomSegue", sender: restroom)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addRestroomVC = segue.destination as? AddRestroomViewController {
            addRestroomVC.delegate = self
        }
        
        if let restroomVC = segue.destination as? RestroomViewController {
            if let restroom = sender as? Restroom {
                restroomVC.restroom = restroom
            }
            if let restroomID = sender as? String {
                restroomVC.restroomID = restroomID
            }
        }
    }
}
