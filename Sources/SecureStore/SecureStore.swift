/// Secure Store - A lightweight keychain wrapper for Swift
///
/// By Kemenes Krisztian
/// On 12.02.2025

import Security
import Foundation

/// A lightweight keychain wrapper for Swift
public class SecureStore {
    private let domain: String
    
    /// Create a secure store instance with a given domain
    /// - Parameter domain: The domain is used to tag the secrets saved in the secure store
    public init(domain: String? = nil) {
        guard let domain = domain ?? Bundle.main.bundleIdentifier
        else { fatalError("Domain should not be nil if the bundle identifier is nil") }
        self.domain = domain
    }
    
    // MARK: Storing
    
    /// Store a string secret in the secure store
    /// - Parameters:
    ///   - secret: Secret to store
    ///   - tag: Key to identify the secret
    ///   See ``store(secret: Data, for tag: String)`` for more details
    public func store(secret: String, for tag: String) throws {
        guard let data = secret.data(using: .utf8)
        else { throw SecureStoreError.invalidInput }
        
        try store(secret: data, for: tag)
    }
    
    /// Store a data secret in the secure store
    /// - Parameters:
    ///   - secret: Secret to store
    ///   - tag: Key to identify the secret
    public func store(secret: Data, for tag: String) throws {
        let updated = try self.updateItem(secret, for: tag)
        if !updated {
            let inserted = try self.storeItem(secret, for: tag)
            if !inserted {
                throw SecureStoreError.operationFailed
            }
        }
    }
    
    // MARK: Retrieving
    
    /// Get an item from the keychain
    public func retrieve(for tag: String) -> Data? {
        guard let tag = try? self.tag(for: tag) else { return nil }
        let getQuery: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecReturnData as String: true
        ]
        
        var returnedItem: CFTypeRef?
        let status = SecItemCopyMatching(getQuery as CFDictionary, &returnedItem)
        guard status == errSecSuccess else { return nil }
        
        return returnedItem as? Data
    }
    
    /// Get a string item from the keychain
    public func retrieveString(for tag: String) -> String? {
        if let data = retrieve(for: tag), let string = String(data: data, encoding: .utf8) {
            return string
        }
        
        return nil
    }
    
    // MARK: Removing
    
    /// Delete the item of a tag
    /// - Parameters:
    ///    - tag: Key of the secret
    public func delete(for tag: String) throws {
        let tag = try self.tag(for: tag)
        let getQuery: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
        ]
        let status = SecItemDelete(getQuery as CFDictionary)
        if status != errSecSuccess {
            throw SecureStoreError.operationFailed
        }
    }
}

// MARK: - Convenience API

extension SecureStore {
    /// Store a data secret in the secure store
    /// - Parameters:
    ///   - secret: Secret to store
    ///   - tag: Key to identify the secret
    ///   See ``store(secret: Data, for tag: String)`` for more details
    func store(secret: Data, for tag: any RawRepresentable<String>) throws {
        try store(secret: secret, for: tag.rawValue)
    }
    
    /// Store a string secret in the secure store
    /// - Parameters:
    ///   - secret: Secret to store
    ///   - tag: Key to identify the secret
    ///   See ``store(secret: Data, for tag: String)`` for more details
    func store(secret: String, for tag: any RawRepresentable<String>) throws {
        try store(secret: secret, for: tag.rawValue)
    }
    
    /// Get an item from the keychain
    /// - Parameters:
    ///    - tag: Key of the secret
    func retrieve(for tag: any RawRepresentable<String>) -> Data? {
        retrieve(for: tag.rawValue)
    }
    
    /// Get an item from the keychain
    /// - Parameters:
    ///    - tag: Key of the secret
    func retrieveString(for tag: any RawRepresentable<String>) -> String? {
        retrieveString(for: tag.rawValue)
    }
    
    /// Delete the item of a tag
    /// - Parameters:
    ///    - tag: Key of the secret
    func delete(for tag: any RawRepresentable<String>) throws {
        try delete(for: tag.rawValue)
    }
}

// MARK: - Helpers

extension SecureStore {
    /// Store an item in the keychain
    /// - Returns: Boolean flag indicating success
    private func storeItem(_ secret: Data, for tag: String) throws -> Bool {
        let tag = try self.tag(for: tag)
        let attributes: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecValueData as String: secret
        ]
        
        let status = SecItemAdd(attributes as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    /// Update an item in the keychain
    /// - Returns: Boolean flag indicating success
    private func updateItem(_ secret: Data, for tag: String) throws -> Bool {
        let tag = try self.tag(for: tag)
        
        let getQuery: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
        ]
        let updateQuery: [String: Any] = [
            kSecValueData as String: secret
        ]
        
        let status = SecItemUpdate(getQuery as CFDictionary, updateQuery as CFDictionary)
        return status == errSecSuccess
    }
    
    /// Generate tag as data
    private func tag(for key: String) throws -> Data {
        guard let tag = "\(self.domain).\(key)".data(using: .utf8)
        else { throw SecureStoreError.invalidInput }
        return tag
    }
}
