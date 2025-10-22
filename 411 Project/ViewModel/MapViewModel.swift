import Foundation
import MapKit

class MapViewModel {
    
    // This array will be the single source of truth for all bathroom pins.
    // In a real app, you would load this data from a persistent store (like Firebase or Core Data)
    // and save to it whenever a new pin is added. For an MVP, we'll just store it in memory.
    private(set) var bathroomAnnotations: [BathroomAnnotation] = []

    /// Adds a new bathroom annotation to our data store.
    /// - Parameter annotation: The `BathroomAnnotation` to add.
    func addBathroom(annotation: BathroomAnnotation) {
        bathroomAnnotations.append(annotation)
        // In a production app, you would trigger a save to your database here.
    }
}
