
import MapKit

/// A custom map annotation to represent a bathroom location.
/// It inherits from MKPointAnnotation to be easily added to a map.
class BathroomAnnotation: MKPointAnnotation {
    
    let code: String
    let notes: String
    let isUnisex: Bool
    
    /// Rating of how clean the restroom is (for example, 1–5).
    let cleanRating: Int
    
    /// Overall bathroom quality rating (for example, 1–5).
    let bathroomRating: Int

    /// Initializes a new BathroomAnnotation.
    init(title: String,
         code: String,
         notes: String,
         isUnisex: Bool,
         cleanRating: Int,
         bathroomRating: Int,
         coordinate: CLLocationCoordinate2D) {
        
        self.code = code
        self.notes = notes
        self.isUnisex = isUnisex
        self.cleanRating = cleanRating
        self.bathroomRating = bathroomRating
        
        super.init()
        
        // Properties inherited from MKPointAnnotation
        self.title = title
        self.coordinate = coordinate
        
        // Short info in the standard callout.
        self.subtitle = "Code: \(code) • Clean: \(cleanRating)/5"
    }
}
