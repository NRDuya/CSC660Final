//
//  AddReviewViewController.swift
//  Restroom Review
//
//  Created by Nathaniel Duya on 3/28/22.
//

import UIKit
import Cosmos
import FirebaseAuth

protocol AddReviewDelegate: AnyObject {
    func addReview(review: Review)
}

class AddReviewViewController: UIViewController {
    let userModel = UserModel()
    weak var delegate: AddReviewDelegate? = nil
    var restroom: Restroom?
    var ratingNumber: Double = 1
    
    @IBOutlet weak var restroomName: UILabel!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var content: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        restroomName.text = restroom?.name
        rating.settings.fillMode = .half
        rating.didFinishTouchingCosmos = handleChangeRating
        content.inputAccessoryView = toolbar
    }
    
    func handleChangeRating (rating: Double) {
        self.ratingNumber = rating
    }
    
    @IBAction func postClicked(_ sender: UIButton) {
        guard let reviewContent: String = content.text, !reviewContent.isEmpty else {
            return
        }
        guard let user = Auth.auth().currentUser else {
            return
        }
        guard let displayName = user.displayName else {
            return
        }
        let author = userModel.getUserRefPath(userID: user.uid)
        
        let newReview: Review = Review(author: author, content: reviewContent, rating: ratingNumber, displayName: displayName)

        delegate?.addReview(review: newReview)
    }
}
