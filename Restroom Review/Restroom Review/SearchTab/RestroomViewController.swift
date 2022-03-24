//
//  RestroomViewController.swift
//  Restroom Review
//
//  Created by Nathaniel Duya on 3/22/22.
//

import UIKit

class RestroomViewController: UIViewController {
    let restroomModel = RestroomModel()
    var restroomID: String?
    
    @IBOutlet weak var restroomName: UILabel!
    @IBOutlet weak var restroomPhone: UILabel!
    @IBOutlet weak var reviewTable: UITableView!

    @IBAction func addReviewClicked(_ sender: UIButton) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let restroomID = restroomID else {
            return
        }
        
        Task {
            do {
                let restroom = try await restroomModel.getRestroom(restroomID: restroomID)
                await MainActor.run {
                    restroomName.text = restroom.name
                    if let phone = restroom.phone {
                        restroomPhone.text = phone
                    }
                }
            } catch {
                print("err")
            }
        }
    }
    
}
