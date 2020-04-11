//
//  CodaleTests.swift
//  CodableFirebaseTests
//
//  Created by Oleksii on 27/12/2017.
//  Copyright © 2017 ViolentOctopus. All rights reserved.
//

import XCTest
import CodableFirebase

func debugDescription<T>(_ value: T) -> String {
    if let debugDescribable = value as? CustomDebugStringConvertible {
        return debugDescribable.debugDescription
    } else if let describable = value as? CustomStringConvertible {
        return describable.description
    } else {
        return "\(value)"
    }
}

func expectRoundTripEquality<T : Codable>(of value: T, encode: (T) throws -> Any, decode: (Any) throws -> T, lineNumber: Int) where T : Equatable {
    let data: Any
    do {
        data = try encode(value)
    } catch {
        fatalError("\(#file):\(lineNumber): Unable to encode \(T.self) <\(debugDescription(value))>: \(error)")
    }
    
    let decoded: T
    do {
        decoded = try decode(data as! NSObject)
    } catch {
        fatalError("\(#file):\(lineNumber): Unable to decode \(T.self) <\(debugDescription(value))>: \(error)")
    }
    
    XCTAssertEqual(value, decoded, "\(#file):\(lineNumber): Decoded \(T.self) <\(debugDescription(decoded))> not equal to original <\(debugDescription(value))>")
}

func expectRoundTripEqualityThroughFirebaseDatabase<T : Codable>(for value: T, lineNumber: Int) where T : Equatable {
    let encode = { (_ value: T) throws -> Any in
        return try FirebaseEncoder().encode(value) as! NSObject
    }
    
    let decode = { (_ data: Any) throws -> T in
        return try FirebaseDecoder().decode(T.self, from: data)
    }
    
    expectRoundTripEquality(of: value, encode: encode, decode: decode, lineNumber: lineNumber)
}

// MARK: - Helper Types
// A wrapper around a UUID that will allow it to be encoded at the top level of an encoder.
struct UUIDCodingWrapper : Codable, Equatable {
    let value: UUID
    
    init(_ value: UUID) {
        self.value = value
    }
    
    static func ==(_ lhs: UUIDCodingWrapper, _ rhs: UUIDCodingWrapper) -> Bool {
        return lhs.value == rhs.value
    }
}

class CodaleTests: XCTestCase {
    
    // MARK: - Calendar
    lazy var calendarValues: [Int : Calendar] = [
        #line : Calendar(identifier: .gregorian),
        #line : Calendar(identifier: .buddhist),
        #line : Calendar(identifier: .chinese),
        #line : Calendar(identifier: .coptic),
        #line : Calendar(identifier: .ethiopicAmeteMihret),
        #line : Calendar(identifier: .ethiopicAmeteAlem),
        #line : Calendar(identifier: .hebrew),
        #line : Calendar(identifier: .iso8601),
        #line : Calendar(identifier: .indian),
        #line : Calendar(identifier: .islamic),
        #line : Calendar(identifier: .islamicCivil),
        #line : Calendar(identifier: .japanese),
        #line : Calendar(identifier: .persian),
        #line : Calendar(identifier: .republicOfChina),
    ]
    
    func test_Calendar_Database() {
        for (testLine, calendar) in calendarValues {
            expectRoundTripEqualityThroughFirebaseDatabase(for: calendar, lineNumber: testLine)
        }
    }
    
    // MARK: - CharacterSet
    lazy var characterSetValues: [Int : CharacterSet] = [
        #line : CharacterSet.controlCharacters,
        #line : CharacterSet.whitespaces,
        #line : CharacterSet.whitespacesAndNewlines,
        #line : CharacterSet.decimalDigits,
        #line : CharacterSet.letters,
        #line : CharacterSet.lowercaseLetters,
        #line : CharacterSet.uppercaseLetters,
        #line : CharacterSet.nonBaseCharacters,
        #line : CharacterSet.alphanumerics,
        #line : CharacterSet.decomposables,
        #line : CharacterSet.illegalCharacters,
        #line : CharacterSet.punctuationCharacters,
        #line : CharacterSet.capitalizedLetters,
        #line : CharacterSet.symbols,
        #line : CharacterSet.newlines
    ]
    
