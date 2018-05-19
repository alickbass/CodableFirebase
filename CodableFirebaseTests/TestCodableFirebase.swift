//
//  TestCodableFirebase.swift
//  CodableFirebaseTests
//
//  Created by Oleksii on 27/12/2017.
//  Copyright © 2017 ViolentOctopus. All rights reserved.
//

import XCTest
import CodableFirebase

class TestCodableFirebase: XCTestCase {
    // MARK: - Encoding Top-Level Empty Types
    func testEncodingTopLevelEmptyStruct() {
        _testRoundTrip(of: EmptyStruct(), expectedValue: _emptyDictionary)
    }
    
    func testEncodingTopLevelEmptyClass() {
        _testRoundTrip(of: EmptyClass(), expectedValue: _emptyDictionary)
    }
    
    // MARK: - Encoding Top-Level Single-Value Types
    func testEncodingTopLevelSingleValueEnum() {
        _testRoundTrip(of: Switch.off)
        _testRoundTrip(of: Switch.on)
        
        _testRoundTrip(of: TopLevelWrapper(Switch.off))
        _testRoundTrip(of: TopLevelWrapper(Switch.on))
    }
    
    func testEncodingTopLevelSingleValueStruct() {
        _testRoundTrip(of: Timestamp(3141592653))
        _testRoundTrip(of: TopLevelWrapper(Timestamp(3141592653)))
    }
    
    func testEncodingTopLevelSingleValueClass() {
        _testRoundTrip(of: Counter())
        _testRoundTrip(of: TopLevelWrapper(Counter()))
    }
    
    // MARK: - Encoding Top-Level Structured Types
    func testEncodingTopLevelStructuredStruct() {
        _testRoundTrip(of: Address.testValue)
    }
    
    func testEncodingTopLevelStructuredClass() {
        _testRoundTrip(of: Person.testValue, expectedValue: ["name": "Johnny Appleseed","email":"appleseed@apple.com"])
    }
    
    func testEncodingTopLevelStructuredSingleStruct() {
        _testRoundTrip(of: Numbers.testValue)
    }
    
    func testEncodingTopLevelStructuredSingleClass() {
        _testRoundTrip(of: Mapping.testValue)
    }
    
    func testEncodingTopLevelDeepStructuredType() {
        _testRoundTrip(of: Company.testValue)
    }
    
    func testEncodingClassWhichSharesEncoderWithSuper() {
        _testRoundTrip(of: Employee.testValue)
    }
    
    func testEncodingTopLevelNullableType() {
        // EnhancedBool is a type which encodes either as a Bool or as nil.
        _testRoundTrip(of: EnhancedBool.true)
        _testRoundTrip(of: EnhancedBool.false)
        _testRoundTrip(of: EnhancedBool.fileNotFound)
        
        _testRoundTrip(of: TopLevelWrapper(EnhancedBool.true), expectedValue: ["value": true])
        _testRoundTrip(of: TopLevelWrapper(EnhancedBool.false), expectedValue: ["value": false])
        _testRoundTrip(of: TopLevelWrapper(EnhancedBool.fileNotFound), expectedValue: ["value": NSNull()])
    }
    
    // MARK: - Date Strategy Tests
    func testEncodingDate() {
        _testRoundTrip(of: Date())
        _testRoundTrip(of: TopLevelWrapper(Date()))
        _testRoundTrip(of: OptionalTopLevelWrapper(Date()))
    }
    
    func testEncodingDateSecondsSince1970() {
        // Cannot encode an arbitrary number of seconds since we've lost precision since 1970.
        let seconds = 1000.0
        let expected = ["value":1000]
        
        _testRoundTrip(of: Date(timeIntervalSince1970: seconds),
                       expectedValue: 1000,
                       dateEncodingStrategy: .secondsSince1970,
                       dateDecodingStrategy: .secondsSince1970)
        
        _testRoundTrip(of: TopLevelWrapper(Date(timeIntervalSince1970: seconds)),
                       expectedValue: expected,
                       dateEncodingStrategy: .secondsSince1970,
                       dateDecodingStrategy: .secondsSince1970)
      
        _testRoundTrip(of: TopLevelWrapper(FirTimestamp(date: Date(timeIntervalSince1970: seconds))),
                       expectedValue: expected,
                       dateEncodingStrategy: .secondsSince1970,
                       dateDecodingStrategy: .secondsSince1970)
        
        _testRoundTrip(of: OptionalTopLevelWrapper(Date(timeIntervalSince1970: seconds)),
                       expectedValue: expected,
                       dateEncodingStrategy: .secondsSince1970,
                       dateDecodingStrategy: .secondsSince1970)
    }
    
