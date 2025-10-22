import UIKit
import MapKit
import CoreLocation

// This is the main view controller that displays the map.
class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

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
            // Check if the coordinate is valid
            guard CLLocationCoordinate2DIsValid(userLocation) else {
                print("Cannot add pin: User location is invalid.")
                return
            }
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
            // Check if the coordinate is valid before creating a region
            if CLLocationCoordinate2DIsValid(location) {
                let region = MKCoordinateRegion(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)
                mapView.setRegion(region, animated: true)
            } else {
                print("Invalid coordinate received from location manager.")
            }
        }
    }
    
    @objc private func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        // We only want to trigger this once, at the beginning of the press
        if gestureRecognizer.state != .began {
            return
        }
        
        let touchPoint = gestureRecognizer.location(in: mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        // Check if the converted coordinate is valid
        guard CLLocationCoordinate2DIsValid(touchMapCoordinate) else {
            print("Invalid coordinate from long press.")
            return
        }
        
        // Present the AddPinViewController
        presentAddPinScreen(at: touchMapCoordinate)
    }
    
    // Helper function to present the Add Pin screen
    private func presentAddPinScreen(at coordinate: CLLocationCoordinate2D) {
        let addPinVC = AddPinViewController()
        
        // Set the coordinate directly on the view controller
        addPinVC.coordinate = coordinate
        
        // Set up a closure to get the new bathroom data back
        addPinVC.onSave = { [weak self] newBathroomAnnotation in
            self?.viewModel.addBathroom(annotation: newBathroomAnnotation)
            self?.addPinToMap(annotation: newBathroomAnnotation) // Update the UI
        }
        
        // Present it modally
        let navigationController = UINavigationController(rootViewController: addPinVC)
        present(navigationController, animated: true)
    }
    
    private func addPinToMap(annotation: BathroomAnnotation) {
        // This function is now just responsible for the UI update.
        // The ViewModel handles the data management.
        mapView.addAnnotation(annotation)
    }

    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Center the map on the user's location the first time it's found.
        if let location = locations.first {
            // Check if the coordinate is valid before creating a region
            if CLLocationCoordinate2DIsValid(location.coordinate) {
                let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1500, longitudinalMeters: 1500)
                mapView.setRegion(region, animated: true)
            } else {
                print("Invalid coordinate received from didUpdateLocations.")
            }
            
            // Stop updating location to save battery
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user's location: \(error.localizedDescription)")
    }
    
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Don't customize the user's blue dot
        guard !(annotation is MKUserLocation) else {
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
        
        return annotationView
    }
}

