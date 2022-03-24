//
//  UserModel.swift
//  Restroom Review
//

import Foundation
import FirebaseFirestore

struct UserModel {
    let db = Firestore.firestore()

    func logUser(uid: String, displayName: String) -> Void {
        db.collection("Users").document(uid).setData(["lastLogged": FieldValue.serverTimestamp(), "displayName": displayName], merge: true)
            { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
    }
}
