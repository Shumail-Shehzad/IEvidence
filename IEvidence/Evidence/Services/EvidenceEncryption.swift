
import Foundation
import CryptoKit
import Security

enum EvidenceEncryptionError: Error {
    case keyGenerationFailed
    case keychainError(OSStatus)
    case encryptionFailed
    case decryptionFailed
}

final class EvidenceEncryption {

    private static let keychainService = "com.shumail.iEvidence"
    private static let keychainAccount = "EvidenceEncryptionKey"

    // Get or create the AES-256 encryption key
    private static func getEncryptionKey() throws -> SymmetricKey {

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: CFTypeRef?

        let status = SecItemCopyMatching(
            query as CFDictionary,
            &result
        )

        if status == errSecSuccess,
           let keyData = result as? Data {
            return SymmetricKey(data: keyData)
        }

        guard status == errSecItemNotFound else {
            throw EvidenceEncryptionError.keychainError(status)
        }

        let newKey = SymmetricKey(size: .bits256)

        let keyData = newKey.withUnsafeBytes {
            Data($0)
        }

        let saveQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String:
                kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let saveStatus = SecItemAdd(
            saveQuery as CFDictionary,
            nil
        )

        guard saveStatus == errSecSuccess else {
            throw EvidenceEncryptionError.keychainError(saveStatus)
        }

        return newKey
    }

    // Encrypt evidence data
    static func encrypt(_ data: Data) throws -> Data {

        let key = try getEncryptionKey()

        do {
            let sealedBox = try AES.GCM.seal(
                data,
                using: key
            )

            guard let encryptedData = sealedBox.combined else {
                throw EvidenceEncryptionError.encryptionFailed
            }

            return encryptedData

        } catch let error as EvidenceEncryptionError {
            throw error
        } catch {
            throw EvidenceEncryptionError.encryptionFailed
        }
    }

    // Decrypt evidence data
    static func decrypt(_ encryptedData: Data) throws -> Data {

        let key = try getEncryptionKey()

        do {
            let sealedBox = try AES.GCM.SealedBox(
                combined: encryptedData
            )

            return try AES.GCM.open(
                sealedBox,
                using: key
            )

        } catch {
            throw EvidenceEncryptionError.decryptionFailed
        }
    }
}
