//
//  ReviewModel.swift
//  Restroom Review
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ReviewModel {
    let db = Firestore.firestore()
    
    func createReview(restroomID: String, review: Review) -> String {
        let newReviewRef = db.collection("Restrooms").document(restroomID).collection("Reviews").document()
        do {
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
}
