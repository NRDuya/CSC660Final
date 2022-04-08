//
//  AddReviewViewController.swift
//  Restroom Review
//

import UIKit
import Cosmos
import FirebaseAuth

protocol AddReviewDelegate: AnyObject {
    func addReview(review: Review)
}

class AddReviewViewController: UIViewController, UITextViewDelegate {
    let userModel = UserModel()
    
    @IBOutlet weak var restroomName: UILabel!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var content: UITextView!
    
    weak var delegate: AddReviewDelegate? = nil
    var restroom: Restroom?
    var ratingNumber: Double = 1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        restroomName.text = restroom?.name
        rating.settings.fillMode = .half
        rating.didFinishTouchingCosmos = handleChangeRating
        content.inputAccessoryView = toolbar
        content.delegate = self
        content.becomeFirstResponder()
        content.text = placeholder
        content.textColor = UIColor.lightGray
        content.selectedTextRange = content.textRange(from: content.beginningOfDocument, to: content.beginningOfDocument)
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
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)

        if updatedText.isEmpty {
            textView.text = placeholder
            textView.textColor = UIColor.lightGray
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        } else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            textView.textColor = UIColor.black
            textView.text = text
        } else {
            return true
        }
        return false
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
    var placeholder: String = "I was walking one day and had the sudden urge to go to the restroom. This bathroom located at this place was very accomodating. Employees were very understanding and clearly take pride in working at a place with a clear 5 star restroom. The entrance to the restroom was nothing amazing. However, the facilities from the toilets to the napkins were nothing short of the best of the best. 10/10 would poop again."
}
