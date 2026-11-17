
import Foundation

class ChainOfCustodyStorage {

    static let shared = ChainOfCustodyStorage()

    private let storageKey = "savedChainOfCustody"

    private init() {}

    // MARK: - Save Audit Record

    func recordEvent(
        evidence: EvidenceModel,
        action: String,
        performedBy: String,
        details: String
    ) {

        let record = ChainOfCustodyModel(
            id: UUID(),
            evidenceID: evidence.id,
            caseNumber: evidence.caseNumber,
            action: action,
            performedBy: performedBy,
            date: Date(),
            details: details
        )

        var allRecords = fetchAllRecords()

        allRecords.append(record)

        do {

            let encodedData = try JSONEncoder().encode(allRecords)

            UserDefaults.standard.set(
                encodedData,
                forKey: storageKey
            )

            print("Chain of custody record saved: \(action)")

        } catch {

            print("Audit record saving error: \(error)")
        }
    }
    // MARK: - Fetch Records for Case

    func fetchRecords(forCaseNumber caseNumber: String) -> [ChainOfCustodyModel] {

        return fetchAllRecords()
            .filter { $0.caseNumber == caseNumber }
            .sorted { $0.date > $1.date }
    }
    // MARK: - Fetch Records for Evidence

    func fetchRecords(for evidenceID: UUID) -> [ChainOfCustodyModel] {

        return fetchAllRecords()
            .filter { $0.evidenceID == evidenceID }
            .sorted { $0.date < $1.date }
    }

    // MARK: - Fetch All Records

    private func fetchAllRecords() -> [ChainOfCustodyModel] {

        guard let savedData = UserDefaults.standard.data(
            forKey: storageKey
        ) else {
            return []
        }

        do {

            return try JSONDecoder().decode(
                [ChainOfCustodyModel].self,
                from: savedData
            )

        } catch {

            print("Chain of custody loading error: \(error)")
            return []
        }
    }
}
