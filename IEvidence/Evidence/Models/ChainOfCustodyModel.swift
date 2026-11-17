
import Foundation

struct ChainOfCustodyModel: Codable {

    let id: UUID
    let evidenceID: UUID
    let caseNumber: String
    let action: String
    let performedBy: String
    let date: Date
    let details: String
}
