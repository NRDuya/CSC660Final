//
//  RestroomViewController.swift
//  Restroom Review
//

import UIKit
import FirebaseAuthUI

class ReviewCell: UITableViewCell {
}

class RestroomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddReviewDelegate {
    let restroomModel = RestroomModel()
    let reviewModel = ReviewModel()
    let userModel = UserModel()
    
    @IBOutlet weak var restroomName: UILabel!
    @IBOutlet weak var restroomPhone: UILabel!
    @IBOutlet weak var reviewTableView: UITableView!
    
    var restroomID: String?
    var restroom: Restroom?
    var reviews: [Review] = []


    @IBAction func unwindSearch(_ segue: UIStoryboardSegue) {}
    
    override func viewDidLoad() {
        reviewTableView.delegate = self
        reviewTableView.dataSource = self
        reviewTableView.register(ReviewCell.self, forCellReuseIdentifier: "ReviewCell")
        
        super.viewDidLoad()
        // If restroom was passed down
        if let restroom = restroom {
            restroomName.text = restroom.name
            if let phone = restroom.phone {
                restroomPhone.text = phone
            }
            Task {
                do {
                    guard let restroomDocID = restroom.documentID else {
                        return
                    }

                    reviews = try await reviewModel.getReviewsByRestroom(restroomID: restroomDocID)
                    for review in reviews {
                        review.displayName = try await userModel.getUserDisplayname(userRef: review.author.path)
                    }
                    
                    await MainActor.run {
                        reviewTableView.reloadData()
                    }
                } catch {
                    print(error)
                }
            }
        }
        // If no restroom passed and ID passed instead
        else if let restroomID = restroomID {
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
    }
    
    @IBAction func addReviewClicked(_ sender: UIButton) {
        if Auth.auth().currentUser != nil {
          performSegue(withIdentifier: "ToAddReviewSegue", sender: nil)
        } else {
            tabBarController?.selectedIndex = 1
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
