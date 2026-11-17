import UIKit
import PhotosUI
import UniformTypeIdentifiers
import CoreLocation
import MapKit



class EvidenceViewController: UIViewController {

    // MARK: - Properties

    var caseNumber: String = ""

    private var evidenceList: [EvidenceModel] = []
    private let searchController = UISearchController(
        searchResultsController: nil
    )

    private var filteredEvidence: [EvidenceModel] = []

    private let tableView = UITableView()

    private let emptyLabel = UILabel()

    private var selectedFileURL: URL?
    
    private let locationManager = CLLocationManager()
    
    private var currentLocation: CLLocation?

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupScreen()
        setupUI()
        setupConstraints()
        loadEvidence()
        setupSearchController()
        setupLocationManager()
    }

    // MARK: - Screen Setup

   
    private func setupScreen() {

        view.backgroundColor = .systemGroupedBackground

        title = "Case Evidence"

        // Add Evidence button
        let addButton = UIBarButtonItem(
            title: "Add Evidence",
            style: .plain,
            target: self,
            action: #selector(addEvidenceTapped)
        )

        // Evidence History button
        let historyButton = UIBarButtonItem(
            title: "History",
            style: .plain,
            target: self,
            action: #selector(historyTapped)
        )

        navigationItem.rightBarButtonItems = [
            addButton,
            historyButton
        ]
    }
    
    private func setupLocationManager() {

        locationManager.delegate = self

        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        locationManager.requestWhenInUseAuthorization()
    }

    // MARK: - UI Setup

    private func setupUI() {

        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "EvidenceCell"
        )

        tableView.backgroundColor = .clear

        view.addSubview(tableView)

        emptyLabel.text = "No evidence added yet."
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.textAlignment = .center
        emptyLabel.font = .systemFont(ofSize: 16)
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(emptyLabel)
    }

    // MARK: - Constraints

    private func setupConstraints() {

        NSLayoutConstraint.activate([

            tableView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            tableView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),

            emptyLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            emptyLabel.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            )
        ])
    }

    // MARK: - Load Evidence

    private func loadEvidence() {

        evidenceList = EvidenceStorage.shared.fetchEvidence(
            for: caseNumber
        )

        emptyLabel.isHidden = !evidenceList.isEmpty

        tableView.reloadData()
    }
    
    // MARK: - Open Evidence History

    @objc private func historyTapped() {

        let historyVC = EvidenceHistoryViewController()

        historyVC.caseNumber = caseNumber

        navigationController?.pushViewController(
            historyVC,
            animated: true
        )
    }


    // MARK: - Add Evidence

  
    @objc private func addEvidenceTapped() {

        let alert = UIAlertController(
            title: "Add Evidence",
            message: "Select the type of evidence you want to import.",
            preferredStyle: .actionSheet
        )

        alert.addAction(
            UIAlertAction(title: "Photo", style: .default) { _ in
                self.openPhotoPicker()
            }
        )

        alert.addAction(
            UIAlertAction(title: "Video", style: .default) { _ in
                self.openVideoPicker()
            }
        )

        alert.addAction(
            UIAlertAction(title: "PDF Document", style: .default) { _ in
                self.openDocumentPicker()
            }
        )

        alert.addAction(
            UIAlertAction(title: "Cancel", style: .cancel)
        )

        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }

        present(alert, animated: true)
    }


    // MARK: - Description Alert

    private func showDescriptionAlert(for fileURL: URL) {

        let alert = UIAlertController(
            title: "Evidence Description",
            message: "Enter a description for this image.",
            preferredStyle: .alert
        )

        alert.addTextField { textField in

            textField.placeholder = "Example: Photograph of recovered item"

        }

        alert.addAction(
            UIAlertAction(title: "Cancel", style: .cancel)
        )

        alert.addAction(
            UIAlertAction(title: "Save Evidence", style: .default) {
                [weak self] _ in

                guard let self = self else { return }

                let description = alert.textFields?.first?.text?
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ) ?? ""

                guard !description.isEmpty else {

                    self.showMessage(
                        "Please enter an evidence description."
                    )

                    return
                }

                self.saveEvidence(
                    fileURL: fileURL,
                    description: description
                )
            }
        )

        present(alert, animated: true)
    }

    // MARK: - Save Evidence

    private func saveEvidence(
        fileURL: URL,
        description: String
    ) {

        do {

            let location = currentLocation

            let evidence = try EvidenceStorage.shared.importEvidenceFile(
                from: fileURL,
                caseNumber: caseNumber,
                description: description,
                latitude: location?.coordinate.latitude,
                longitude: location?.coordinate.longitude,
                horizontalAccuracy: location?.horizontalAccuracy
            )
                
            ChainOfCustodyStorage.shared.recordEvent(
                evidence: evidence,
                action: "Evidence Added",
                performedBy: "Investigator",
                details: "Evidence was imported into the case."
            )

            print("Evidence hash: \(evidence.sha256Hash)")

            loadEvidence()

            showMessage("Evidence imported and SHA-256 hash generated.")

        } catch {

            showMessage(
                "Could not save evidence: \(error.localizedDescription)"
            )
        }
    }

    // MARK: - Alert

    private func showMessage(_ message: String) {

        let alert = UIAlertController(
            title: "iEvidence",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: "OK", style: .default)
        )

        present(alert, animated: true)
    }
}

