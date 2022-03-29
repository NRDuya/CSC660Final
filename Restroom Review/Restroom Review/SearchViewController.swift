//
//  SearchViewController.swift
//  
//
//  Created by Nathaniel Duya on 3/21/22.
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
    @IBAction func butto(_ sender: Any) {
        performSegue(withIdentifier: "ToRestroomSegue", sender: "zjEnWsHUuL8D4IJD7kAx")
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
