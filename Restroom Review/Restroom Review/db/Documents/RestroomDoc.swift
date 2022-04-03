//
//  RestroomDoc.swift
//  Restroom Review
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct hours: Codable {
    var day: String
    var open: Date
    var close: Date
    
    init(day: String, open: Date, close: Date) {
        self.day = day
        self.open = open
        self.close = close
    }
}

public struct Restroom: Codable {
    @DocumentID var documentID: String?
    let name: String
    let location: GeoPoint
    let geohash: String
    let address: String
    let created = FieldValue.serverTimestamp()
    let phone: String?
    let hours: Array<hours>?

    enum CodingKeys: String, CodingKey {
        case documentID
        case name
        case location
        case geohash
        case address
        case phone
        case hours
    }
}
