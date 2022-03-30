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
        dismiss(animated: true, completion: nil)
        performSegue(withIdentifier: "ToRestroomSegue", sender: newRestroomID)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addRestroomVC = segue.destination as? AddRestroomViewController {
            addRestroomVC.delegate = self
        }
        
        if let restroomVC = segue.destination as? RestroomViewController, let restroomID = sender as? String {
            restroomVC.restroomID = restroomID
        }
    }
}
