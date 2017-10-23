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
    
}
