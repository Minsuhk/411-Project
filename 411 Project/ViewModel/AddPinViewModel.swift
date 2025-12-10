import Foundation
import CoreLocation

class AddPinViewModel {
    
    /// An enumeration for specific validation errors.
    enum ValidationError: Error, LocalizedError {
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
        
        guard let name = name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ValidationError.missingName
        }
        
        guard let code = code, !code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ValidationError.missingCode
        }
        
        let finalNotes = notes ?? ""
        
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
