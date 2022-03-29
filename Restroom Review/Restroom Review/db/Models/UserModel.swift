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
    
    func getUserDisplayname(userRef: String) async throws -> String {
        let user = try await db.document(userRef).getDocument()
        let displayName = user.data()?["displayName"] as? String ?? "No name"
        return displayName
    }
    
    func getUserRefPath(userID: String) -> DocumentReference {
        let documentRefString = db.collection("Users").document(userID)
        let userRef: DocumentReference = db.document(documentRefString.path)
        return userRef
    }
}
