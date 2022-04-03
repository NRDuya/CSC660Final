//
//  RestroomModel.swift
//  Restroom Review
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import CoreLocation
import GeoFire

struct RestroomModel {
    let db = Firestore.firestore()

    func createRestroom(restroom: Restroom) -> String {
        let newRestroomRef = db.collection("Restrooms").document()
        do {
            try newRestroomRef.setData(from: restroom) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(newRestroomRef.documentID)")
                }
            }
            newRestroomRef.setData(["created": FieldValue.serverTimestamp()], merge: true) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
            }
        } catch let error {
            print("Error writing restroom to Firestore: \(error)")
        }
        return newRestroomRef.documentID
    }
    
    func getRestroomByID(restroomID: String) async throws -> Restroom {
        let restroomRef = db.collection("Restrooms").document(restroomID)
        return try await restroomRef.getDocument(as: Restroom.self)
    }
    
    func getRestroomsByBounds(center: CLLocationCoordinate2D, radius: Double) async throws -> [Restroom] {
        let queryBounds = GFUtils.queryBounds(forLocation: center, withRadius: radius)
        let queries = queryBounds.map { bound -> Query in
            return db.collection("Restrooms")
                .order(by: "geohash")
                .start(at: [bound.startValue])
                .end(at: [bound.endValue])
        }
        
        var restrooms = [Restroom]()
        for query in queries {
            let newRestrooms: [Restroom] = try await query.getDocuments().documents.compactMap { document in
                let location = document.data()["location"] as? GeoPoint ?? GeoPoint(latitude: 0, longitude: 0)
                let coordinates = CLLocation(latitude: location.latitude, longitude: location.longitude)
                let centerPoint = CLLocation(latitude: center.latitude, longitude: center.longitude)
                
                let distance = GFUtils.distance(from: centerPoint, to: coordinates)
                if distance <= radius {
                    return try? document.data(as: Restroom.self)
                }
                return nil
            }
            restrooms += newRestrooms
        }
        return restrooms
    }
}
