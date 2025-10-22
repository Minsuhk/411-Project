import Foundation
import FirebaseFirestore
import CoreLocation

// Delegate protocol to send data back to the ViewController
protocol MapViewModelDelegate: AnyObject {
    func didFetchBathrooms(_ bathrooms: [Bathroom])
}

class MapViewModel {
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    weak var delegate: MapViewModelDelegate?
    
    // Start listening for real-time updates
    func fetchBathrooms() {
        // The error you saw is related to the closure that starts here
        listener = db.collection("bathrooms").addSnapshotListener { [weak self] (querySnapshot, error) in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents found.")
                return
            }
            
            // --- THIS IS THE FIX ---
            // We explicitly tell compactMap that it is processing a (QueryDocumentSnapshot)
            // and should return an optional Bathroom (Bathroom?).
            // This resolves the "ambiguous" error.
            let bathrooms = documents.compactMap { (document: QueryDocumentSnapshot) -> Bathroom? in
                return try? document.data(as: Bathroom.self)
            }
            // --- END OF FIX ---
            
            // Pass the results back to the delegate (MapViewController)
            self.delegate?.didFetchBathrooms(bathrooms)
        }
    }
    
    // Add a new bathroom
    func addBathroom(bathroom: Bathroom) {
        do {
            // Use .addDocument(from:) to let Firestore auto-generate an ID
            try db.collection("bathrooms").addDocument(from: bathroom)
        } catch {
            print("Error saving bathroom: \(error.localizedDescription)")
        }
    }
    
    // Stop listening
    func stopListening() {
        listener?.remove()
    }
    
    deinit {
        stopListening()
    }
}

