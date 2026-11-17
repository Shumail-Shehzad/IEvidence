import Foundation

class CaseStorage {

    static let shared = CaseStorage()

    private let storageKey = "savedCases"

    private init() {}

    // Save a new case
    func saveCase(_ newCase: CaseModel) {

        var cases = fetchCases()

        cases.insert(newCase, at: 0)

        do {
            let encodedData = try JSONEncoder().encode(cases)

            UserDefaults.standard.set(
                encodedData,
                forKey: storageKey
            )

            print("Case saved successfully")

        } catch {
            print("Error saving case: \(error.localizedDescription)")
        }
    }

    // Fetch all saved cases
    func fetchCases() -> [CaseModel] {

        guard let savedData = UserDefaults.standard.data(
            forKey: storageKey
        ) else {
            return []
        }

        do {
            return try JSONDecoder().decode(
                [CaseModel].self,
                from: savedData
            )

        } catch {
            print("Error loading cases: \(error.localizedDescription)")
            return []
        }
    }
}
