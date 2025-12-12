import UIKit
import CoreLocation

class AddPinViewController: UIViewController {

    // MARK: - Properties
    var coordinate: CLLocationCoordinate2D?
    var onSave: ((BathroomAnnotation) -> Void)?
    private var viewModel = AddPinViewModel()

    // MARK: - UI Components
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Location Name"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "e.g., Starbucks on Main St"
        textField.borderStyle = .roundedRect
        return textField
    }()

    private let codeLabel: UILabel = {
        let label = UILabel()
        label.text = "Bathroom Code"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private let codeTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "e.g., 12345"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        return textField
    }()
    
    private let isUnisexLabel: UILabel = {
        let label = UILabel()
        label.text = "Unisex"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private let isUnisexSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = false
        return toggle
    }()

    private let notesLabel: UILabel = {
        let label = UILabel()
        label.text = "Notes (Optional)"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()

    private let notesTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 5.0
        return textView
    }()
    
    private let cleanRatingLabel: UILabel = {
        let label = UILabel()
        label.text = "Clean Rating (1–5)"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()

    private let cleanRatingControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["1","2","3","4","5"])
        control.selectedSegmentIndex = 3 // default to 4
        return control
    }()

    private let bathroomRatingLabel: UILabel = {
        let label = UILabel()
        label.text = "Bathroom Rating (1–5)"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()

    private let bathroomRatingControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["1","2","3","4","5"])
        control.selectedSegmentIndex = 3 // default to 4
        return control
    }()


    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Bathroom Info"
        view.backgroundColor = .systemBackground
        
        setupNavigationBar()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))
    }

    private func setupUI() {
        let isUnisexStackView = UIStackView(arrangedSubviews: [isUnisexLabel, isUnisexSwitch])
        isUnisexStackView.axis = .horizontal
        isUnisexStackView.distribution = .fill
        
        let stackView = UIStackView(arrangedSubviews: [
            nameLabel, nameTextField,
            codeLabel, codeTextField,
            isUnisexStackView,
            cleanRatingLabel, cleanRatingControl,
            bathroomRatingLabel, bathroomRatingControl,
            notesLabel, notesTextView
        ])
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Custom spacing after key rows
        stackView.setCustomSpacing(20, after: isUnisexStackView)
        stackView.setCustomSpacing(16, after: cleanRatingControl)
        stackView.setCustomSpacing(16, after: bathroomRatingControl)
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            notesTextView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    // MARK: - Actions
    @objc private func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func saveTapped() {
        do {
            let newBathroom = try viewModel.createBathroomAnnotation(
                name: nameTextField.text,
                code: codeTextField.text,
                notes: notesTextView.text,
                isUnisex: isUnisexSwitch.isOn,
                cleanRating: cleanRatingControl.selectedSegmentIndex + 1,
                bathroomRating: bathroomRatingControl.selectedSegmentIndex + 1,
                coordinate: coordinate
            )
            
            // Call the closure to pass the new, validated object back
            onSave?(newBathroom)
            
            dismiss(animated: true, completion: nil)
            
        } catch {
            let alert = UIAlertController(title: "Error",
                                          message: error.localizedDescription,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}

