
import UIKit
import QuickLook
import CoreImage
import CoreImage.CIFilterBuiltins
import AVFoundation
import MapKit

class EvidenceDetailViewController: UIViewController {

    var evidence: EvidenceModel!

    private let detailsLabel = UILabel()
    private let verifyButton = UIButton(type: .system)
    private let shareButton = UIButton(type: .system)
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let copyHashButton = UIButton(type: .system)
    private let previewButton = UIButton(type: .system)
    private let qrCodeButton = UIButton(type: .system)
    private let scanQRButton = UIButton(type: .system)
    private let viewLocationButton = UIButton(type: .system)
    private let copyLocationButton = UIButton(type: .system)
    private let integrityStatusLabel = UILabel()
    private let context = CIContext()
    private let qrFilter = CIFilter.qrCodeGenerator()
    private var generatedQRImage: UIImage?
    private var decryptedPreviewURL: URL?
    private var decryptedShareURL: URL?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setupScreen()
        setupUI()
        displayEvidenceDetails()
    }

    private func setupScreen() {
        view.backgroundColor = .systemGroupedBackground
        title = "Evidence Details"
    }

    private func setupUI() {
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        detailsLabel.numberOfLines = 0
        detailsLabel.font = .systemFont(ofSize: 16)
        detailsLabel.backgroundColor = .secondarySystemGroupedBackground
        detailsLabel.layer.cornerRadius = 12
        detailsLabel.clipsToBounds = true
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false

        verifyButton.setTitle("Verify Integrity", for: .normal)
        verifyButton.backgroundColor = .systemGreen
        verifyButton.setTitleColor(.white, for: .normal)
        verifyButton.layer.cornerRadius = 10
        verifyButton.addTarget(
            self,
            action: #selector(verifyTapped),
            for: .touchUpInside
        )

        shareButton.setTitle("Share / Export Evidence", for: .normal)
        shareButton.backgroundColor = .systemBlue
        shareButton.setTitleColor(.white, for: .normal)
        shareButton.layer.cornerRadius = 10
        shareButton.addTarget(
            self,
            action: #selector(shareTapped),
            for: .touchUpInside
        )

        let stackView = UIStackView(
            arrangedSubviews: [
                detailsLabel,
                integrityStatusLabel,
                previewButton,
                copyHashButton,
                qrCodeButton,
                scanQRButton,
                verifyButton,
                shareButton
            ]
        )

        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(viewLocationButton)
        stackView.addArrangedSubview(copyLocationButton)

        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([

            // Scroll View
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

            // Content View
            contentView.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor
            ),
            contentView.leadingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.leadingAnchor
            ),
            contentView.trailingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.trailingAnchor
            ),
            contentView.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor
            ),
            contentView.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor
            ),

            // Stack View
            stackView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 25
            ),
            stackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 20
            ),
            stackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -20
            ),
            stackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -25
            ),

            // Buttons
            previewButton.heightAnchor.constraint(equalToConstant: 50),
            copyHashButton.heightAnchor.constraint(equalToConstant: 50),
            verifyButton.heightAnchor.constraint(equalToConstant: 50),
            shareButton.heightAnchor.constraint(equalToConstant: 50),
            qrCodeButton.heightAnchor.constraint(equalToConstant: 50),
            scanQRButton.heightAnchor.constraint(equalToConstant: 50),
            viewLocationButton.heightAnchor.constraint(equalToConstant: 50),
            copyLocationButton.heightAnchor.constraint(equalToConstant: 50),
            integrityStatusLabel.heightAnchor.constraint(
                greaterThanOrEqualToConstant: 45
                
            ),
        ])
        previewButton.setTitle("Preview Evidence", for: .normal)
        previewButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        previewButton.backgroundColor = .systemBlue
        previewButton.setTitleColor(.white, for: .normal)
        previewButton.layer.cornerRadius = 10
        

        previewButton.addTarget(
            self,
            action: #selector(previewTapped),
            for: .touchUpInside
        )
        copyHashButton.setTitle("Copy SHA-256 Hash", for: .normal)
        copyHashButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        copyHashButton.backgroundColor = .systemIndigo
        copyHashButton.setTitleColor(.white, for: .normal)
        copyHashButton.layer.cornerRadius = 10

        copyHashButton.addTarget(
            self,
            action: #selector(copyHashTapped),
            for: .touchUpInside
        )
        integrityStatusLabel.font = .boldSystemFont(ofSize: 16)
        integrityStatusLabel.textAlignment = .center
        integrityStatusLabel.text = "Integrity: Not Checked"
        integrityStatusLabel.textColor = .secondaryLabel
        integrityStatusLabel.numberOfLines = 0
        integrityStatusLabel.backgroundColor = .secondarySystemGroupedBackground
        integrityStatusLabel.layer.cornerRadius = 10
        integrityStatusLabel.clipsToBounds = true
        integrityStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        qrCodeButton.setTitle("Generate QR Code", for: .normal)
        qrCodeButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        qrCodeButton.backgroundColor = .systemTeal
        qrCodeButton.setTitleColor(.white, for: .normal)
        qrCodeButton.layer.cornerRadius = 10

        qrCodeButton.addTarget(
            self,
            action: #selector(qrCodeTapped),
            for: .touchUpInside
        )
        scanQRButton.setTitle("Scan QR Code", for: .normal)
        scanQRButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        scanQRButton.backgroundColor = .systemOrange
        scanQRButton.setTitleColor(.white, for: .normal)
        scanQRButton.layer.cornerRadius = 10

        scanQRButton.addTarget(
            self,
            action: #selector(scanQRTapped),
            for: .touchUpInside
        )
        viewLocationButton.setTitle("View Location on Map", for: .normal)
        viewLocationButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        viewLocationButton.backgroundColor = .systemGreen
        viewLocationButton.setTitleColor(.white, for: .normal)
        viewLocationButton.layer.cornerRadius = 10

        viewLocationButton.addTarget(
            self,
            action: #selector(viewLocationTapped),
            for: .touchUpInside
        )
        copyLocationButton.setTitle("Copy GPS Coordinates", for: .normal)
        copyLocationButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        copyLocationButton.backgroundColor = .systemIndigo
        copyLocationButton.setTitleColor(.white, for: .normal)
        copyLocationButton.layer.cornerRadius = 10

        copyLocationButton.addTarget(
            self,
            action: #selector(copyLocationTapped),
            for: .touchUpInside
        )
    }
    @objc private func scanQRTapped() {

        let scannerVC = QRCodeScannerViewController()

        navigationController?.pushViewController(
            scannerVC,
            animated: true
        )
    }
    

    
    private func displayEvidenceDetails() {
        
        let utcFormatter = ISO8601DateFormatter()

        let utcCollectionDate = utcFormatter.string(
            from: evidence.dateCollected
        )
        
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .medium
        formatter.timeZone = .current

        // File size
        let fileURL = EvidenceStorage.shared.fileURL(for: evidence)

        var fileSizeText = "Unavailable"

        if let attributes = try? FileManager.default.attributesOfItem(
            atPath: fileURL.path
        ),
        let fileSize = attributes[.size] as? Int64 {

            let fileSizeInMB = Double(fileSize) / (1024 * 1024)
            fileSizeText = String(format: "%.2f MB", fileSizeInMB)
        }

        // GPS information
        var locationText = "GPS Location: Not Available"

        if let latitude = evidence.latitude,
           let longitude = evidence.longitude {

            let accuracy = evidence.horizontalAccuracy ?? 0

            locationText = """
            GPS Location:
            Latitude: \(latitude)
            Longitude: \(longitude)
            Accuracy: \(accuracy) meters
            """
        }

        // Device information
        let deviceText = """
        Device Name: \(evidence.deviceName ?? "Not Available")
        iOS Version: \(evidence.iOSVersion ?? "Not Available")
        App Version: \(evidence.appVersion ?? "Not Available")
        """

        // Display all evidence information
        detailsLabel.text = """
        File Name:
        \(evidence.fileName)

        Evidence Type:
        \(evidence.evidenceType)

        File Size:
        \(fileSizeText)

        Description:
        \(evidence.evidenceDescription)

        Case Number:
        \(evidence.caseNumber)
        
        Collection Date (Local Time):
        \(formatter.string(from: evidence.dateCollected))

        Collection Date (UTC):
        \(utcCollectionDate)

        \(locationText)

        \(deviceText)

        SHA-256 Hash:
        \(evidence.sha256Hash)
        """

        detailsLabel.setContentHuggingPriority(
            .defaultLow,
            for: .vertical
        )
    }

    @objc private func verifyTapped() {

        do {

            let isValid = try EvidenceStorage.shared.verifyIntegrity(
                of: evidence
            )

            // Update Integrity Status Label
            if isValid {
                integrityStatusLabel.text = "✓ Integrity: Verified"
                integrityStatusLabel.textColor = .systemGreen
            } else {
                integrityStatusLabel.text = "✕ Integrity: Check Failed"
                integrityStatusLabel.textColor = .systemRed
            }

            let action = isValid
                ? "Evidence Verified"
                : "Integrity Check Failed"

            let details = isValid
                ? "SHA-256 integrity verification passed."
                : "SHA-256 integrity verification failed."

            ChainOfCustodyStorage.shared.recordEvent(
                evidence: evidence,
                action: action,
                performedBy: "Investigator",
                details: details
            )

            showAlert(
                title: isValid ? "Evidence Verified" : "Integrity Failed",
                message: isValid
                    ? "Evidence integrity verified successfully."
                    : "Evidence file has been modified."
            )

        } catch {

            integrityStatusLabel.text = "✕ Integrity: Verification Error"
            integrityStatusLabel.textColor = .systemRed

            showAlert(
                title: "Verification Error",
                message: error.localizedDescription
            )
        }
    }
  
   
    @objc private func shareTapped() {

        // Authenticate before exporting evidence
        BiometricAuth.shared.authenticate { [weak self] success, error in

            guard let self = self else { return }

            guard success else {

                self.showAlert(
                    title: "Authentication Required",
                    message: error ?? "Authentication failed. Evidence export is blocked."
                )

                return
            }

            do {

                // Verify evidence integrity
                let isVerified = try EvidenceStorage.shared.verifyIntegrity(
                    of: self.evidence
                )

                guard isVerified else {

                    ChainOfCustodyStorage.shared.recordEvent(
                        evidence: self.evidence,
                        action: "Evidence Export Blocked",
                        performedBy: "Investigator",
                        details: "SHA-256 verification failed. Export was blocked."
                    )

                    self.showAlert(
                        title: "Integrity Check Failed",
                        message: "This evidence may have been modified. Export is blocked."
                    )

                    return
                }

                // Create decrypted temporary evidence file
                let decryptedURL = try EvidenceStorage.shared.decryptedFileURL(
                    for: self.evidence
                )

                self.decryptedShareURL = decryptedURL

                // Record export request
                ChainOfCustodyStorage.shared.recordEvent(
                    evidence: self.evidence,
                    action: "Evidence Export Requested",
                    performedBy: "Investigator",
                    details: "Authentication and SHA-256 verification passed before export."
                )

                // Share decrypted evidence
                let activityVC = UIActivityViewController(
                    activityItems: [decryptedURL],
                    applicationActivities: nil
                )

                if let popover = activityVC.popoverPresentationController {
                    popover.sourceView = self.shareButton
                    popover.sourceRect = self.shareButton.bounds
                }

                activityVC.completionWithItemsHandler = {
                    activityType,
                    completed,
                    returnedItems,
                    error in

                    let action = completed
                        ? "Evidence Export Completed"
                        : "Evidence Export Cancelled"

                    let details = error?.localizedDescription
                        ?? (completed
                            ? "Evidence was successfully exported."
                            : "The investigator cancelled the export.")

                    // Record export result
                    ChainOfCustodyStorage.shared.recordEvent(
                        evidence: self.evidence,
                        action: action,
                        performedBy: "Investigator",
                        details: details
                    )

                    // Delete temporary decrypted file
                    if let url = self.decryptedShareURL {

                        try? FileManager.default.removeItem(at: url)

                        self.decryptedShareURL = nil
                    }
                }

                self.present(activityVC, animated: true)

            } catch {

                self.showAlert(
                    title: "Export Error",
                    message: error.localizedDescription
                )
            }
        }
    }

    private func showAlert(title: String, message: String) {

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
   
   
    @objc private func previewTapped() {

        // Authenticate before previewing evidence
        BiometricAuth.shared.authenticate { [weak self] success, error in

            guard let self = self else { return }

            guard success else {

                self.showAlert(
                    title: "Authentication Required",
                    message: error ?? "Authentication failed. Evidence preview is blocked."
                )

                return
            }

            // Verify evidence integrity
            do {

                let isValid = try EvidenceStorage.shared.verifyIntegrity(
                    of: self.evidence
                )

                guard isValid else {

                    self.integrityStatusLabel.text = "✕ Integrity: Check Failed"
                    self.integrityStatusLabel.textColor = .systemRed

                    ChainOfCustodyStorage.shared.recordEvent(
                        evidence: self.evidence,
                        action: "Preview Blocked",
                        performedBy: "Investigator",
                        details: "SHA-256 verification failed. Preview was blocked."
                    )

                    self.showAlert(
                        title: "Integrity Check Failed",
                        message: "This evidence may have been modified. Preview is blocked."
                    )

                    return
                }

                // Update integrity status
                self.integrityStatusLabel.text = "✓ Integrity: Verified"
                self.integrityStatusLabel.textColor = .systemGreen

                // Create decrypted temporary file
                let previewURL = try EvidenceStorage.shared.decryptedFileURL(
                    for: self.evidence
                )

                self.decryptedPreviewURL = previewURL

                // Record preview event
                ChainOfCustodyStorage.shared.recordEvent(
                    evidence: self.evidence,
                    action: "Evidence Previewed",
                    performedBy: "Investigator",
                    details: "Authentication and SHA-256 verification passed before preview."
                )

                // Open decrypted evidence
                let previewController = QLPreviewController()
                previewController.dataSource = self
                previewController.delegate = self

                self.present(previewController, animated: true)

            } catch {

                self.integrityStatusLabel.text = "✕ Integrity: Verification Error"
                self.integrityStatusLabel.textColor = .systemRed

                self.showAlert(
                    title: "Preview Error",
                    message: error.localizedDescription
                )
            }
        }
    }


    
    @objc private func copyHashTapped() {

        BiometricAuth.shared.authenticate { [weak self] success, error in

            guard let self = self else { return }

            guard success else {
                self.showAlert(
                    title: "Authentication Failed",
                    message: error ?? "Authentication is required to copy the evidence hash."
                )
                return
            }

            UIPasteboard.general.string = self.evidence.sha256Hash

            ChainOfCustodyStorage.shared.recordEvent(
                evidence: self.evidence,
                action: "Evidence Hash Copied",
                performedBy: "Investigator",
                details: "SHA-256 hash copied to clipboard."
            )

            self.showAlert(
                title: "Hash Copied",
                message: "SHA-256 hash copied successfully."
            )
        }
    }

    
    
    @objc private func qrCodeTapped() {
        
        BiometricAuth.shared.authenticate { [weak self] success, error in
            
            guard let self = self else { return }
            
            guard success else {
                self.showAlert(
                    title: "Authentication Failed",
                    message: error ?? "You are not authorized to generate the QR code."
                )
                return
            }
            
            let latitudeText = self.evidence.latitude.map { String($0) } ?? "N/A"
            let longitudeText = self.evidence.longitude.map { String($0) } ?? "N/A"
            let accuracyText = self.evidence.horizontalAccuracy.map { String($0) } ?? "N/A"
            
            let utcFormatter = ISO8601DateFormatter()
            let utcCollectionDate = utcFormatter.string(
                from: self.evidence.dateCollected
            )
            
            let qrData = """
            Evidence ID: \(self.evidence.id)
            Case Number: \(self.evidence.caseNumber)
            SHA-256 Hash: \(self.evidence.sha256Hash)
            Latitude: \(latitudeText)
            Longitude: \(longitudeText)
            Accuracy: \(accuracyText)
            Device Name: \(self.evidence.deviceName ?? "N/A")
            iOS Version: \(self.evidence.iOSVersion ?? "N/A")
            Collection Date (UTC): \(utcCollectionDate)
            App Version: \(self.evidence.appVersion ?? "N/A")
            """
            
            guard let data = qrData.data(using: .utf8) else {
                self.showAlert(
                    title: "QR Code Error",
                    message: "Could not prepare QR code data."
                )
                return
            }
            
            self.qrFilter.message = data
            self.qrFilter.correctionLevel = "H"
            
            guard let outputImage = self.qrFilter.outputImage,
                  let cgImage = self.context.createCGImage(
                    outputImage,
                    from: outputImage.extent
                  ) else {
                self.showAlert(
                    title: "QR Code Error",
                    message: "Could not generate QR code."
                )
                return
            }
            
            let qrImage = UIImage(cgImage: cgImage)
            
            self.generatedQRImage = qrImage
            
            ChainOfCustodyStorage.shared.recordEvent(
                evidence: self.evidence,
                action: "Evidence QR Code Generated",
                performedBy: "Investigator",
                details: "QR code generated containing evidence ID, case number, and SHA-256 hash."
            )
            
            let imageViewController = UIViewController()
            imageViewController.title = "Evidence QR Code"
            imageViewController.view.backgroundColor = .systemBackground
            
            let imageView = UIImageView(image: qrImage)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            
            let shareButton = UIButton(type: .system)
            shareButton.setTitle("Share QR Code", for: .normal)
            shareButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
            shareButton.backgroundColor = .systemBlue
            shareButton.setTitleColor(.white, for: .normal)
            shareButton.layer.cornerRadius = 10
            shareButton.translatesAutoresizingMaskIntoConstraints = false
            
            shareButton.addTarget(
                self,
                action: #selector(self.shareQRCodeTapped),
                for: .touchUpInside
            )
            
            imageViewController.view.addSubview(shareButton)
            imageViewController.view.addSubview(imageView)
            
            NSLayoutConstraint.activate([
                
                imageView.centerXAnchor.constraint(
                    equalTo: imageViewController.view.centerXAnchor
                ),
                
                imageView.centerYAnchor.constraint(
                    equalTo: imageViewController.view.centerYAnchor
                ),
                
                imageView.widthAnchor.constraint(
                    equalTo: imageViewController.view.widthAnchor,
                    multiplier: 0.7
                ),
                
                imageView.heightAnchor.constraint(
                    equalTo: imageView.widthAnchor
                ),
                
                shareButton.centerXAnchor.constraint(
                    equalTo: imageViewController.view.centerXAnchor
                ),
                
                shareButton.topAnchor.constraint(
                    equalTo: imageView.bottomAnchor,
                    constant: 30
                ),
                
                shareButton.leadingAnchor.constraint(
                    equalTo: imageViewController.view.leadingAnchor,
                    constant: 30
                ),
                
                shareButton.trailingAnchor.constraint(
                    equalTo: imageViewController.view.trailingAnchor,
                    constant: -30
                ),
                
                shareButton.heightAnchor.constraint(
                    equalToConstant: 50
                )
            ])
            
            self.navigationController?.pushViewController(
                imageViewController,
                animated: true
            )
        }
    }
    
    
    @objc private func shareQRCodeTapped() {
        
        guard let qrImage = generatedQRImage else {
            showAlert(
                title: "QR Code Not Found",
                message: "Please generate the QR code first."
            )
            return
        }
        
        BiometricAuth.shared.authenticate { [weak self] success, error in
            
            guard let self = self else { return }
            
            guard success else {
                self.showAlert(
                    title: "Authentication Failed",
                    message: error ?? "Authentication is required to share the QR code."
                )
                return
            }
            
            let activityVC = UIActivityViewController(
                activityItems: [qrImage],
                applicationActivities: nil
            )
            
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = self.view
                popover.sourceRect = CGRect(
                    x: self.view.bounds.midX,
                    y: self.view.bounds.midY,
                    width: 0,
                    height: 0
                )
            }
            
            activityVC.completionWithItemsHandler = {
                _, completed, _, _ in
                
                guard completed else { return }
                
                ChainOfCustodyStorage.shared.recordEvent(
                    evidence: self.evidence,
                    action: "Evidence QR Code Shared",
                    performedBy: "Investigator",
                    details: "Evidence QR code sharing completed."
                )
            }
            
            self.present(activityVC, animated: true)
        }
    }
    
  
    @objc private func viewLocationTapped() {

        guard let latitude = evidence.latitude,
              let longitude = evidence.longitude else {

            showAlert(
                title: "Location Unavailable",
                message: "GPS coordinates are not available for this evidence."
            )
            return
        }

        BiometricAuth.shared.authenticate { [weak self] success, error in

            guard let self = self else { return }

            guard success else {
                self.showAlert(
                    title: "Authentication Failed",
                    message: error ?? "Authentication is required to view the evidence location."
                )
                return
            }

            let mapVC = UIViewController()
            mapVC.title = "Evidence Location"
            mapVC.view.backgroundColor = .systemBackground

            let mapView = MKMapView()
            mapView.translatesAutoresizingMaskIntoConstraints = false

            mapVC.view.addSubview(mapView)

            NSLayoutConstraint.activate([
                mapView.topAnchor.constraint(
                    equalTo: mapVC.view.safeAreaLayoutGuide.topAnchor
                ),
                mapView.leadingAnchor.constraint(
                    equalTo: mapVC.view.leadingAnchor
                ),
                mapView.trailingAnchor.constraint(
                    equalTo: mapVC.view.trailingAnchor
                ),
                mapView.bottomAnchor.constraint(
                    equalTo: mapVC.view.bottomAnchor
                )
            ])

            let coordinate = CLLocationCoordinate2D(
                latitude: latitude,
                longitude: longitude
            )

            let annotation = MKPointAnnotation()

            annotation.coordinate = coordinate
            annotation.subtitle = """
            Accuracy: \(self.evidence.horizontalAccuracy ?? 0) meters
            """
            annotation.title = "Evidence Collection Location"

            mapView.addAnnotation(annotation)

            let region = MKCoordinateRegion(
                center: coordinate,
                latitudinalMeters: 500,
                longitudinalMeters: 500
            )

            mapView.setRegion(region, animated: false)

            self.navigationController?.pushViewController(
                mapVC,
                animated: true
            )
        }
    }

    
    @objc private func copyLocationTapped() {
        
        guard let latitude = evidence.latitude,
              let longitude = evidence.longitude else {
            
            showAlert(
                title: "Location Unavailable",
                message: "GPS coordinates are not available."
            )
            return
        }
        
        BiometricAuth.shared.authenticate { [weak self] success, error in
            
            guard let self = self else { return }
            
            guard success else {
                self.showAlert(
                    title: "Authentication Failed",
                    message: error ?? "Authentication is required to copy GPS coordinates."
                )
                return
            }
            
            let coordinates = """
            Evidence Location
            Latitude: \(latitude)
            Longitude: \(longitude)
            Accuracy: \(self.evidence.horizontalAccuracy ?? 0) meters
            """
            
            UIPasteboard.general.string = coordinates
            
            ChainOfCustodyStorage.shared.recordEvent(
                evidence: self.evidence,
                action: "GPS Coordinates Copied",
                performedBy: "Investigator",
                details: "Evidence GPS coordinates copied to clipboard."
            )
            
            self.showAlert(
                title: "Coordinates Copied",
                message: "GPS coordinates copied successfully."
            )
        }
    }
}

extension EvidenceDetailViewController: QLPreviewControllerDataSource, QLPreviewControllerDelegate {

    func numberOfPreviewItems(
        in controller: QLPreviewController
    ) -> Int {
        return decryptedPreviewURL == nil ? 0 : 1
    }

    func previewController(
        _ controller: QLPreviewController,
        previewItemAt index: Int
    ) -> QLPreviewItem {
        return decryptedPreviewURL! as NSURL
    }

    func previewControllerDidDismiss(
        _ controller: QLPreviewController
    ) {
        if let url = decryptedPreviewURL {
            try? FileManager.default.removeItem(at: url)
            decryptedPreviewURL = nil
        }
    }
}
