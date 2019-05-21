//
//  FirebaseEncoder.swift
//  CodableFirebase
//
//  Created by Oleksii on 27/12/2017.
//  Copyright © 2017 ViolentOctopus. All rights reserved.
//

import Foundation

open class FirebaseEncoder {
    public init() {}
    
    open var userInfo: [CodingUserInfoKey : Any] = [:]

    open func encode<Value : Encodable>(_ value: Value) throws -> Any {
        let encoder = _FirebaseEncoder(userInfo: userInfo)
        guard let topLevel = try encoder.box_(value) else {
            throw EncodingError.invalidValue(value,
                                             EncodingError.Context(codingPath: [],
                                                                   debugDescription: "Top-level \(Value.self) did not encode any values."))
        }
        
        return topLevel
    }
}