    func testEncodingDateMillisecondsSince1970() {
        // Cannot encode an arbitrary number of seconds since we've lost precision since 1970.
        let seconds = 1000.0
        let expectedValue = ["value": 1000000]
        
        _testRoundTrip(of: Date(timeIntervalSince1970: seconds),
                       expectedValue: 1000000,
                       dateEncodingStrategy: .millisecondsSince1970,
                       dateDecodingStrategy: .millisecondsSince1970)
        
        _testRoundTrip(of: TopLevelWrapper(Date(timeIntervalSince1970: seconds)),
                       expectedValue: expectedValue,
                       dateEncodingStrategy: .millisecondsSince1970,
                       dateDecodingStrategy: .millisecondsSince1970)
        
        _testRoundTrip(of: OptionalTopLevelWrapper(Date(timeIntervalSince1970: seconds)),
                       expectedValue: expectedValue,
                       dateEncodingStrategy: .millisecondsSince1970,
                       dateDecodingStrategy: .millisecondsSince1970)
    }
    
    func testEncodingDateISO8601() {
        if #available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = .withInternetDateTime
            
            let timestamp = Date(timeIntervalSince1970: 1000)
            let expectedValue = ["value": formatter.string(from: timestamp)]
            
            _testRoundTrip(of: timestamp,
                           expectedValue: formatter.string(from: timestamp),
                           dateEncodingStrategy: .iso8601,
                           dateDecodingStrategy: .iso8601)
            
            _testRoundTrip(of: TopLevelWrapper(timestamp),
                           expectedValue: expectedValue,
                           dateEncodingStrategy: .iso8601,
                           dateDecodingStrategy: .iso8601)
            
            _testRoundTrip(of: OptionalTopLevelWrapper(timestamp),
                           expectedValue: expectedValue,
                           dateEncodingStrategy: .iso8601,
                           dateDecodingStrategy: .iso8601)
        }
    }
    
    func testEncodingDateFormatted() {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .full
        
        let timestamp = Date(timeIntervalSince1970: 1000)
        let expectedValue = ["value": formatter.string(from: timestamp)]
        
        _testRoundTrip(of: timestamp,
                       expectedValue: formatter.string(from: timestamp),
                       dateEncodingStrategy: .formatted(formatter),
                       dateDecodingStrategy: .formatted(formatter))
        
        _testRoundTrip(of: TopLevelWrapper(timestamp),
                       expectedValue: expectedValue,
                       dateEncodingStrategy: .formatted(formatter),
                       dateDecodingStrategy: .formatted(formatter))
        
        _testRoundTrip(of: OptionalTopLevelWrapper(timestamp),
                       expectedValue: expectedValue,
                       dateEncodingStrategy: .formatted(formatter),
                       dateDecodingStrategy: .formatted(formatter))
    }
    
    func testEncodingDateCustom() {
        let timestamp = Date()
        
        // We'll encode a number instead of a date.
        let encode = { (_ data: Date, _ encoder: Encoder) throws -> Void in
            var container = encoder.singleValueContainer()
            try container.encode(42)
        }
        let decode = { (_: Decoder) throws -> Date in return timestamp }
        let expectedValue = ["value": 42]
        
        _testRoundTrip(of: timestamp,
                       expectedValue: 42,
                       dateEncodingStrategy: .custom(encode),
                       dateDecodingStrategy: .custom(decode))
        
        _testRoundTrip(of: TopLevelWrapper(timestamp),
                       expectedValue: expectedValue,
                       dateEncodingStrategy: .custom(encode),
                       dateDecodingStrategy: .custom(decode))
        
        _testRoundTrip(of: OptionalTopLevelWrapper(timestamp),
                       expectedValue: expectedValue,
                       dateEncodingStrategy: .custom(encode),
                       dateDecodingStrategy: .custom(decode))
    }
    
    func testEncodingDateCustomEmpty() {
        let timestamp = Date()
        
        // Encoding nothing should encode an empty keyed container ({}).
        let encode = { (_: Date, _: Encoder) throws -> Void in }
        let decode = { (_: Decoder) throws -> Date in return timestamp }
        let expectedValue = ["value": [:]]
        
        _testRoundTrip(of: TopLevelWrapper(timestamp),
                       expectedValue: expectedValue,
                       dateEncodingStrategy: .custom(encode),
                       dateDecodingStrategy: .custom(decode))
        
        // Optional dates should encode the same way.
        _testRoundTrip(of: OptionalTopLevelWrapper(timestamp),
                       expectedValue: expectedValue,
                       dateEncodingStrategy: .custom(encode),
                       dateDecodingStrategy: .custom(decode))
    }
    
    // MARK: - Data Strategy Tests
    func testEncodingData() {
        let data = Data(bytes: [0xDE, 0xAD, 0xBE, 0xEF])
        let expectedValue = ["value":[222,173,190,239]]
        
        _testRoundTrip(of: data,
                       expectedValue: [222,173,190,239],
                       dataEncodingStrategy: .deferredToData,
                       dataDecodingStrategy: .deferredToData)
        
        _testRoundTrip(of: TopLevelWrapper(data),
                       expectedValue: expectedValue,
                       dataEncodingStrategy: .deferredToData,
                       dataDecodingStrategy: .deferredToData)
        
        // Optional data should encode the same way.
        _testRoundTrip(of: OptionalTopLevelWrapper(data),
                       expectedValue: expectedValue,
                       dataEncodingStrategy: .deferredToData,
                       dataDecodingStrategy: .deferredToData)
    }
    
    func testEncodingDataBase64() {
        let data = Data(bytes: [0xDE, 0xAD, 0xBE, 0xEF])
        let expectedValue = ["value":"3q2+7w=="]
        
        _testRoundTrip(of: data, expectedValue: "3q2+7w==")
        _testRoundTrip(of: TopLevelWrapper(data), expectedValue: expectedValue)
        _testRoundTrip(of: OptionalTopLevelWrapper(data), expectedValue: expectedValue)
    }
    
    func testEncodingDataCustom() {
        // We'll encode a number instead of data.
        let encode = { (_ data: Data, _ encoder: Encoder) throws -> Void in
            var container = encoder.singleValueContainer()
            try container.encode(42)
        }
        let decode = { (_: Decoder) throws -> Data in return Data() }
        let expectedValue = ["value": 42]
        
        _testRoundTrip(of: Data(),
                       expectedValue: 42,
                       dataEncodingStrategy: .custom(encode),
                       dataDecodingStrategy: .custom(decode))
        
        _testRoundTrip(of: TopLevelWrapper(Data()),
                       expectedValue: expectedValue,
                       dataEncodingStrategy: .custom(encode),
                       dataDecodingStrategy: .custom(decode))
        
        // Optional data should encode the same way.
        _testRoundTrip(of: OptionalTopLevelWrapper(Data()),
                       expectedValue: expectedValue,
                       dataEncodingStrategy: .custom(encode),
                       dataDecodingStrategy: .custom(decode))
    }
    
    func testEncodingDataCustomEmpty() {
        // Encoding nothing should encode an empty keyed container ({}).
        let encode = { (_: Data, _: Encoder) throws -> Void in }
        let decode = { (_: Decoder) throws -> Data in return Data() }
        let expectedValue = ["value": [:]]
        
        _testRoundTrip(of: Data(),
                       expectedValue: [:],
                       dataEncodingStrategy: .custom(encode),
                       dataDecodingStrategy: .custom(decode))
        
        _testRoundTrip(of: TopLevelWrapper(Data()),
                       expectedValue: expectedValue,
                       dataEncodingStrategy: .custom(encode),
                       dataDecodingStrategy: .custom(decode))
        
        // Optional Data should encode the same way.
        _testRoundTrip(of: OptionalTopLevelWrapper(Data()),
                       expectedValue: expectedValue,
                       dataEncodingStrategy: .custom(encode),
                       dataDecodingStrategy: .custom(decode))
    }
    
    // MARK: - Encoder Features
    func testNestedContainerCodingPaths() {
        let encoder = FirebaseEncoder()
        do {
            let _ = try encoder.encode(NestedContainersTestType())
        } catch let error as NSError {
            XCTFail("Caught error during encoding nested container types: \(error)")
        }
    }
    
    func testSuperEncoderCodingPaths() {
        let encoder = FirebaseEncoder()
        do {
            let _ = try encoder.encode(NestedContainersTestType(testSuperEncoder: true))
        } catch let error as NSError {
            XCTFail("Caught error during encoding nested container types: \(error)")
        }
    }
    
    func testInterceptURL() {
        // Want to make sure JSONEncoder writes out single-value URLs, not the keyed encoding.
        let expectedValue = ["value": "http://swift.org"]
        let url = URL(string: "http://swift.org")!
        _testRoundTrip(of: url, expectedValue: "http://swift.org")
        _testRoundTrip(of: TopLevelWrapper(url), expectedValue: expectedValue)
        _testRoundTrip(of: OptionalTopLevelWrapper(url), expectedValue: expectedValue)
    }
    
    func testTypeCoercion() {
        _testRoundTripTypeCoercionFailure(of: [false, true], as: [Int].self)
        _testRoundTripTypeCoercionFailure(of: [false, true], as: [Int8].self)
        _testRoundTripTypeCoercionFailure(of: [false, true], as: [Int16].self)
        _testRoundTripTypeCoercionFailure(of: [false, true], as: [Int32].self)
        _testRoundTripTypeCoercionFailure(of: [false, true], as: [Int64].self)
        _testRoundTripTypeCoercionFailure(of: [false, true], as: [UInt].self)
        _testRoundTripTypeCoercionFailure(of: [false, true], as: [UInt8].self)
        _testRoundTripTypeCoercionFailure(of: [false, true], as: [UInt16].self)
        _testRoundTripTypeCoercionFailure(of: [false, true], as: [UInt32].self)
        _testRoundTripTypeCoercionFailure(of: [false, true], as: [UInt64].self)
        _testRoundTripTypeCoercionFailure(of: [false, true], as: [Float].self)
        _testRoundTripTypeCoercionFailure(of: [false, true], as: [Double].self)
        _testRoundTripTypeCoercionFailure(of: [0, 1] as [Int], as: [Bool].self)
        _testRoundTripTypeCoercionFailure(of: [0, 1] as [Int8], as: [Bool].self)
        _testRoundTripTypeCoercionFailure(of: [0, 1] as [Int16], as: [Bool].self)
        _testRoundTripTypeCoercionFailure(of: [0, 1] as [Int32], as: [Bool].self)
        _testRoundTripTypeCoercionFailure(of: [0, 1] as [Int64], as: [Bool].self)
        _testRoundTripTypeCoercionFailure(of: [0, 1] as [UInt], as: [Bool].self)
        _testRoundTripTypeCoercionFailure(of: [0, 1] as [UInt8], as: [Bool].self)
        _testRoundTripTypeCoercionFailure(of: [0, 1] as [UInt16], as: [Bool].self)
        _testRoundTripTypeCoercionFailure(of: [0, 1] as [UInt32], as: [Bool].self)
        _testRoundTripTypeCoercionFailure(of: [0, 1] as [UInt64], as: [Bool].self)
        _testRoundTripTypeCoercionFailure(of: [0.0, 1.0] as [Float], as: [Bool].self)
        _testRoundTripTypeCoercionFailure(of: [0.0, 1.0] as [Double], as: [Bool].self)
    }
    
    func testEncodingTopLevelNumericTypes() {
        _testRoundTrip(of: 3 as Int)
        _testRoundTrip(of: 3 as Int8)
        _testRoundTrip(of: 3 as Int16)
        _testRoundTrip(of: 3 as Int32)
        _testRoundTrip(of: 3 as Int64)
        _testRoundTrip(of: 3 as UInt)
        _testRoundTrip(of: 3 as UInt8)
        _testRoundTrip(of: 3 as UInt16)
        _testRoundTrip(of: 3 as UInt32)
        _testRoundTrip(of: 3 as UInt64)
        _testRoundTrip(of: 3 as Float)
        _testRoundTrip(of: 3 as Double)
    }
    
    // MARK: - GeoPoint
    func testEncodingGeoPoint() {
        let point = Point(latitude: 2, longitude: 2)
        XCTAssertEqual((try? FirebaseEncoder().encode(point)) as? NSDictionary, ["latitude": 2, "longitude": 2])
        XCTAssertEqual(try? FirebaseDecoder().decode(Point.self, from: ["latitude": 2, "longitude": 2]), point)
    }
    
    // MARK: - Document Reference
    func testEncodingDocumentReference() {
        XCTAssertThrowsError(try FirebaseEncoder().encode(DocumentReference()))
        XCTAssertThrowsError(try FirebaseDecoder().decode(DocumentReference.self, from: []))
    }
    
    // MARK: - Helper Functions
    private var _emptyDictionary: [String: Any] = [:]
    
    private func _testRoundTrip<T>(of value: T,
                                   expectedValue json: Any? = nil,
                                   dateEncodingStrategy: FirebaseEncoder.DateEncodingStrategy = .deferredToDate,
                                   dateDecodingStrategy: FirebaseDecoder.DateDecodingStrategy = .deferredToDate,
                                   dataEncodingStrategy: FirebaseEncoder.DataEncodingStrategy = .base64,
                                   dataDecodingStrategy: FirebaseDecoder.DataDecodingStrategy = .base64) where T : Codable, T : Equatable {
        var payload: Any! = nil
        do {
            let encoder = FirebaseEncoder()
            encoder.dateEncodingStrategy = dateEncodingStrategy
            encoder.dataEncodingStrategy = dataEncodingStrategy
            payload = try encoder.encode(value)
        } catch {
            XCTFail("Failed to encode \(T.self) to val: \(error)")
        }
        
        if let expectedJSON = json.flatMap({ $0 as? NSObject }), let payload = payload as? NSObject {
            XCTAssertEqual(expectedJSON, payload, "Produced value not identical to expected value.")
        }
        
        do {
            let decoder = FirebaseDecoder()
            decoder.dateDecodingStrategy = dateDecodingStrategy
            decoder.dataDecodingStrategy = dataDecodingStrategy
            let decoded = try decoder.decode(T.self, from: payload)
            XCTAssertEqual(decoded, value, "\(T.self) did not round-trip to an equal value.")
        } catch {
            XCTFail("Failed to decode \(T.self) from val: \(error)")
        }
    }
    
    private func _testRoundTripTypeCoercionFailure<T,U>(of value: T, as type: U.Type) where T : Codable, U : Codable {
        do {
            let data = try FirebaseEncoder().encode(value)
            let _ = try FirebaseDecoder().decode(U.self, from: data)
            XCTFail("Coercion from \(T.self) to \(U.self) was expected to fail.")
        } catch {}
    }
}

