import UIKit
import CoreLocation

// This view controller shows the form to add a new pin.
class AddPinViewController: UIViewController {

    // MARK: - Properties
    var onSave: ((Bathroom) -> Void)?
    var viewModel = AddPinViewModel()
    
    // MARK: - UI Elements
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Location Name:"
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }()
    
    private let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "e.g., Starbucks on Main St"
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    private let codeLabel: UILabel = {
        let label = UILabel()
        label.text = "Bathroom Code:"
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }()
    
    private let codeTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "e.g., 12345 (optional)"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .numberPad
        return tf
    }()

    private let notesLabel: UILabel = {
        let label = UILabel()
        label.text = "Notes:"
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }()
    
    private let notesTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "e.g., 3rd floor, ask barista (optional)"
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    private let unisexLabel: UILabel = {
        let label = UILabel()
        label.text = "Unisex:"
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }()
    
    private let unisexSwitch: UISwitch = {
        let sw = UISwitch()
        return sw
    }()

    private let mainStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 16
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // --- FIX for Constraint Warning ---
        // By setting navigationItem.title instead of self.title,
        // we avoid the layout conflict.
        self.navigationItem.title = "Add New Bathroom"
        // --- End of Fix ---
        
        // --- Navigation Bar ---
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonTapped))
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
        self.navigationItem.rightBarButtonItem = saveButton
        self.navigationItem.leftBarButtonItem = cancelButton
        
        // --- Stack View ---
        let unisexStack = UIStackView(arrangedSubviews: [unisexLabel, UIView(), unisexSwitch])
        unisexStack.axis = .horizontal
        unisexStack.alignment = .center
        
        mainStackView.addArrangedSubview(nameLabel)
        mainStackView.addArrangedSubview(nameTextField)
        mainStackView.addArrangedSubview(codeLabel)
        mainStackView.addArrangedSubview(codeTextField)
        mainStackView.addArrangedSubview(notesLabel)
        mainStackView.addArrangedSubview(notesTextField)
        mainStackView.addArrangedSubview(unisexStack)
        
        view.addSubview(mainStackView)
        
        // --- Constraints ---
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func saveButtonTapped() {
        do {
            // Use the ViewModel to create the new Bathroom object
            let newBathroom = try viewModel.createBathroom(
                name: nameTextField.text,
                code: codeTextField.text,
                notes: notesTextField.text,
                isUnisex: unisexSwitch.isOn
            )
            
            // Pass the new object back to the map
            onSave?(newBathroom)
            dismiss(animated: true)
            
        } catch AddPinViewModel.ValidationError.missingName {
            showAlert(title: "Missing Name", message: "Please enter a name for this location.")
        } catch {
            showAlert(title: "Error", message: "Could not create new bathroom.")
        }
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

