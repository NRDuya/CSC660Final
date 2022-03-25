//
//  ReviewDoc.swift
//  Restroom Review
//
//  Created by Nathaniel Duya on 3/23/22.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

public class Review: Codable {
    @DocumentID var documentID: String?
    let author: DocumentReference
    let content: String
    let rating: Int
    let created = FieldValue.serverTimestamp()
    let tag: Array<String>?
    var displayName: String?

    enum CodingKeys: String, CodingKey {
        case documentID
        case author
        case content
        case rating
        case tag
        case displayName
    }
    
}
