
import UIKit
import Foundation
import CryptoKit

class EvidenceStorage {

    static let shared = EvidenceStorage()
    private let storageKey = "savedEvidence"

    private init() {}

    // MARK: - Evidence Folder

    private func evidenceFolderURL() -> URL {

        let documentsURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]

        let folderURL = documentsURL.appendingPathComponent(
            "EvidenceFiles",
            isDirectory: true
        )

        if !FileManager.default.fileExists(atPath: folderURL.path) {
            try? FileManager.default.createDirectory(
                at: folderURL,
                withIntermediateDirectories: true
            )
        }

        return folderURL
    }

    // MARK: - Generate SHA-256 Hash

    private func generateSHA256(for data: Data) -> String {

        let hash = SHA256.hash(data: data)

        return hash.map {
            String(format: "%02x", $0)
        }.joined()
    }

    // MARK: - Import Evidence File

    func importEvidenceFile(
        from sourceURL: URL,
        caseNumber: String,
        description: String,
        latitude: Double? = nil,
        longitude: Double? = nil,
        horizontalAccuracy: Double? = nil
    ) throws -> EvidenceModel {

        let folderURL = evidenceFolderURL()

        let fileExtension = sourceURL.pathExtension.isEmpty
            ? "bin"
            : sourceURL.pathExtension

        let fileName = UUID().uuidString + "." + fileExtension
        let destinationURL = folderURL.appendingPathComponent(fileName)

        // Read original evidence file
        let fileData = try Data(contentsOf: sourceURL)

        // Generate SHA-256 hash from original file
        let hashString = generateSHA256(for: fileData)

        // Encrypt original evidence using AES-256-GCM
        let encryptedData = try EvidenceEncryption.encrypt(fileData)

        // Save encrypted evidence to app storage
        try encryptedData.write(
            to: destinationURL,
            options: .atomic
        )

        // Protect evidence file while device is locked
        try FileManager.default.setAttributes(
            [
                .protectionKey: FileProtectionType.complete
            ],
            ofItemAtPath: destinationURL.path
        )
        // Create Evidence Object
        let evidence = EvidenceModel(
            id: UUID(),
            caseNumber: caseNumber,
            fileName: fileName,
            evidenceDescription: description,
            dateCollected: Date(),
            sha256Hash: hashString,
            latitude: latitude,
            longitude: longitude,
            horizontalAccuracy: horizontalAccuracy,
            deviceName: UIDevice.current.model,
            iOSVersion: UIDevice.current.systemVersion,
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            isEncrypted: true
        )

        // Save metadata
        var allEvidence = fetchEvidence()
        allEvidence.append(evidence)

        let encodedData = try JSONEncoder().encode(allEvidence)

        UserDefaults.standard.set(
            encodedData,
            forKey: storageKey
        )

        return evidence
    }

    // MARK: - Fetch Evidence

    func fetchEvidence(for caseNumber: String) -> [EvidenceModel] {

        return fetchEvidence().filter {
            $0.caseNumber == caseNumber
        }
    }

    private func fetchEvidence() -> [EvidenceModel] {

        guard let savedData = UserDefaults.standard.data(
            forKey: storageKey
        ) else {
            return []
        }

        do {
            return try JSONDecoder().decode(
                [EvidenceModel].self,
                from: savedData
            )
        } catch {
            print("Evidence loading error: \(error)")
            return []
        }
    }

    // MARK: - Create Decrypted Temporary Evidence File

    func decryptedFileURL(for evidence: EvidenceModel) throws -> URL {

        let originalURL = fileURL(for: evidence)

        guard FileManager.default.fileExists(
            atPath: originalURL.path
        ) else {
            throw EvidenceStorageError.fileNotFound
        }

        // Read stored evidence
        let storedData = try Data(contentsOf: originalURL)

        // Support both encrypted and older unencrypted evidence
        let originalData: Data

        if evidence.isEncrypted == true {

            originalData = try EvidenceEncryption.decrypt(storedData)

        } else {

            originalData = storedData
        }

        // Verify original evidence before creating temporary copy
        let currentHash = generateSHA256(for: originalData)

        guard currentHash == evidence.sha256Hash else {
            throw EvidenceStorageError.integrityCheckFailed
        }

        // Create temporary folder
        let temporaryFolder = FileManager.default.temporaryDirectory
            .appendingPathComponent(
                "DecryptedEvidence",
                isDirectory: true
            )

        try FileManager.default.createDirectory(
            at: temporaryFolder,
            withIntermediateDirectories: true
        )

        // Create unique temporary filename
        let temporaryURL = temporaryFolder.appendingPathComponent(
            UUID().uuidString + "." + originalURL.pathExtension
        )

        try originalData.write(
            to: temporaryURL,
            options: .atomic
        )

        // Protect temporary decrypted evidence
        try FileManager.default.setAttributes(
            [
                .protectionKey: FileProtectionType.complete
            ],
            ofItemAtPath: temporaryURL.path
        )
        return temporaryURL
    }

    // MARK: - Evidence File URL

    func fileURL(for evidence: EvidenceModel) -> URL {

        return evidenceFolderURL().appendingPathComponent(
            evidence.fileName
        )
    }

    // MARK: - Verify Evidence Integrity

    func verifyIntegrity(of evidence: EvidenceModel) throws -> Bool {

        let url = fileURL(for: evidence)

        // Check whether evidence file exists
        guard FileManager.default.fileExists(
            atPath: url.path
        ) else {
            throw EvidenceStorageError.fileNotFound
        }

        // Read stored evidence
        let storedData = try Data(contentsOf: url)

        // Get original data
        let originalData: Data

        if evidence.isEncrypted == true {

            // Decrypt AES-256-GCM evidence
            originalData = try EvidenceEncryption.decrypt(storedData)

        } else {

            // Older evidence was stored without encryption
            originalData = storedData
        }

        // Generate SHA-256 hash
        let currentHash = generateSHA256(for: originalData)

        // Compare with originally stored hash
        return currentHash == evidence.sha256Hash
    }
    
    // MARK: - Clean Temporary Decrypted Evidence

    func cleanTemporaryEvidenceFiles() {

        let temporaryFolder = FileManager.default.temporaryDirectory
            .appendingPathComponent(
                "DecryptedEvidence",
                isDirectory: true
            )

        guard FileManager.default.fileExists(
            atPath: temporaryFolder.path
        ) else {
            return
        }

        do {
            let files = try FileManager.default.contentsOfDirectory(
                at: temporaryFolder,
                includingPropertiesForKeys: nil
            )

            for file in files {
                try FileManager.default.removeItem(at: file)
            }

            print("Temporary decrypted evidence files cleaned.")

        } catch {
            print("Temporary file cleanup error: \(error.localizedDescription)")
        }
    }


    // MARK: - Evidence Storage Errors

    enum EvidenceStorageError: LocalizedError {

        case fileNotFound
        case integrityCheckFailed

        var errorDescription: String? {

            switch self {

            case .fileNotFound:
                return "The original evidence file could not be found."

            case .integrityCheckFailed:
                return "Evidence integrity verification failed. The file may have been modified."
            }
        }
    }
}