// MARK: - Test Types
/* FIXME: Import from %S/Inputs/Coding/SharedTypes.swift somehow. */

// MARK: - GeoPoint
struct Point: GeoPointType, Equatable {
    let latitude: Double
    let longitude: Double
    
    static func == (lhs: Point, rhs: Point) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

// MARK: - ReferenceType
fileprivate struct DocumentReference: DocumentReferenceType {}

// MARK: - Empty Types
fileprivate struct EmptyStruct : Codable, Equatable {
    static func ==(_ lhs: EmptyStruct, _ rhs: EmptyStruct) -> Bool {
        return true
    }
}

fileprivate class EmptyClass : Codable, Equatable {
    static func ==(_ lhs: EmptyClass, _ rhs: EmptyClass) -> Bool {
        return true
    }
}

// MARK: - Single-Value Types
/// A simple on-off switch type that encodes as a single Bool value.
fileprivate enum Switch : Codable {
    case off
    case on
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        switch try container.decode(Bool.self) {
        case false: self = .off
        case true:  self = .on
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .off: try container.encode(false)
        case .on:  try container.encode(true)
        }
    }
}

/// A simple timestamp type that encodes as a single Double value.
fileprivate struct Timestamp : Codable, Equatable {
    let value: Double
    
    init(_ value: Double) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try container.decode(Double.self)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.value)
    }
    
    static func ==(_ lhs: Timestamp, _ rhs: Timestamp) -> Bool {
        return lhs.value == rhs.value
    }
}

