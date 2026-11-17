
import Foundation

struct EvidenceModel: Codable {

    let id: UUID
    let caseNumber: String
    let fileName: String
    let evidenceDescription: String
    let dateCollected: Date
    let sha256Hash: String

    let latitude: Double?
    let longitude: Double?
    let horizontalAccuracy: Double?

    let deviceName: String?
    let iOSVersion: String?
    let appVersion: String?

    // Indicates whether the evidence file is encrypted
    let isEncrypted: Bool?

    var evidenceType: String {

        switch fileName.lowercased().split(separator: ".").last {

        case "jpg", "jpeg", "png", "heic":
            return "Image"

        case "mp4", "mov", "m4v":
            return "Video"

        case "pdf":
            return "PDF Document"

        default:
            return "Other"
        }
    }
}
