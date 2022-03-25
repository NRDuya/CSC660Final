//
//  RestroomViewController.swift
//  Restroom Review
//
//  Created by Nathaniel Duya on 3/22/22.
//

import UIKit

class ReviewCell: UITableViewCell {
    
}

class RestroomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let restroomModel = RestroomModel()
    let reviewModel = ReviewModel()
    let userModel = UserModel()
    var restroomID: String?
    var reviews: [Review] = []
    
    @IBOutlet weak var restroomName: UILabel!
    @IBOutlet weak var restroomPhone: UILabel!
    @IBOutlet weak var reviewTableView: UITableView!
    
    @IBAction func addReviewClicked(_ sender: UIButton) {
    }
    override func viewDidLoad() {
        reviewTableView.delegate = self
        reviewTableView.dataSource = self
        reviewTableView.register(ReviewCell.self, forCellReuseIdentifier: "ReviewCell")
        super.viewDidLoad()
        guard let restroomID = restroomID else {
            return
        }
        
        Task {
            do {
                let restroom = try await restroomModel.getRestroom(restroomID: restroomID)
                 
                reviews = try await reviewModel.getReviewsByRestroom(restroomID: restroomID)
                for review in reviews {
                    review.displayName = try await userModel.getUserDisplayname(userRef: review.author.path)
                }
                
                await MainActor.run {
                    restroomName.text = restroom.name
                    if let phone = restroom.phone {
                        restroomPhone.text = phone
                    }
                    reviewTableView.reloadData()
                }
            } catch {
                print("err")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = reviewTableView.dequeueReusableCell(withIdentifier: "ReviewCell") as? ReviewCell else {
            return UITableViewCell()
        }
        
        let review = reviews[indexPath.row]
        cell.textLabel?.text = review.content
        return cell
    }
    
    
}