fileprivate struct FirTimestamp : TimestampType, Equatable {
    let date: Date
  
    init(date: Date) {
        self.date = date
    }
  
    func dateValue() -> Date {
        return date
    }
  
    static func == (_ lhs: FirTimestamp, _ rhs: FirTimestamp) -> Bool {
        return lhs.date == rhs.date
    }
}

/// A simple referential counter type that encodes as a single Int value.
fileprivate final class Counter : Codable, Equatable {
    var count: Int = 0
    
    init() {}
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        count = try container.decode(Int.self)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.count)
    }
    
    static func ==(_ lhs: Counter, _ rhs: Counter) -> Bool {
        return lhs === rhs || lhs.count == rhs.count
    }
}

// MARK: - Structured Types
/// A simple address type that encodes as a dictionary of values.
fileprivate struct Address : Codable, Equatable {
    let street: String
    let city: String
    let state: String
    let zipCode: Int
    let country: String
    
    init(street: String, city: String, state: String, zipCode: Int, country: String) {
        self.street = street
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.country = country
    }
    
    static func ==(_ lhs: Address, _ rhs: Address) -> Bool {
        return lhs.street == rhs.street &&
            lhs.city == rhs.city &&
            lhs.state == rhs.state &&
            lhs.zipCode == rhs.zipCode &&
            lhs.country == rhs.country
    }
    
    static var testValue: Address {
        return Address(street: "1 Infinite Loop",
                       city: "Cupertino",
                       state: "CA",
                       zipCode: 95014,
                       country: "United States")
    }
}

