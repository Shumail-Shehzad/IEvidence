import Foundation

struct CaseModel: Codable {

    let caseNumber: String
    let firNumber: String
    let caseTitle: String
    let crimeType: String
    let caseDescription: String
    let incidentDate: Date
    let status: String
}
