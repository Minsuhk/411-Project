
import MapKit

/// A custom map annotation to represent a bathroom location.
/// It inherits from MKPointAnnotation to be easily added to a map.
class BathroomAnnotation: MKPointAnnotation {
    
    let code: String
    let notes: String
    let isUnisex: Bool

    /// Initializes a new BathroomAnnotation.
    init(title: String, code: String, notes: String, isUnisex: Bool, coordinate: CLLocationCoordinate2D) {
        self.code = code
        self.notes = notes
        self.isUnisex = isUnisex
        
        super.init()
        
        // Properties inherited from MKPointAnnotation
        self.title = title
        self.coordinate = coordinate
        
        // Set the subtitle property directly, rather than overriding it.
        // This resolves the build error.
        self.subtitle = "Code: \(code)"
    }
}

