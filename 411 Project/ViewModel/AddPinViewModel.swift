import Foundation
import CoreLocation
import FirebaseFirestore // From File 2

class AddPinViewModel {
    
    /// This will hold the coordinate passed from the map
    var coordinate: CLLocationCoordinate2D? // From File 2
    
    /// An enumeration for specific validation errors.
    enum ValidationError: Error, LocalizedError { // Full enum from File 1
        case missingName
        case missingCode
        case missingCoordinate
        
        var errorDescription: String? {
            switch self {
            case .missingName:
                return "Please enter a name for the location."
            case .missingCode:
                return "Please enter the bathroom code."
            case .missingCoordinate:
                return "There was an error getting the location's coordinate."
            }
        }
    }
    
    /// Validates input and creates a `Bathroom` data object ready for storage.
    /// - Throws: A `ValidationError` if any required field is missing.
    /// - Returns: A new `Bathroom` instance.
    func createBathroom(name: String?,
                        code: String?,
                        notes: String?,
                        isUnisex: Bool,
                        cleanRating: Int, // Added from File 1
                        bathroomRating: Int) throws -> Bathroom { // Added from File 1
        
        // 1. Validate Coordinate (uses class property from File 2)
        guard let coordinate = self.coordinate else {
            throw ValidationError.missingCoordinate
        }
        
        // 2. Validate Name (robust trimming from File 1)
        guard let name = name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ValidationError.missingName
        }
        
        // 3. Validate Code (from File 1)
        guard let code = code, !code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ValidationError.missingCode
        }
        
        // Finalize Notes (use nil-coalescing)
        let finalNotes = notes ?? ""
        
        // Clamp ratings between 1 and 5 to avoid invalid values. (From File 1)
        let clampedClean = max(1, min(cleanRating, 5))
        let clampedBathroom = max(1, min(bathroomRating, 5))
        
        // Create the Firestore GeoPoint (From File 2)
        let geoPoint = GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        // Create and return the new Bathroom struct (Unified object creation)
        return Bathroom(
            name: name,
            code: code,
            notes: finalNotes,
            isUnisex: isUnisex,
            cleanRating: clampedClean,        // Added property
            bathroomRating: clampedBathroom,  // Added property
            location: geoPoint
        )
    }
}
