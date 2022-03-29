//
//  RestroomViewController.swift
//  Restroom Review
//
//  Created by Nathaniel Duya on 3/22/22.
//

import UIKit

class ReviewCell: UITableViewCell {
    
}

class RestroomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddReviewDelegate {
    let restroomModel = RestroomModel()
    let reviewModel = ReviewModel()
    let userModel = UserModel()
    var restroomID: String?
    var restroom: Restroom?
    var reviews: [Review] = []
    
    @IBOutlet weak var restroomName: UILabel!
    @IBOutlet weak var restroomPhone: UILabel!
    @IBOutlet weak var reviewTableView: UITableView!
    
    @IBAction func unwindSearch(_ segue: UIStoryboardSegue) {}

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
                restroom = try await restroomModel.getRestroomByID(restroomID: restroomID)
                guard let restroom = restroom else {
                    return
                }

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
                print(error)
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
        cell.textLabel?.text = "\(review.displayName) \(review.content)"
        return cell
    }
    
    func addReview(review: Review) {
        guard let restroom = restroom else {
            return
        }
        guard let restroomID = restroom.documentID else {
            return
        }

        let newReviewID = reviewModel.createReview(restroomID: restroomID, review: review)
        review.documentID = newReviewID
        reviews.insert(review, at: 0)
        reviewTableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addReviewVC = segue.destination as? AddReviewViewController {
            addReviewVC.delegate = self
            addReviewVC.restroom = restroom
        }
    }
    
}
