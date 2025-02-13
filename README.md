#  SecureStore - A lightweight Keychain wrapper for Swift

This package is a Swift wrapper around the Keychain managment mechanisms contained in the `Security` module.

> Note: The packages main purpose is to provide an easy way for storing secret values in the keychain and thus it hides many options for the sake of a simpler API 

## Install

### 1. Swift Package Manager

Add the following to your `Package.swift` file

```swift
dependencies: [
  .package(
    name: "ProportionalStack",
    url: "https://github.com/kemkriszt/SecureStore",
    .upToNextMajor(from: "1.0)
  ),

  // Any other dependencies you have...
],
```

### 2. Form Xcode

1. Add a package by selecting `File` → `Add Package...` in the Menu bar
2. Search for `https://github.com/kemkriszt/SecureStore`

### 3. Manually

Since this is a two file package, you can easily copy the files in your project and start using the store

## Usage

### Storing and updating an item

```swift
let store = SecureStore(domain: "com.exmaple.myapp")

try store.store(secret: "my-secret", for: "secretKey")
```

For convinience, you can use any `RawRepresentable<String>` as a tag. 

```swift
enum SecretKeys: String {
    case apiToken = "api-token"
}

try store.store(secret: "my-secret", for: SecretKeys.apiToken)
```

Calling the store multiple times with the same tag will update the value if it already exists

### Retrieving an item

```swift
let secureData = store.retrieve(for: SecretKeys.apiToken)
// or...
let secureString = store.retrieveString(for: "my-key")
```

### Removing an item

```swift
try store.delete(for: "my-key")
```

---

If you want to get in contact, find me on [X](https://x.com/@kkemenes_)
