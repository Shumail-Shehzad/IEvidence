import UIKit

class CreateCaseViewController: UIViewController {

    // MARK: - UI Components

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    private let headingLabel = UILabel()

    private let caseNumberField = UITextField()
    private let firNumberField = UITextField()
    private let caseTitleField = UITextField()
    private let crimeTypeField = UITextField()

    private let descriptionView = UITextView()

    private let incidentDatePicker = UIDatePicker()

    private let saveButton = UIButton(type: .system)

    private let crimeTypes = [
        "Cybercrime",
        "Digital Fraud",
        "Theft",
        "Harassment",
        "Missing Person",
        "Other"
    ]

    private let crimePicker = UIPickerView()

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupScreen()
        setupUI()
        setupConstraints()
        setupKeyboardDismiss()
    }
    // MARK: - Keyboard Dismiss

    private func setupKeyboardDismiss() {

        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )

        tapGesture.cancelsTouchesInView = false

        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Screen Setup

    private func setupScreen() {

        view.backgroundColor = .systemGroupedBackground
        title = "Create New Case"

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeScreen)
        )
    }

    // MARK: - UI Setup

    private func setupUI() {

        // Scroll View
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        // Stack View
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(stackView)

        // Heading
        headingLabel.text = "Case Information"
        headingLabel.font = .systemFont(
            ofSize: 25,
            weight: .bold
        )

        // Text Fields
        configureField(
            caseNumberField,
            placeholder: "Enter Case Number"
        )

        configureField(
            firNumberField,
            placeholder: "Enter FIR Number"
        )

        configureField(
            caseTitleField,
            placeholder: "Enter Case Title"
        )

        configureField(
            crimeTypeField,
            placeholder: "Select Crime Type"
        )

        // Crime Type Picker
        crimePicker.delegate = self
        crimePicker.dataSource = self

        crimeTypeField.inputView = crimePicker

        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        toolbar.items = [
            UIBarButtonItem(
                barButtonSystemItem: .flexibleSpace,
                target: nil,
                action: nil
            ),
            UIBarButtonItem(
                title: "Done",
                style: .done,
                target: self,
                action: #selector(dismissCrimePicker)
            )
        ]

        crimeTypeField.inputAccessoryView = toolbar

        // Description
        descriptionView.font = .systemFont(ofSize: 16)
        descriptionView.backgroundColor = .secondarySystemGroupedBackground
        descriptionView.layer.cornerRadius = 10
        descriptionView.layer.borderWidth = 0.5
        descriptionView.layer.borderColor = UIColor.separator.cgColor

        // Incident Date
        incidentDatePicker.datePickerMode = .date
        incidentDatePicker.preferredDatePickerStyle = .compact

        // Save Button
        saveButton.setTitle("Save Case", for: .normal)
        saveButton.titleLabel?.font = .systemFont(
            ofSize: 17,
            weight: .semibold
        )
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = .systemBlue
        saveButton.layer.cornerRadius = 12

        saveButton.addTarget(
            self,
            action: #selector(saveCaseTapped),
            for: .touchUpInside
        )

        // Add Components
        addField(title: "Case Number", field: caseNumberField)
        addField(title: "FIR Number", field: firNumberField)
        addField(title: "Case Title", field: caseTitleField)
        addField(title: "Crime Type", field: crimeTypeField)

        let descriptionLabel = makeLabel("Case Description")

        stackView.addArrangedSubview(descriptionLabel)
        stackView.addArrangedSubview(descriptionView)

        let dateLabel = makeLabel("Incident Date")

        stackView.addArrangedSubview(dateLabel)
        stackView.addArrangedSubview(incidentDatePicker)

        stackView.addArrangedSubview(saveButton)
    }

    // MARK: - Helper Methods

    private func configureField(
        _ field: UITextField,
        placeholder: String
    ) {

        field.placeholder = placeholder
        field.borderStyle = .roundedRect
        field.backgroundColor = .secondarySystemGroupedBackground
        field.font = .systemFont(ofSize: 16)
        field.autocorrectionType = .no
        field.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    private func makeLabel(_ title: String) -> UILabel {

        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 15, weight: .semibold)

        return label
    }

    private func addField(
        title: String,
        field: UITextField
    ) {

        stackView.addArrangedSubview(makeLabel(title))
        stackView.addArrangedSubview(field)
    }

    // MARK: - Auto Layout

    private func setupConstraints() {

        NSLayoutConstraint.activate([

            scrollView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            scrollView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            scrollView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            scrollView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            ),

            stackView.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor,
                constant: 25
            ),
            stackView.leadingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.leadingAnchor,
                constant: 20
            ),
            stackView.trailingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.trailingAnchor,
                constant: -20
            ),
            stackView.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor,
                constant: -25
            ),
            stackView.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor,
                constant: -40
            ),

            descriptionView.heightAnchor.constraint(
                equalToConstant: 120
            ),

            saveButton.heightAnchor.constraint(
                equalToConstant: 55
            )
        ])
    }

    // MARK: - Button Actions

    @objc private func dismissCrimePicker() {
        view.endEditing(true)
    }

    @objc private func closeScreen() {
        dismiss(animated: true)
    }

    @objc private func saveCaseTapped() {

        let caseNumber = caseNumberField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let firNumber = firNumberField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let caseTitle = caseTitleField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let crimeType = crimeTypeField.text ?? ""

        let caseDescription = descriptionView.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !caseNumber.isEmpty else {
            showMessage("Please enter the case number.")
            return
        }

        guard !firNumber.isEmpty else {
            showMessage("Please enter the FIR number.")
            return
        }

        guard !caseTitle.isEmpty else {
            showMessage("Please enter the case title.")
            return
        }

        guard !crimeType.isEmpty else {
            showMessage("Please select a crime type.")
            return
        }

        // Create Case Object

        let newCase = CaseModel(
            caseNumber: caseNumber,
            firNumber: firNumber,
            caseTitle: caseTitle,
            crimeType: crimeType,
            caseDescription: caseDescription,
            incidentDate: incidentDatePicker.date,
            status: "Active"
        )

        // Save Case

        CaseStorage.shared.saveCase(newCase)

        // Show Confirmation

        let alert = UIAlertController(
            title: "Case Saved",
            message: "Your case has been saved successfully.",
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: "OK", style: .default) { _ in
                self.dismiss(animated: true)
            }
        )

        present(alert, animated: true)
    }

    private func showMessage(_ message: String) {

        let alert = UIAlertController(
            title: "Missing Information",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: "OK", style: .default)
        )

        present(alert, animated: true)
    }
}


// MARK: - Crime Type Picker

extension CreateCaseViewController:
    UIPickerViewDelegate,
    UIPickerViewDataSource {

    func numberOfComponents(
        in pickerView: UIPickerView
    ) -> Int {
        return 1
    }

    func pickerView(
        _ pickerView: UIPickerView,
        numberOfRowsInComponent component: Int
    ) -> Int {
        return crimeTypes.count
    }

    func pickerView(
        _ pickerView: UIPickerView,
        titleForRow row: Int,
        forComponent component: Int
    ) -> String? {
        return crimeTypes[row]
    }

    func pickerView(
        _ pickerView: UIPickerView,
        didSelectRow row: Int,
        inComponent component: Int
    ) {
        crimeTypeField.text = crimeTypes[row]
    }
}