    func test_CharacterSet_Database() {
        for (testLine, characterSet) in characterSetValues {
            expectRoundTripEqualityThroughFirebaseDatabase(for: characterSet, lineNumber: testLine)
        }
    }
    
    // MARK: - CGAffineTransform
    lazy var cg_affineTransformValues: [Int : CGAffineTransform] = {
        var values = [
            #line : CGAffineTransform.identity,
            #line : CGAffineTransform(),
            #line : CGAffineTransform(translationX: 2.0, y: 2.0),
            #line : CGAffineTransform(scaleX: 2.0, y: 2.0),
            #line : CGAffineTransform(a: 1.0, b: 2.5, c: 66.2, d: 40.2, tx: -5.5, ty: 3.7),
            #line : CGAffineTransform(a: -55.66, b: 22.7, c: 1.5, d: 0.0, tx: -22, ty: -33),
            #line : CGAffineTransform(a: 4.5, b: 1.1, c: 0.025, d: 0.077, tx: -0.55, ty: 33.2),
            #line : CGAffineTransform(a: 7.0, b: -2.3, c: 6.7, d: 0.25, tx: 0.556, ty: 0.99),
            #line : CGAffineTransform(a: 0.498, b: -0.284, c: -0.742, d: 0.3248, tx: 12, ty: 44)
        ]
        
        if #available(OSX 10.13, iOS 11.0, watchOS 4.0, tvOS 11.0, *) {
            values[#line] = CGAffineTransform(rotationAngle: .pi / 2)
        }
        
        return values
    }()
    
    func test_CGAffineTransform_Database() {
        for (testLine, transform) in cg_affineTransformValues {
            expectRoundTripEqualityThroughFirebaseDatabase(for: transform, lineNumber: testLine)
        }
    }
    
    // MARK: - DateComponents
    lazy var dateComponents: Set<Calendar.Component> = [
        .era, .year, .month, .day, .hour, .minute, .second, .nanosecond,
        .weekday, .weekdayOrdinal, .quarter, .weekOfMonth, .weekOfYear,
        .yearForWeekOfYear, .timeZone, .calendar
    ]
    
    func test_DateComponents_Database() {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(dateComponents, from: Date())
        expectRoundTripEqualityThroughFirebaseDatabase(for: components, lineNumber: #line - 1)
    }
    
    // MARK: - URL
    lazy var urlValues: [Int : URL] = {
        var values: [Int : URL] = [
            #line : URL(fileURLWithPath: NSTemporaryDirectory()),
            #line : URL(fileURLWithPath: "/"),
            #line : URL(string: "http://swift.org")!,
            #line : URL(string: "documentation", relativeTo: URL(string: "http://swift.org")!)!
        ]
        
        if #available(OSX 10.11, iOS 9.0, *) {
            values[#line] = URL(fileURLWithPath: "bin/sh", relativeTo: URL(fileURLWithPath: "/"))
        }
        
        return values
    }()
    
    func test_URL_Database() {
        for (testLine, url) in urlValues {
            // URLs encode as single strings in JSON. They lose their baseURL this way.
            // For relative URLs, we don't expect them to be equal to the original.
            if url.baseURL == nil {
                // This is an absolute URL; we can expect equality.
                expectRoundTripEqualityThroughFirebaseDatabase(for: TopLevelWrapper(url), lineNumber: testLine)
            } else {
                // This is a relative URL. Make it absolute first.
                let absoluteURL = URL(string: url.absoluteString)!
                expectRoundTripEqualityThroughFirebaseDatabase(for: TopLevelWrapper(absoluteURL), lineNumber: testLine)
            }
        }
    }
    
    // MARK: - UUID
    lazy var uuidValues: [Int : UUID] = [
        #line : UUID(),
        #line : UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
        #line : UUID(uuidString: "e621e1f8-c36c-495a-93fc-0c247a3e6e5f")!,
        #line : UUID(uuid: uuid_t(0xe6,0x21,0xe1,0xf8,0xc3,0x6c,0x49,0x5a,0x93,0xfc,0x0c,0x24,0x7a,0x3e,0x6e,0x5f))
    ]
    
    func test_UUID_Database() {
        for (testLine, uuid) in uuidValues {
            // We have to wrap the UUID since we cannot have a top-level string.
            expectRoundTripEqualityThroughFirebaseDatabase(for: UUIDCodingWrapper(uuid), lineNumber: testLine)
        }
    }
}
