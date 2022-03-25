//
//  ReviewModel.swift
//  Restroom Review
//
//  Created by Nathaniel Duya on 3/23/22.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ReviewModel {
    let db = Firestore.firestore()

    func getReviewsByRestroom(restroomID: String) async throws -> [Review] {
        let restroomReviewsRef = db.collection("Restrooms").document(restroomID).collection("Reviews")
        let restroomReviews = try await restroomReviewsRef.getDocuments()
        
        return restroomReviews.documents.compactMap { review in      
            return try? review.data(as: Review.self)
        }   
    }
}
