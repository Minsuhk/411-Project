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
        class PaddedLabel: UILabel {
            var textInsets = UIEdgeInsets(top:8, left:12, bottom:8, right:12)
            override func drawText(in rect: CGRect) {
                let insetRect = rect.inset(by: textInsets)
                super.drawText(in: insetRect)
            }
            override var intrinsicContentSize: CGSize {
                let size = super.intrinsicContentSize
                return CGSize (
                    width: size.width + textInsets.left + textInsets.right,
                    height: size.height + textInsets.top + textInsets.bottom
                )
            }
        }
        super.viewDidLoad()
        
        let titleLabel = PaddedLabel()
        titleLabel.text = "Restroom Runner"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 30)
        titleLabel.backgroundColor = UIColor.systemGray.withAlphaComponent(0.3)
        titleLabel.layer.cornerRadius = 10
        titleLabel.layer.masksToBounds = true
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.7 // or some value
        titleLabel.textAlignment = .center
        
        navigationItem.titleView = titleLabel
        
        view.backgroundColor = .white
        automaticallyAdjustsScrollViewInsets = false // Important for older iOS versions, but good practice
        edgesForExtendedLayout = [.top, .bottom]
        extendedLayoutIncludesOpaqueBars = true
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithTransparentBackground()
        navigationController?.navigationBar.standardAppearance = navAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navAppearance
        navigationController?.navigationBar.compactAppearance = navAppearance
        navigationController?.navigationBar.isTranslucent = true
        
        view.insetsLayoutMarginsFromSafeArea = false
        mapView.insetsLayoutMarginsFromSafeArea = false
        
        setupMapView()
        setupLocationManager()
        setupGestureRecognizers()
        
        // Add a button to re-center on user's location
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "location.fill"), style: .plain, target: self, action: #selector(centerOnUserLocation))
    }

    // MARK: - Setup
    private func setupMapView() {
        view.addSubview(mapView)
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.layoutMargins =  .zero
        mapView.insetsLayoutMarginsFromSafeArea = false
        
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
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
    @objc private func centerOnUserLocation() {
        if let location = locationManager.location?.coordinate {
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
        let addPinVC = AddPinViewController()
        addPinVC.coordinate = touchMapCoordinate
        
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
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1500, longitudinalMeters: 1500)
            mapView.setRegion(region, animated: true)
            
            // Stop updating location to save battery
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user's location: \(error.localizedDescription)")
    }
    
    // MARK: - MKMapViewDelegate
    // Called when a user taps on a bathroom pin.
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let bathroomAnnotation = view.annotation as? BathroomAnnotation else {
            return
        }
        
        let locationName = bathroomAnnotation.title ?? "Bathroom"
        
        let message = """
        Location: \(locationName)
        Clean rating: \(bathroomAnnotation.cleanRating)/5
        Bathroom rating: \(bathroomAnnotation.bathroomRating)/5
        Code: \(bathroomAnnotation.code)
        """
        
        let alert = UIAlertController(title: "Bathroom Details",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

