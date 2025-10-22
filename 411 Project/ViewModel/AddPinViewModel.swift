import Foundation
import CoreLocation
import FirebaseFirestore

// This ViewModel validates and creates a new Bathroom object.
class AddPinViewModel {
    
    // This will hold the coordinate passed from the map
    var coordinate: CLLocationCoordinate2D?
    
    // Validation error enum
    enum ValidationError: Error {
        case missingName
        case missingCoordinate
    }
    
    // Creates a new Bathroom data object
    func createBathroom(name: String?, code: String?, notes: String?, isUnisex: Bool) throws -> Bathroom {
        
        guard let name = name, !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ValidationError.missingName
        }
        
        guard let coordinate = self.coordinate else {
            throw ValidationError.missingCoordinate
        }
        
        // Create the Firestore GeoPoint
        let geoPoint = GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        // Create and return the new Bathroom struct
        return Bathroom(
            name: name,
            code: code,
            notes: notes,
            isUnisex: isUnisex,
            location: geoPoint
        )
    }
}