// MARK: - Photo Picker Delegate

extension EvidenceViewController: PHPickerViewControllerDelegate {
    
    
    func picker(
        _ picker: PHPickerViewController,
        didFinishPicking results: [PHPickerResult]
    ) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else {
            return
        }
        
        let typeIdentifier: String
        let evidenceType: String
        
        if result.itemProvider.hasItemConformingToTypeIdentifier(
            UTType.image.identifier
        ) {
            typeIdentifier = UTType.image.identifier
            evidenceType = "Image"
            
        } else if result.itemProvider.hasItemConformingToTypeIdentifier(
            UTType.movie.identifier
        ) {
            typeIdentifier = UTType.movie.identifier
            evidenceType = "Video"
            
        } else {
            showMessage("Unsupported evidence file.")
            return
        }
        
        result.itemProvider.loadFileRepresentation(
            forTypeIdentifier: typeIdentifier
        ) { [weak self] url, error in
            
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.showMessage(
                        "\(evidenceType) import failed: \(error.localizedDescription)"
                    )
                }
                return
            }
            
            guard let url = url else {
                DispatchQueue.main.async {
                    self.showMessage("Could not access the selected file.")
                }
                return
            }
            
            let temporaryURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension(url.pathExtension)
            
            do {
                try FileManager.default.copyItem(
                    at: url,
                    to: temporaryURL
                )
                
                DispatchQueue.main.async {
                    self.showDescriptionAlert(for: temporaryURL)
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.showMessage(
                        "Could not prepare \(evidenceType.lowercased()): \(error.localizedDescription)"
                    )
                }
            }
        }
    }
}
extension EvidenceViewController: UIDocumentPickerDelegate {
    
    
    func documentPicker(
        _ controller: UIDocumentPickerViewController,
        didPickDocumentsAt urls: [URL]
    ) {
        guard let selectedURL = urls.first else {
            return
        }
        
        let accessGranted = selectedURL.startAccessingSecurityScopedResource()
        defer {
            if accessGranted {
                selectedURL.stopAccessingSecurityScopedResource()
            }
        }
        
        let temporaryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(selectedURL.pathExtension)
        
        do {
            try FileManager.default.copyItem(
                at: selectedURL,
                to: temporaryURL
            )
        } catch {
            let errorAlert = UIAlertController(
                title: "Import Failed",
                message: error.localizedDescription,
                preferredStyle: .alert
            )

            errorAlert.addAction(
                UIAlertAction(title: "OK", style: .default)
            )

            present(errorAlert, animated: true)
            return
        }
        
        let alert = UIAlertController(
            title: "Evidence Description",
            message: "Enter a description for this PDF.",
            preferredStyle: .alert
        )
        
        alert.addTextField {
            $0.placeholder = "Enter description"
        }
        
        alert.addAction(
            UIAlertAction(title: "Cancel", style: .cancel) { _ in
                try? FileManager.default.removeItem(at: temporaryURL)
            }
        )
        
        alert.addAction(
            UIAlertAction(title: "Save", style: .default) { _ in
                let description = alert.textFields?.first?.text ?? ""
                
                self.saveEvidence(
                    fileURL: temporaryURL,
                    description: description
                )
                
                try? FileManager.default.removeItem(at: temporaryURL)
            }
        )
        
        present(alert, animated: true)
    }
}

// MARK: - Table View

