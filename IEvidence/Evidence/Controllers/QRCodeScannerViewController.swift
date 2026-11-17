
import UIKit
import AVFoundation

class QRCodeScannerViewController: UIViewController {

    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let messageLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Scan Evidence QR"

        setupUI()
        setupCamera()
    }

    // MARK: - Camera Setup

    private func setupCamera() {

        let authorizationStatus =
            AVCaptureDevice.authorizationStatus(for: .video)

        switch authorizationStatus {

        case .authorized:
            configureCamera()

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in

                DispatchQueue.main.async {

                    if granted {
                        self.configureCamera()
                    } else {
                        self.messageLabel.text =
                            "Camera permission denied."
                    }
                }
            }

        default:
            messageLabel.text =
                "Please allow camera access in Settings."
        }
    }

    private func configureCamera() {

        let session = AVCaptureSession()

        guard let videoCaptureDevice =
                AVCaptureDevice.default(for: .video) else {

            messageLabel.text = "Camera is not available."
            return
        }

        do {

            let videoInput = try AVCaptureDeviceInput(
                device: videoCaptureDevice
            )

            guard session.canAddInput(videoInput) else {
                messageLabel.text = "Cannot access camera input."
                return
            }

            session.addInput(videoInput)

            let metadataOutput = AVCaptureMetadataOutput()

            guard session.canAddOutput(metadataOutput) else {
                messageLabel.text = "Cannot configure QR scanner."
                return
            }

            session.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(
                self,
                queue: DispatchQueue.main
            )

            metadataOutput.metadataObjectTypes = [.qr]

            captureSession = session

            let preview = AVCaptureVideoPreviewLayer(
                session: session
            )

            preview.videoGravity = .resizeAspectFill
            preview.frame = view.bounds

            view.layer.insertSublayer(preview, at: 0)

            previewLayer = preview

            DispatchQueue.global(qos: .userInitiated).async {
                session.startRunning()
            }

        } catch {

            messageLabel.text =
                "Camera error: \(error.localizedDescription)"
        }
    }

    // MARK: - User Interface

    private func setupUI() {

        view.backgroundColor = .black

        messageLabel.text =
            "Point your camera at an evidence QR code"

        messageLabel.textColor = .white
        messageLabel.font = .boldSystemFont(ofSize: 17)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(messageLabel)

        NSLayoutConstraint.activate([

            messageLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 20
            ),

            messageLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),

            messageLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            )
        ])
    }

    // MARK: - Verification Alert

    private func showVerificationAlert(
        title: String,
        message: String
    ) {

        messageLabel.text = title

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

// MARK: - QR Code Scanner Delegate

extension QRCodeScannerViewController:
    AVCaptureMetadataOutputObjectsDelegate {

    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {

        guard let metadataObject =
                metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              metadataObject.type == .qr,
              let scannedValue = metadataObject.stringValue else {

            return
        }
        
        print("FULL SCANNED QR CONTENT:")
        print(scannedValue)

        print("SCANNED QR LINES:")
        print(scannedValue.components(separatedBy: .newlines))
        captureSession?.stopRunning()

        DispatchQueue.main.async {

            let lines = scannedValue.components(
                separatedBy: .newlines
            )

            // Read a value from the QR code.
            func getValue(for key: String) -> String? {
                guard let line = lines.first(where: { line in
                    let parts = line.split(
                        separator: ":",
                        maxSplits: 1
                    )

                    guard let firstPart = parts.first else {
                        return false
                    }

                    return firstPart.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ) == key
                }) else {
                    return nil
                }

                let parts = line.split(separator: ":", maxSplits: 1)

                guard parts.count == 2 else {
                    return nil
                }

                return String(parts[1])
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            }

            // Extract QR information.

          
            guard
                let evidenceIDString = getValue(for: "Evidence ID"),
                let evidenceID = UUID(uuidString: evidenceIDString),
                let caseNumber = getValue(for: "Case Number"),
                let scannedHash = getValue(for: "SHA-256 Hash"),
                let scannedLatitude = getValue(for: "Latitude"),
                let scannedAccuracy = getValue(for: "Accuracy"),
                let scannedLongitude = getValue(for: "Longitude")
            else {

                self.showVerificationAlert(
                    title: "Invalid QR Code",
                    message: "Required evidence information is missing or invalid."
                )

                return
            }

            // Extract device information
            let scannedUTCDate = getValue(for: "Collection Date (UTC)")
                ?? getValue(for: "Collection Date (UTC):")
            let scannedDeviceName = getValue(for: "Device Name")
            let scannedIOSVersion = getValue(for: "iOS Version")
            let scannedAppVersion = getValue(for: "App Version")


            // Find evidence in local storage.

            guard let storedEvidence = EvidenceStorage.shared
                .fetchEvidence(for: caseNumber)
                .first(where: { $0.id == evidenceID }) else {

                self.showVerificationAlert(
                    title: "Evidence Not Found",
                    message: "No matching evidence record was found."
                )

                return
            }

            // Verify case number.

            let caseIsValid =
                storedEvidence.caseNumber == caseNumber

            // Verify SHA-256 hash in QR code.

            let hashIsValid =
                storedEvidence.sha256Hash.caseInsensitiveCompare(
                    scannedHash
                ) == .orderedSame

            // Verify GPS coordinates.

            let latitudeIsValid: Bool

            if scannedLatitude == "N/A" {
                latitudeIsValid = storedEvidence.latitude == nil
            } else {
                latitudeIsValid =
                    Double(scannedLatitude) == storedEvidence.latitude
            }
            
            // Verify device information

            let deviceNameIsValid =
                (scannedDeviceName ?? "N/A") ==
                (storedEvidence.deviceName ?? "N/A")

            let iOSVersionIsValid =
                (scannedIOSVersion ?? "N/A") ==
                (storedEvidence.iOSVersion ?? "N/A")

            let appVersionIsValid =
                (scannedAppVersion ?? "N/A") ==
                (storedEvidence.appVersion ?? "N/A")

            // Verify UTC collection timestamp

            let utcDateIsValid: Bool

            print("Scanned UTC Date:", scannedUTCDate ?? "NIL")

            print(
                "Stored UTC Date:",
                ISO8601DateFormatter().string(
                    from: storedEvidence.dateCollected
                )
            )

            if let scannedUTCDate = scannedUTCDate,
               let scannedDate = ISO8601DateFormatter().date(
                   from: scannedUTCDate
               ) {

                let difference = abs(
                    scannedDate.timeIntervalSince(
                        storedEvidence.dateCollected
                    )
                )

                print("UTC Date Difference:", difference, "seconds")

                utcDateIsValid = difference < 1

            } else {
                print("UTC Date Parsing Failed")
                utcDateIsValid = false
            }

            let accuracyIsValid: Bool

            if scannedAccuracy == "N/A" {
                accuracyIsValid = storedEvidence.horizontalAccuracy == nil
            } else {
                accuracyIsValid =
                    Double(scannedAccuracy) == storedEvidence.horizontalAccuracy
            }

            let longitudeIsValid: Bool

            if scannedLongitude == "N/A" {
                longitudeIsValid = storedEvidence.longitude == nil
            } else {
                longitudeIsValid =
                    Double(scannedLongitude) == storedEvidence.longitude
            }

            // Verify actual stored evidence file integrity.

            let fileIsValid: Bool

            do {

                fileIsValid = try EvidenceStorage.shared.verifyIntegrity(
                    of: storedEvidence
                )

            } catch {

                self.showVerificationAlert(
                    title: "Verification Error",
                    message: error.localizedDescription
                )

                return
            }

            // Final verification result.
            let isValid =
                caseIsValid &&
                hashIsValid &&
                latitudeIsValid &&
                longitudeIsValid &&
                accuracyIsValid &&
                deviceNameIsValid &&
                iOSVersionIsValid &&
                appVersionIsValid &&
                utcDateIsValid &&
                fileIsValid
            
            print("Case Valid:", caseIsValid)
            print("Hash Valid:", hashIsValid)
            print("Latitude Valid:", latitudeIsValid)
            print("Longitude Valid:", longitudeIsValid)
            print("Accuracy Valid:", accuracyIsValid)
            print("Device Name Valid:", deviceNameIsValid)
            print("iOS Version Valid:", iOSVersionIsValid)
            print("App Version Valid:", appVersionIsValid)
            print("UTC Date Valid:", utcDateIsValid)
            print("File Integrity Valid:", fileIsValid)
            
            if isValid {

                ChainOfCustodyStorage.shared.recordEvent(
                    evidence: storedEvidence,
                    action: "QR Code Verified",
                    performedBy: "Investigator",
                    details: "Evidence ID, case number, SHA-256 hash, GPS coordinates, and actual file integrity verified."
                )
                self.showVerificationAlert(
                    title: "Evidence Verified",
                    message: """
                    Evidence ID: Verified
                    Case Number: Verified
                    SHA-256 Hash: Verified
                    GPS Coordinates: Verified
                    GPS Accuracy: Verified
                    Device Name: \(scannedDeviceName ?? "N/A")
                    iOS Version: \(scannedIOSVersion ?? "N/A")
                    App Version: \(scannedAppVersion ?? "N/A")
                    Collection Timestamp (UTC): Verified
                    File Integrity: Verified
                    """
                )

            } else {

                ChainOfCustodyStorage.shared.recordEvent(
                    evidence: storedEvidence,
                    action: "QR Code Verification Failed",
                    performedBy: "Investigator",
                    details: "QR information, GPS coordinates, or actual evidence file integrity did not match."
                )

                self.showVerificationAlert(
                    title: "Verification Failed",
                    message: """
                    One or more verification checks failed.
                    Evidence information, GPS coordinates, or file integrity does not match.
                    """
                )
            }
        }
    }
}
