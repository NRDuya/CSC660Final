//
//  ReviewDoc.swift
//  Restroom Review
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

public class Review: Codable {
    @DocumentID var documentID: String?
    let created: Date?
    let author: DocumentReference
    let content: String
    let rating: Double
    let tag: Array<String>?
    var displayName: String?
    var restroom: String?

    init(author: DocumentReference, content: String, rating: Double, displayName: String) {
        self.author = author
        self.content = content
        self.rating = rating
        self.displayName = displayName
        self.tag = nil
        self.created = nil
        self.restroom = nil
    }
    
    enum CodingKeys: String, CodingKey {
        case documentID
        case created
        case author
        case content
        case rating
        case tag
        case displayName
    }
}
