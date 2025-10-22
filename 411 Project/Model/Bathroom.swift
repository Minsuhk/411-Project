import Foundation

// This struct defines the basic data model for a bathroom.
// It's separate from the map annotation, keeping the data and view logic separate.
struct Bathroom {
    let id: UUID
    let name: String
    let code: String
    let notes: String?
    let isUnisex: Bool
    // You would also include latitude and longitude here.
}

