import Foundation
import FirebaseFirestore
import CoreLocation

// The main data model for a bathroom.
// We make it Codable to easily convert it to/from Firestore.
struct Bathroom: Codable, Identifiable {
    
    @DocumentID var id: String? // This will automatically hold the Firestore document ID
    var name: String
    var code: String?
    var notes: String?
    var isUnisex: Bool
    var location: GeoPoint // Use Firestore's GeoPoint for coordinates
    
    // We can add a helper to get the coordinate
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    }
}

