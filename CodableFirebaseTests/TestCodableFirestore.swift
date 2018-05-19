//
//  TestCodableFirestore.swift
//  SlapTests
//
//  Created by Oleksii on 20/10/2017.
//  Copyright © 2017 Slap. All rights reserved.
//

import XCTest
import CodableFirebase

fileprivate struct Document: Codable, Equatable {
    let stringExample: String
    let booleanExample: Bool
    let numberExample: Double
    let dateExample: Date
    let arrayExample: [String]
    let nullExample: Int?
    let objectExample: [String: String]
    
    static func == (lhs: Document, rhs: Document) -> Bool {
        return lhs.stringExample == rhs.stringExample
            && lhs.booleanExample == rhs.booleanExample
            && lhs.numberExample == rhs.numberExample
            && lhs.dateExample == rhs.dateExample
            && lhs.arrayExample == rhs.arrayExample
            && lhs.nullExample == rhs.nullExample
            && lhs.objectExample == rhs.objectExample
    }
}

/// Wraps a type T so that it can be encoded at the top level of a payload.
struct TopLevelWrapper<T> : Codable, Equatable where T : Codable, T : Equatable {
    enum CodingKeys : String, CodingKey {
        case value
    }
    
    let value: T
    
    init(_ value: T) {
        self.value = value
    }
    
    static func ==(_ lhs: TopLevelWrapper<T>, _ rhs: TopLevelWrapper<T>) -> Bool {
        return lhs.value == rhs.value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = try container.decode(T.self, forKey: .value)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
    }
}

class TestCodableFirestore: XCTestCase {
    
    func testFirebaseEncoder() {
        let model = Document(
            stringExample: "Hello world!",
            booleanExample: true,
            numberExample: 3.14159265,
            dateExample: Date(),
            arrayExample: ["hello", "world"],
            nullExample: nil,
            objectExample: ["objectExample": "one"]
        )
        
        let dict: [String : Any] = [
            "stringExample": "Hello world!",
            "booleanExample": true,
            "numberExample": 3.14159265,
            "dateExample": model.dateExample,
            "arrayExample": ["hello", "world"],
            "objectExample": ["objectExample": "one"]
        ]
        
        XCTAssertEqual((try FirestoreEncoder().encode(model)) as NSDictionary, dict as NSDictionary)
        XCTAssertEqual(try? FirestoreDecoder().decode(Document.self, from: dict) , model)
    }
    
    // MARK: - Encoder Features
    func testNestedContainerCodingPaths() {
        do {
            let _ = try FirestoreEncoder().encode(NestedContainersTestType())
        } catch let error as NSError {
            XCTFail("Caught error during encoding nested container types: \(error)")
        }
    }
    
    func testSuperEncoderCodingPaths() {
        do {
            let _ = try FirestoreEncoder().encode(NestedContainersTestType(testSuperEncoder: true))
        } catch let error as NSError {
            XCTFail("Caught error during encoding nested container types: \(error)")
        }
    }
    
    func testInterceptData() {
        let data = try! JSONSerialization.data(withJSONObject: [], options: [])
        _testRoundTrip(of: TopLevelWrapper(data), expected: ["value": data])
    }
    
    func testInterceptDate() {
        let date = Date(timeIntervalSinceReferenceDate: 0)
        _testRoundTrip(of: TopLevelWrapper(date), expected: ["value": date])
    }
    
    func testDecimalValue() {
        let value = Decimal(2)
        _testRoundTrip(of: TopLevelWrapper(value), expected: ["value": value])
    }
    
    // MARK: - GeoPoint & Document Reference
    func testEncodingGeoPoint() {
        let point = GeoPoint(latitude: 2, longitude: 2)
        let wrapper = TopLevelWrapper(point)
        XCTAssertEqual((try? FirestoreEncoder().encode(wrapper)) as NSDictionary?, ["value": point])
        XCTAssertEqual(try? FirestoreDecoder().decode(TopLevelWrapper<GeoPoint>.self, from: ["value": point]), wrapper)
        XCTAssertThrowsError(try FirestoreEncoder().encode(TopLevelWrapper(Point(latitude: 2, longitude: 2))))
    }
    