/// A simple person class that encodes as a dictionary of values.
fileprivate class Person : Codable, Equatable {
    let name: String
    let email: String
    let website: URL?
    
    init(name: String, email: String, website: URL? = nil) {
        self.name = name
        self.email = email
        self.website = website
    }
    
    private enum CodingKeys : String, CodingKey {
        case name
        case email
        case website
    }
    
    // FIXME: Remove when subclasses (Employee) are able to override synthesized conformance.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        email = try container.decode(String.self, forKey: .email)
        website = try container.decodeIfPresent(URL.self, forKey: .website)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
        try container.encodeIfPresent(website, forKey: .website)
    }
    
    func isEqual(_ other: Person) -> Bool {
        return self.name == other.name &&
            self.email == other.email &&
            self.website == other.website
    }
    
    static func ==(_ lhs: Person, _ rhs: Person) -> Bool {
        return lhs.isEqual(rhs)
    }
    
    class var testValue: Person {
        return Person(name: "Johnny Appleseed", email: "appleseed@apple.com")
    }
}

/// A class which shares its encoder and decoder with its superclass.
fileprivate class Employee : Person {
    let id: Int
    
    init(name: String, email: String, website: URL? = nil, id: Int) {
        self.id = id
        super.init(name: name, email: email, website: website)
    }
    
    enum CodingKeys : String, CodingKey {
        case id
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try super.encode(to: encoder)
    }
    
    override func isEqual(_ other: Person) -> Bool {
        if let employee = other as? Employee {
            guard self.id == employee.id else { return false }
        }
        
        return super.isEqual(other)
    }
    
    override class var testValue: Employee {
        return Employee(name: "Johnny Appleseed", email: "appleseed@apple.com", id: 42)
    }
}

