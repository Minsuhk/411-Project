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
    func createBathroomAnnotation(name: String?, code: String?, notes: String?, isUnisex: Bool, coordinate: CLLocationCoordinate2D?) throws -> BathroomAnnotation {
        
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
        
        return BathroomAnnotation(title: name, code: code, notes: finalNotes, isUnisex: isUnisex, coordinate: coordinate)
    }
}
