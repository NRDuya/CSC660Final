//
//  TableRestroomViewController.swift
//  Restroom Review
//
//  Created by Nathaniel Duya on 4/3/22.
//

import UIKit

class RestroomCell: UITableViewCell {
}

class TableRestroomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var restroomTableView: UITableView!
    var restrooms: [Restroom] = []
    var showRestroom: IndexPath = IndexPath(row: 0, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        restroomTableView.delegate = self
        restroomTableView.dataSource = self
        restroomTableView.register(RestroomCell.self, forCellReuseIdentifier: "RestroomCell")
        restroomTableView.scrollToRow(at: showRestroom, at: .top, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        restrooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RestroomCell") else {
            return UITableViewCell()
        }
        
        let restroom = restrooms[indexPath.row]
        cell.textLabel?.text = restroom.name
        return cell
    }

}
