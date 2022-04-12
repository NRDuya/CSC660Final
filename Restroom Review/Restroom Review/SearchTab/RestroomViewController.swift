//
//  RestroomViewController.swift
//  Restroom Review
//

import UIKit
import FirebaseAuthUI
import Cosmos

class ReviewTableViewCell: UITableViewCell {
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var content: UILabel!
}

class RestroomViewController: UIViewController, AddReviewDelegate {
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
        // If restroom was passed down
        if let restroom = restroom {
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
                    reviews = try await reviewModel.getReviewsByRestroom(restroomID: restroomID)
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
        
        if let restroom = restroom {
            restroomName.text = restroom.name
            if let phone = restroom.phone {
                restroomPhone.text = phone
            }
        }
        super.viewDidLoad()
    }
    
    @IBAction func addReviewClicked(_ sender: UIButton) {
        if Auth.auth().currentUser != nil {
          performSegue(withIdentifier: "ToAddReviewSegue", sender: nil)
        } else {
            tabBarController?.selectedIndex = 1
        }
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


extension RestroomViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = reviewTableView.dequeueReusableCell(withIdentifier: "ReviewTableViewCell") as? ReviewTableViewCell else {
            return UITableViewCell()
        }
        let review = reviews[indexPath.row]
        
        cell.rating.rating = review.rating
        cell.content.text = review.content
        if let username = review.displayName {
            cell.username.text = username
        }
        
        if let created = review.created {
            let date = Date()
            let difference = Calendar.current.dateComponents([.month, .hour, .day], from: created, to: date)
            
            if let month = difference.month, let day = difference.day, let hour = difference.hour {
                if (month == 0) {
                    if (day == 0) {
                        cell.age.text = handlePluralOrSingular(time: hour, component: "hour")
                    } else {
                        cell.age.text = handlePluralOrSingular(time: day, component: "day")
                    }
                } else {
                    cell.age.text = handlePluralOrSingular(time: month, component: "month")
                }
            }
        }

        return cell
    }
    
    func handlePluralOrSingular(time: Int, component: String) -> String{
        if (time > 1) {
            return "\(time) \(component)s ago"
        } else {
            return "\(time) \(component) ago"
        }
    }
}
