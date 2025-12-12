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
    
    /// Validates input and creates a `BathroomAnnotation`.
    /// - Throws: A `ValidationError` if any required field is missing.
    /// - Returns: A new `BathroomAnnotation` instance.
    func createBathroomAnnotation(name: String?,
                                  code: String?,
                                  notes: String?,
                                  isUnisex: Bool,
                                  cleanRating: Int,
                                  bathroomRating: Int,
                                  coordinate: CLLocationCoordinate2D?) throws -> BathroomAnnotation {
        
        guard let coordinate = coordinate else {
            throw ValidationError.missingCoordinate
        }
        
        guard let name = name, !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ValidationError.missingName
        }
        
        guard let coordinate = self.coordinate else {
            throw ValidationError.missingCoordinate
        }
        
        // Create the Firestore GeoPoint
        let geoPoint = GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        // Clamp ratings between 1 and 5 to avoid invalid values.
        let clampedClean = max(1, min(cleanRating, 5))
        let clampedBathroom = max(1, min(bathroomRating, 5))
        
        return BathroomAnnotation(
            title: name,
            code: code,
            notes: finalNotes,
            isUnisex: isUnisex,
            cleanRating: clampedClean,
            bathroomRating: clampedBathroom,
            coordinate: coordinate
        )
    }
}