/// A simple company struct which encodes as a dictionary of nested values.
fileprivate struct Company : Codable, Equatable {
    let address: Address
    var employees: [Employee]
    
    init(address: Address, employees: [Employee]) {
        self.address = address
        self.employees = employees
    }
    
    static func ==(_ lhs: Company, _ rhs: Company) -> Bool {
        return lhs.address == rhs.address && lhs.employees == rhs.employees
    }
    
    static var testValue: Company {
        return Company(address: Address.testValue, employees: [Employee.testValue])
    }
}

/// An enum type which decodes from Bool?.
fileprivate enum EnhancedBool : Codable {
    case `true`
    case `false`
    case fileNotFound
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .fileNotFound
        } else {
            let value = try container.decode(Bool.self)
            self = value ? .true : .false
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .true: try container.encode(true)
        case .false: try container.encode(false)
        case .fileNotFound: try container.encodeNil()
        }
    }
}

/// A type which encodes as an array directly through a single value container.
struct Numbers : Codable, Equatable {
    let values = [4, 8, 15, 16, 23, 42]
    
    init() {}
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let decodedValues = try container.decode([Int].self)
        guard decodedValues == values else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "The Numbers are wrong!"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(values)
    }
    
    static func ==(_ lhs: Numbers, _ rhs: Numbers) -> Bool {
        return lhs.values == rhs.values
    }
    
    static var testValue: Numbers {
        return Numbers()
    }
}

