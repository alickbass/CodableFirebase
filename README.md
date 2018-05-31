# CodableFirebase
Use [Codable](https://developer.apple.com/documentation/swift/codable) with [Firebase](https://firebase.google.com)

[![CocoaPods](https://img.shields.io/cocoapods/p/CodableFirebase.svg)](https://github.com/alickbass/CodableFirebase)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) 
[![Build Status](https://travis-ci.org/alickbass/CodableFirebase.svg?branch=master)](https://travis-ci.org/alickbass/CodableFirebase)

## Overview

This library helps you to use your custom types that conform to `Codable` protocol with Firebase. Here's an example of a custom model:

```swift
struct Model: Codable {
    enum MyEnum: Int, Codable {
        case one, two, three
    }
    
    let stringExample: String
    let booleanExample: Bool
    let numberExample: Double
    let dateExample: Date
    let arrayExample: [String]
    let optionalExample: Int?
    let objectExample: [String: String]
    let myEnumExample: MyEnum
}
```

### Firebase Realtime Database usage

This is how you would use the library with [Firebase Realtime Database](https://firebase.google.com/products/realtime-database/):

```swift
import Firebase
import CodableFirebase

let model: Model // here you will create an instance of Model
let data = try! FirebaseEncoder().encode(model)

Database.database().reference().child("model").setValue(data)
```

And here is how you would read the same value from [Firebase Realtime Database](https://firebase.google.com/products/realtime-database/):

```swift
Database.database().reference().child("model").observeSingleEvent(of: .value, with: { snapshot in
    guard let value = snapshot.value else { return }
    do {
        let model = try FirebaseDecoder().decode(Model.self, from: value)
        print(model)
    } catch let error {
        print(error)
    }
})
```

### Firebase Cloud Firestore usage

This is how you would encode a model with [Firebase Cloud Firestore](https://firebase.google.com/products/firestore/):

```swift
import Firebase
import CodableFirebase

let model: Model // here you will create an instance of Model
let docData = try! FirestoreEncoder().encode(model)
Firestore.firestore().collection("data").document("one").setData(docData) { error in
    if let error = error {
        print("Error writing document: \(error)")
    } else {
        print("Document successfully written!")
    }
}
```

And this is how you would decode the same model with [Firebase Cloud Firestore](https://firebase.google.com/products/firestore/):

```swift
Firestore.firestore().collection("data").document("one").getDocument { document, error in
    if let document = document {
        let model = try! FirestoreDecoder().decode(Model.self, from: document.data())
        print("Model: \(model)")
    } else {
        print("Document does not exist")
    }
}
```

#### How to use `GeoPoint`, `DocumentRefence`, `FieldValue`, `Timestamp` in Cloud Firestore

In order to use these types with Cloud Firestore, you need to add the following code somewhere in your app:

```swift
extension DocumentReference: DocumentReferenceType {}
extension GeoPoint: GeoPointType {}
extension FieldValue: FieldValueType {}
extension Timestamp: TimestampType {}
```

and now they become `Codable` and can be used properly with `FirestoreEncoder` and `FirestoreDecoder`.

***PLEASE NOTE*** that as `FieldValue` is only used to [`setData()` and `updateData()`](https://firebase.google.com/docs/reference/swift/firebasefirestore/api/reference/Classes/FieldValue), it only adopts the `Encodable` protocol. 

## Integration

### CocoaPods (iOS 9+)

You can use CocoaPods to install CodableFirebase by adding it to your Podfile:

```swift
platform :ios, '9.0'
use_frameworks!

target 'MyApp' do
  pod 'CodableFirebase'
end
```

Note that this requires CocoaPods version 36, and your iOS deployment target to be at least 9.0:

### Carthage (iOS 9+)

You can use Carthage to install CodableFirebase by adding it to your Cartfile:

```swift
github "alickbass/CodableFirebase"
```