extension EvidenceViewController:
    UITableViewDataSource,
    UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {

        if searchController.isActive {
            return filteredEvidence.count
        }

        return evidenceList.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "EvidenceCell",
            for: indexPath
        )

        let evidence: EvidenceModel

        if searchController.isActive {
            evidence = filteredEvidence[indexPath.row]
        } else {
            evidence = evidenceList[indexPath.row]
        }

        var content = cell.defaultContentConfiguration()
        
        switch evidence.evidenceType {

        case "Image":
            content.image = UIImage(systemName: "photo.fill")

        case "Video":
            content.image = UIImage(systemName: "video.fill")

        case "PDF Document":
            content.image = UIImage(systemName: "doc.fill")

        default:
            content.image = UIImage(systemName: "doc")
        }

        content.imageProperties.tintColor = .systemBlue
        content.imageProperties.preferredSymbolConfiguration =
            UIImage.SymbolConfiguration(pointSize: 24)
        
        content.text = evidence.evidenceDescription

        content.secondaryText = """
        Type: \(evidence.evidenceType)
        File: \(evidence.fileName)
        SHA-256: \(evidence.sha256Hash)
        """

        content.secondaryTextProperties.numberOfLines = 4

        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator

        return cell
    }
    
    // MARK: - Verify Evidence When Tapped

   
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {

        tableView.deselectRow(at: indexPath, animated: true)

        let selectedEvidence: EvidenceModel

        if searchController.isActive {
            selectedEvidence = filteredEvidence[indexPath.row]
        } else {
            selectedEvidence = evidenceList[indexPath.row]
        }

        // Require biometric or device passcode authentication
        BiometricAuth.shared.authenticate { [weak self] success, error in

            guard let self = self else { return }

            guard success else {

                let alert = UIAlertController(
                    title: "Authentication Failed",
                    message: error ?? "You are not authorized to access this evidence.",
                    preferredStyle: .alert
                )

                alert.addAction(
                    UIAlertAction(title: "OK", style: .default)
                )

                self.present(alert, animated: true)

                return
            }

            // Open Evidence Details after successful authentication
            let detailVC = EvidenceDetailViewController()
            detailVC.evidence = selectedEvidence

            self.navigationController?.pushViewController(
                detailVC,
                animated: true
            )
        }
    }


    // MARK: - Verification Result Alert

    private func showVerificationResult(
        title: String,
        message: String,
        isVerified: Bool
    ) {

        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: "OK", style: .default)
        )

        present(alert, animated: true)
    }
}
extension EvidenceViewController: UISearchResultsUpdating {

    func updateSearchResults(
        for searchController: UISearchController
    ) {
        let searchText = searchController.searchBar.text ?? ""

        if searchText.isEmpty {
            filteredEvidence = evidenceList
        } else {
            filteredEvidence = evidenceList.filter { evidence in
                evidence.fileName.localizedCaseInsensitiveContains(searchText) ||
                evidence.evidenceDescription.localizedCaseInsensitiveContains(searchText)
            }
        }

        tableView.reloadData()
    }
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search evidence..."

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        definesPresentationContext = true
    }
    private func openPhotoPicker() {
        var configuration = PHPickerConfiguration(
            photoLibrary: .shared()
        )

        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(
            configuration: configuration
        )

        picker.delegate = self
        present(picker, animated: true)
    }
    private func openVideoPicker() {

        var configuration = PHPickerConfiguration(
            photoLibrary: .shared()
        )

        configuration.filter = .videos
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(
            configuration: configuration
        )

        picker.delegate = self
        present(picker, animated: true)
    }
    private func openDocumentPicker() {

        let documentPicker = UIDocumentPickerViewController(
            forOpeningContentTypes: [.pdf],
            asCopy: true
        )

        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false

        present(documentPicker, animated: true)
    }
}

extension EvidenceViewController: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager
    ) {
        switch manager.authorizationStatus {

        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()

        case .denied, .restricted:
            print("Location permission denied")

        case .notDetermined:
            break

        @unknown default:
            break
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        currentLocation = locations.last

        if let location = currentLocation {
            print("Latitude: \(location.coordinate.latitude)")
            print("Longitude: \(location.coordinate.longitude)")
            print("Accuracy: \(location.horizontalAccuracy)")
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        print("Location error: \(error.localizedDescription)")
    }
}