/// A type which encodes as a dictionary directly through a single value container.
fileprivate final class Mapping : Codable, Equatable {
    let values: [String : URL]
    
    init(values: [String : URL]) {
        self.values = values
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        values = try container.decode([String : URL].self)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(values)
    }
    
    static func ==(_ lhs: Mapping, _ rhs: Mapping) -> Bool {
        return lhs === rhs || lhs.values == rhs.values
    }
    
    static var testValue: Mapping {
        return Mapping(values: ["Apple": URL(string: "http://apple.com")!,
                                "localhost": URL(string: "http://127.0.0.1")!])
    }
}

struct NestedContainersTestType : Encodable {
    let testSuperEncoder: Bool
    
    init(testSuperEncoder: Bool = false) {
        self.testSuperEncoder = testSuperEncoder
    }
    
    enum TopLevelCodingKeys : Int, CodingKey {
        case a
        case b
        case c
    }
    
    enum IntermediateCodingKeys : Int, CodingKey {
        case one
        case two
    }
    
    func encode(to encoder: Encoder) throws {
        if self.testSuperEncoder {
            var topLevelContainer = encoder.container(keyedBy: TopLevelCodingKeys.self)
            expectEqualPaths(encoder.codingPath, [], "Top-level Encoder's codingPath changed.")
            expectEqualPaths(topLevelContainer.codingPath, [], "New first-level keyed container has non-empty codingPath.")
            
            let superEncoder = topLevelContainer.superEncoder(forKey: .a)
            expectEqualPaths(encoder.codingPath, [], "Top-level Encoder's codingPath changed.")
            expectEqualPaths(topLevelContainer.codingPath, [], "First-level keyed container's codingPath changed.")
            expectEqualPaths(superEncoder.codingPath, [TopLevelCodingKeys.a], "New superEncoder had unexpected codingPath.")
            _testNestedContainers(in: superEncoder, baseCodingPath: [TopLevelCodingKeys.a])
        } else {
            _testNestedContainers(in: encoder, baseCodingPath: [])
        }
    }
    
