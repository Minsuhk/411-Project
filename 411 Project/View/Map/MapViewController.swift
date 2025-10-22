import UIKit
import MapKit
import CoreLocation
import FirebaseFirestore

// This is the main view controller that displays the map.
class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, MapViewModelDelegate { // <-- Add MapViewModelDelegate

    // MARK: - UI Properties
    private let mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    // MARK: - Properties
    private let locationManager = CLLocationManager()
    private var viewModel = MapViewModel() // Instantiate the ViewModel

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Bathroom Codes"
        view.backgroundColor = .white
                
        setupMapView()
        setupLocationManager()
        setupGestureRecognizers()
        setupViewModel() // <-- Add this
        
        // Add a button to re-center on user's location
        let locationButton = UIBarButtonItem(
            image: UIImage(systemName: "location.fill"),
            style: .plain,
            target: self,
            action: #selector(centerOnUserLocation)
        )
        self.navigationItem.rightBarButtonItem = locationButton
        
        // Button to add pin at current location
        let addPinButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addPinAtCurrentLocation)
        )
        self.navigationItem.leftBarButtonItem = addPinButton
    }

    // MARK: - Setup
    
    // --- 1. Setup the ViewModel ---
    private func setupViewModel() {
        viewModel.delegate = self
        viewModel.fetchBathrooms() // Start listening for pins
    }
    
    private func setupMapView() {
        view.addSubview(mapView)
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func setupGestureRecognizers() {
        // Add a long press gesture to add a pin
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        mapView.addGestureRecognizer(longPressGesture)
    }

    // MARK: - Actions
    @objc private func addPinAtCurrentLocation() {
        if let userLocation = locationManager.location?.coordinate {
            // We have the location, present the add pin screen
            presentAddPinScreen(at: userLocation)
        } else {
            // This will be called if permissions are denied or location is not yet found
            print("Cannot add pin: User location is not available.")
            let alert = UIAlertController(
                title: "Location Not Found",
                message: "We can't find your current location to add a pin. Please make sure location services are enabled and try again.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    @objc private func centerOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            // --- FIX for NaN Error ---
            guard CLLocationCoordinate2DIsValid(location) else {
                print("Invalid coordinate received from location manager.")
                return
            }
            // --- End of Fix ---
            let region = MKCoordinateRegion(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
    }
    
    @objc private func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        // We only want to trigger this once, at the beginning of the press
        if gestureRecognizer.state != .began {
            return
        }
        
        let touchPoint = gestureRecognizer.location(in: mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        // Present the AddPinViewController
        presentAddPinScreen(at: touchMapCoordinate)
    }
    
    // --- 2. Create a single function to present the AddPin screen ---
    private func presentAddPinScreen(at coordinate: CLLocationCoordinate2D) {
        let addPinVC = AddPinViewController()
        let addPinViewModel = AddPinViewModel()
        addPinViewModel.coordinate = coordinate // Pass coordinate to the ViewModel
        addPinVC.viewModel = addPinViewModel
        
        // Set up a closure to get the new bathroom data back
        // This 'onSave' closure now returns a 'Bathroom' model, not an annotation
        addPinVC.onSave = { [weak self] newBathroom in
            // --- 3. Use the new 'addBathroom' method ---
            self?.viewModel.addBathroom(bathroom: newBathroom)
        }
        
        // Present it modally
        let navigationController = UINavigationController(rootViewController: addPinVC)
        present(navigationController, animated: true)
    }
    
    // (This function is no longer needed, 'didFetchBathrooms' handles it)
    // private func addPinToMap(annotation: BathroomAnnotation) { ... }

    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Center the map on the user's location the first time it's found.
        if let location = locations.first {
            // --- FIX for NaN Error ---
            guard CLLocationCoordinate2DIsValid(location.coordinate) else {
                print("Invalid coordinate received from location manager.")
                return
            }
            // --- End of Fix ---
            
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1500, longitudinalMeters: 1500)
            mapView.setRegion(region, animated: true)
            
            // Stop updating location to save battery
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user's location: \(error.localizedDescription)")
    }
    
    // MARK: - MapViewModelDelegate
    
    // --- 4. Implement the delegate method ---
    // This function will be called by the ViewModel whenever the pins are updated
    func didFetchBathrooms(_ bathrooms: [Bathroom]) {
        // 1. Remove all old pins (except the user's blue dot)
        let allAnnotations = self.mapView.annotations
        if let userAnnotation = self.mapView.userLocation as MKAnnotation? {
            let otherAnnotations = allAnnotations.filter { $0.title != userAnnotation.title }
            self.mapView.removeAnnotations(otherAnnotations)
        } else {
            self.mapView.removeAnnotations(allAnnotations)
        }
        
        // 2. Create new BathroomAnnotation objects from the Bathroom models
        let newAnnotations = bathrooms.map { bathroom -> BathroomAnnotation in
            return BathroomAnnotation(bathroom: bathroom)
        }
        
        // 3. Add the new pins to the map
        self.mapView.addAnnotations(newAnnotations)
    }

    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Don't customize the user's blue dot
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        // Handle our custom BathroomAnnotation
        guard let bathroomAnnotation = annotation as? BathroomAnnotation else {
            return nil
        }
        
        let identifier = "BathroomPin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        // Customize the pin
        annotationView?.markerTintColor = .systemBlue
        annotationView?.glyphImage = UIImage(systemName: "toilet.fill")
        
        // Set the callout details from the annotation's bathroom model
        annotationView?.titleVisibility = .visible
        annotationView?.subtitleVisibility = .visible
        
        return annotationView
    }
}

