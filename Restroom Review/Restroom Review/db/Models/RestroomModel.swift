//
//  RestroomModel.swift
//  Restroom Review
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct RestroomModel {
    let db = Firestore.firestore()

    func createRestroom(restroom: Restroom) -> String{
        let newRestroomRef = db.collection("Restrooms").document()
        do {
            try newRestroomRef.setData(from: restroom) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(newRestroomRef.documentID)")
                }
            }
        } catch let error {
            print("Error writing city to Firestore: \(error)")
        }
        return newRestroomRef.documentID
    }
    
    func getRestroomByID(restroomID: String) async throws -> Restroom {
        let restroomRef = db.collection("Restrooms").document(restroomID)
        return try await restroomRef.getDocument(as: Restroom.self)
    }
}