    func _testNestedContainers(in encoder: Encoder, baseCodingPath: [CodingKey]) {
        expectEqualPaths(encoder.codingPath, baseCodingPath, "New encoder has non-empty codingPath.")
        
        // codingPath should not change upon fetching a non-nested container.
        var firstLevelContainer = encoder.container(keyedBy: TopLevelCodingKeys.self)
        expectEqualPaths(encoder.codingPath, baseCodingPath, "Top-level Encoder's codingPath changed.")
        expectEqualPaths(firstLevelContainer.codingPath, baseCodingPath, "New first-level keyed container has non-empty codingPath.")
        
        // Nested Keyed Container
        do {
            // Nested container for key should have a new key pushed on.
            var secondLevelContainer = firstLevelContainer.nestedContainer(keyedBy: IntermediateCodingKeys.self, forKey: .a)
            expectEqualPaths(encoder.codingPath, baseCodingPath, "Top-level Encoder's codingPath changed.")
            expectEqualPaths(firstLevelContainer.codingPath, baseCodingPath, "First-level keyed container's codingPath changed.")
            expectEqualPaths(secondLevelContainer.codingPath, baseCodingPath + [TopLevelCodingKeys.a], "New second-level keyed container had unexpected codingPath.")
            
            // Inserting a keyed container should not change existing coding paths.
            let thirdLevelContainerKeyed = secondLevelContainer.nestedContainer(keyedBy: IntermediateCodingKeys.self, forKey: .one)
            expectEqualPaths(encoder.codingPath, baseCodingPath, "Top-level Encoder's codingPath changed.")
            expectEqualPaths(firstLevelContainer.codingPath, baseCodingPath, "First-level keyed container's codingPath changed.")
            expectEqualPaths(secondLevelContainer.codingPath, baseCodingPath + [TopLevelCodingKeys.a], "Second-level keyed container's codingPath changed.")
            expectEqualPaths(thirdLevelContainerKeyed.codingPath, baseCodingPath + [TopLevelCodingKeys.a, IntermediateCodingKeys.one], "New third-level keyed container had unexpected codingPath.")
            
            // Inserting an unkeyed container should not change existing coding paths.
            let thirdLevelContainerUnkeyed = secondLevelContainer.nestedUnkeyedContainer(forKey: .two)
            expectEqualPaths(encoder.codingPath, baseCodingPath + [], "Top-level Encoder's codingPath changed.")
            expectEqualPaths(firstLevelContainer.codingPath, baseCodingPath + [], "First-level keyed container's codingPath changed.")
            expectEqualPaths(secondLevelContainer.codingPath, baseCodingPath + [TopLevelCodingKeys.a], "Second-level keyed container's codingPath changed.")
            expectEqualPaths(thirdLevelContainerUnkeyed.codingPath, baseCodingPath + [TopLevelCodingKeys.a, IntermediateCodingKeys.two], "New third-level unkeyed container had unexpected codingPath.")
        }
        
        // Nested Unkeyed Container
        do {
            // Nested container for key should have a new key pushed on.
            var secondLevelContainer = firstLevelContainer.nestedUnkeyedContainer(forKey: .b)
            expectEqualPaths(encoder.codingPath, baseCodingPath, "Top-level Encoder's codingPath changed.")
            expectEqualPaths(firstLevelContainer.codingPath, baseCodingPath, "First-level keyed container's codingPath changed.")
            expectEqualPaths(secondLevelContainer.codingPath, baseCodingPath + [TopLevelCodingKeys.b], "New second-level keyed container had unexpected codingPath.")
            
            // Appending a keyed container should not change existing coding paths.
            let thirdLevelContainerKeyed = secondLevelContainer.nestedContainer(keyedBy: IntermediateCodingKeys.self)
            expectEqualPaths(encoder.codingPath, baseCodingPath, "Top-level Encoder's codingPath changed.")
            expectEqualPaths(firstLevelContainer.codingPath, baseCodingPath, "First-level keyed container's codingPath changed.")
            expectEqualPaths(secondLevelContainer.codingPath, baseCodingPath + [TopLevelCodingKeys.b], "Second-level unkeyed container's codingPath changed.")
            expectEqualPaths(thirdLevelContainerKeyed.codingPath, baseCodingPath + [TopLevelCodingKeys.b, _TestKey(index: 0)], "New third-level keyed container had unexpected codingPath.")
            
            // Appending an unkeyed container should not change existing coding paths.
            let thirdLevelContainerUnkeyed = secondLevelContainer.nestedUnkeyedContainer()
            expectEqualPaths(encoder.codingPath, baseCodingPath, "Top-level Encoder's codingPath changed.")
            expectEqualPaths(firstLevelContainer.codingPath, baseCodingPath, "First-level keyed container's codingPath changed.")
            expectEqualPaths(secondLevelContainer.codingPath, baseCodingPath + [TopLevelCodingKeys.b], "Second-level unkeyed container's codingPath changed.")
            expectEqualPaths(thirdLevelContainerUnkeyed.codingPath, baseCodingPath + [TopLevelCodingKeys.b, _TestKey(index: 1)], "New third-level unkeyed container had unexpected codingPath.")
        }
    }
}

// MARK: - Helper Types

/// A key type which can take on any string or integer value.
/// This needs to mirror _JSONKey.
fileprivate struct _TestKey : CodingKey {
    var stringValue: String
    var intValue: Int?
    
    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
    
    init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
    
    init(index: Int) {
        self.stringValue = "Index \(index)"
        self.intValue = index
    }
}

/// Wraps a type T (as T?) so that it can be encoded at the top level of a payload.
fileprivate struct OptionalTopLevelWrapper<T> : Codable, Equatable where T : Codable, T : Equatable {
    let value: T?
    
    init(_ value: T) {
        self.value = value
    }
    
    // Provide an implementation of Codable to encode(forKey:) instead of encodeIfPresent(forKey:).
    private enum CodingKeys : String, CodingKey {
        case value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = try container.decode(T?.self, forKey: .value)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
    }
    
    static func ==(_ lhs: OptionalTopLevelWrapper<T>, _ rhs: OptionalTopLevelWrapper<T>) -> Bool {
        return lhs.value == rhs.value
    }
}
