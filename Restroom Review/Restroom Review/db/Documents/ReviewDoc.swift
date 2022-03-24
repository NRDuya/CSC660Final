//
//  ReviewDoc.swift
//  Restroom Review
//
//  Created by Nathaniel Duya on 3/23/22.
//

import Foundation
import FirebaseFirestore

public struct Review: Codable {
    let author: String
    let content: String
    let rating: Int
    let created = FieldValue.serverTimestamp()
    let tag: Array<String>?

    enum CodingKeys: String, CodingKey {
        case author
        case content
        case rating
        case tag
    }
}
