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
    let rating: Double
    let tag: Array<String>?
    var displayName: String?

    init(author: DocumentReference, content: String, rating: Double, displayName: String) {
        self.author = author
        self.content = content
        self.rating = rating
        self.displayName = displayName
        self.tag = nil
    }
    
    enum CodingKeys: String, CodingKey {
        case documentID
        case author
        case content
        case rating
        case tag
        case displayName
    }
}