    func testEncodingDocumentReference() {
        let val = TopLevelWrapper(DocumentReference())
        XCTAssertEqual((try? FirestoreEncoder().encode(val)) as NSDictionary?, ["value": val.value])
        XCTAssertEqual(try? FirestoreDecoder().decode(TopLevelWrapper<DocumentReference>.self, from: ["value": val.value]), val)
    }
  
    func testEncodingTimestamp() {
        let timestamp = Timestamp(date: Date())
        let wrapper = TopLevelWrapper(timestamp)
        XCTAssertEqual((try? FirestoreEncoder().encode(wrapper)) as NSDictionary?, ["value": timestamp])
        XCTAssertEqual(try? FirestoreDecoder().decode(TopLevelWrapper<Timestamp>.self, from: ["value": timestamp]), wrapper)
    }
  
    private func _testEncodeFailure<T : Encodable>(of value: T) {
        do {
            let _ = try FirestoreEncoder().encode(value)
            XCTFail("Encode of top-level \(T.self) was expected to fail.")
        } catch {}
    }
    
    private func _testRoundTrip<T>(of value: T, expected dict: [String: Any]? = nil) where T : Codable, T : Equatable {
        var payload: [String: Any]! = nil
        do {
            payload = try FirestoreEncoder().encode(value)
        } catch {
            XCTFail("Failed to encode \(T.self) to plist: \(error)")
        }
        
        if let expectedDict = dict {
            XCTAssertEqual(payload as NSDictionary, expectedDict as NSDictionary, "Produced dictionary not identical to expected dictionary")
        }
        
        do {
            let decoded = try FirestoreDecoder().decode(T.self, from: payload)
            XCTAssertEqual(decoded, value, "\(T.self) did not round-trip to an equal value.")
        } catch {
            XCTFail("Failed to decode \(T.self) from plist: \(error)")
        }
    }
}

func expectEqualPaths(_ lhs: [CodingKey], _ rhs: [CodingKey], _ prefix: String) {
    if lhs.count != rhs.count {
        XCTFail("\(prefix) [CodingKey].count mismatch: \(lhs.count) != \(rhs.count)")
        return
    }
    
    for (key1, key2) in zip(lhs, rhs) {
        switch (key1.intValue, key2.intValue) {
        case (.none, .none): break
        case (.some(let i1), .none):
            XCTFail("\(prefix) CodingKey.intValue mismatch: \(type(of: key1))(\(i1)) != nil")
            return
        case (.none, .some(let i2)):
            XCTFail("\(prefix) CodingKey.intValue mismatch: nil != \(type(of: key2))(\(i2))")
            return
        case (.some(let i1), .some(let i2)):
            guard i1 == i2 else {
                XCTFail("\(prefix) CodingKey.intValue mismatch: \(type(of: key1))(\(i1)) != \(type(of: key2))(\(i2))")
                return
            }
            
            break
        }
        
        XCTAssertEqual(key1.stringValue, key2.stringValue, "\(prefix) CodingKey.stringValue mismatch: \(type(of: key1))('\(key1.stringValue)') != \(type(of: key2))('\(key2.stringValue)')")
    }
}

// MARK: - GeioPoint
fileprivate class GeoPoint: NSObject, GeoPointType {
    let latitude: Double
    let longitude: Double
    
    required init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object.flatMap({ $0 as? GeoPoint }) else { return false }
        return latitude == other.latitude && longitude == other.longitude
    }
}

// MARK: - ReferenceType
fileprivate class DocumentReference: NSObject, DocumentReferenceType {}

// MARK: - Timestamp
fileprivate class Timestamp: NSObject, TimestampType {
    let date: Date
  
    required init(date: Date) {
        self.date = date
    }
  
    func dateValue() -> Date {
        return date
    }
  
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object.flatMap({ $0 as? Timestamp }) else { return false }
        return date == other.date
    }
}
