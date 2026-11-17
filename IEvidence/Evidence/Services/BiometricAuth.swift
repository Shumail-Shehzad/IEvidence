
import Foundation
import LocalAuthentication

final class BiometricAuth {

    static let shared = BiometricAuth()

    private init() {}

    func authenticate(
        completion: @escaping (Bool, String?) -> Void
    ) {

        let context = LAContext()

        context.localizedCancelTitle = "Cancel"

        var error: NSError?

        guard context.canEvaluatePolicy(
            .deviceOwnerAuthentication,
            error: &error
        ) else {

            completion(
                false,
                error?.localizedDescription ?? "Authentication is unavailable."
            )

            return
        }

        context.evaluatePolicy(
            .deviceOwnerAuthentication,
            localizedReason: "Authenticate to access digital evidence."
        ) { success, authenticationError in

            DispatchQueue.main.async {

                if success {
                    completion(true, nil)
                } else {
                    completion(
                        false,
                        authenticationError?.localizedDescription
                            ?? "Authentication failed."
                    )
                }
            }
        }
    }
}
