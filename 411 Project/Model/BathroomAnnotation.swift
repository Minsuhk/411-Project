import Foundation
import MapKit
import FirebaseFirestore

// This class represents a pin on the map.
class BathroomAnnotation: MKPointAnnotation {
    
    // We'll store the full Bathroom object here.
    let bathroom: Bathroom

    // Initialize the annotation with our Bathroom data model
    init(bathroom: Bathroom) {
        self.bathroom = bathroom
        
        super.init()
        
        // Set the properties for the map annotation
        self.coordinate = bathroom.coordinate
        self.title = bathroom.name
        
        // Create a subtitle from the other details
        var subtitleText = ""
        if let code = bathroom.code, !code.isEmpty {
            subtitleText += "Code: \(code)"
        }
        if bathroom.isUnisex {
            subtitleText += (subtitleText.isEmpty ? "" : " | ") + "Unisex"
        }
        self.subtitle = subtitleText
    }
}

