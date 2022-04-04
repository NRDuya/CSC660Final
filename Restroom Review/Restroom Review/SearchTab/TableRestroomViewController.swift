//
//  TableRestroomViewController.swift
//  Restroom Review
//
//  Created by Nathaniel Duya on 4/3/22.
//

import UIKit

protocol TableRestroomDelegate: AnyObject {
    func selectRestroom(restroom: Restroom)
}

class RestroomCell: UITableViewCell {
}

class TableRestroomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var restroomTableView: UITableView!
    weak var delegate: TableRestroomDelegate? = nil
    var showRestroom: IndexPath?
    var restrooms: [Restroom] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        restroomTableView.delegate = self
        restroomTableView.dataSource = self
        restroomTableView.register(RestroomCell.self, forCellReuseIdentifier: "RestroomCell")
        if let showRestroom = showRestroom {
            restroomTableView.selectRow(at: showRestroom, animated: true, scrollPosition: .top)
        }
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let restroom = restrooms[indexPath.row]
        delegate?.selectRestroom(restroom: restroom)
    }
}
