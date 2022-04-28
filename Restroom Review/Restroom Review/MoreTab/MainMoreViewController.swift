//
//  MainMoreViewController.swift
//  Restroom Review
//

import UIKit
import FirebaseAuthUI

class OptionCell: UITableViewCell {
    
}

class MainMoreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let moreOptions: [String] = ["Update Name", "Update Password"]
    @IBOutlet weak var moreTableView: UITableView!
    
    override func viewDidLoad() {
        moreTableView.delegate = self
        moreTableView.dataSource = self
        moreTableView.register(OptionCell.self, forCellReuseIdentifier: "OptionCell")
        super.viewDidLoad()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        moreOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell") as? OptionCell else {
            return UITableViewCell()
        }
        let option = moreOptions[indexPath.row]
        
        cell.textLabel?.text = option
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let segueIdentifier: String
        switch indexPath.row {
            case 0:
                segueIdentifier = "UpdateNameSegue"
            case 1:
                segueIdentifier = "UpdatePasswordSegue"
            default:
                segueIdentifier = ""
        }
        
        if Auth.auth().currentUser != nil {
            performSegue(withIdentifier: segueIdentifier, sender: moreOptions[indexPath.row])
        } else {
            tabBarController?.selectedIndex = 1
        }
    }
}
