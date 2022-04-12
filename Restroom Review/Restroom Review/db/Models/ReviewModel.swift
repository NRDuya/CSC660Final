//
//  ReviewModel.swift
//  Restroom Review
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ReviewModel {
    let userModel = UserModel()
    let db = Firestore.firestore()
    
    func createReview(restroomID: String, review: Review) -> String {
        let restroomRef = db.collection("Restrooms").document(restroomID)
        let newReviewRef = restroomRef.collection("Reviews").document()
        do {
            // Set review in review collection
            try newReviewRef.setData(from: review) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(newReviewRef.documentID)")
                }
            }
            newReviewRef.setData(["created": FieldValue.serverTimestamp()], merge: true) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
            }
            
            // Update avgRating and numRating in restroom collection
            restroomRef.getDocument() { document, err in
                if var restroomData = document?.data() {
                    let numRating = restroomData["numRating"] as! Int
                    let newNumRating = numRating + 1
                    
                    let avgRating = restroomData["avgRating"] as! Float
                    let oldAvgTotal = avgRating * Float(numRating)
                    let newAvgRating = (oldAvgTotal + Float(review.rating)) / Float(newNumRating)
                    
                    restroomData["numRating"] = newNumRating
                    restroomData["avgRating"] = newAvgRating
                    restroomRef.setData(restroomData)
                }
            }
            
        } catch let error {
            print("Error writing restroom to Firestore: \(error)")
        }
        return newReviewRef.documentID
    }
    
    func getReviewsByRestroom(restroomID: String) async throws -> [Review] {
        let restroomReviewsRef = db.collection("Restrooms").document(restroomID).collection("Reviews")
        let restroomReviews = try await restroomReviewsRef.order(by: "created", descending: true).getDocuments()
        
        return restroomReviews.documents.compactMap { review in      
            return try? review.data(as: Review.self)
        }   
    }
    
    func getReviewsByUser(userID: String) async throws -> [Review] {
        let id = userModel.getUserRefPath(userID: userID)
        let reviews = try await db.collectionGroup("Reviews").whereField("author", isEqualTo: id).getDocuments()

        return reviews.documents.compactMap { reviewData in
            let review = try? reviewData.data(as: Review.self)
            
            let parentPath = reviewData.reference.parent.parent
            review?.restroom = parentPath?.path
            
            return review
        }
    }
}
