//
//  FirebaseDecoder.swift
//  CodableFirebase
//
//  Created by Oleksii on 27/12/2017.
//  Copyright © 2017 ViolentOctopus. All rights reserved.
//

import Foundation

open class FirebaseDecoder {
    public init() {}
    
    open var userInfo: [CodingUserInfoKey: Any] = [:]

    public var dateDecodingStrategy: DateDecodingStrategy {
        set {
            userInfo[.dateDecodingStrategy] = newValue
        }
        get {
            if let strategy = userInfo[.dateDecodingStrategy] as? DateDecodingStrategy {
                return strategy
            }
            return .deferredToDate
        }
    }

    public var dataDecodingStrategy: DataDecodingStrategy {
        set {
            userInfo[.dataDecodingStrategy] = newValue
        }
        get {
            if let strategy = userInfo[.dataDecodingStrategy] as? DataDecodingStrategy {
                return strategy
            }
            return .deferredToData
        }
    }

    open func decode<T : Decodable>(_ type: T.Type, from container: Any) throws -> T {
        let decoder = _FirebaseDecoder(referencing: container, userInfo: userInfo)
        guard let value = try decoder.unbox(container, as: T.self) else {
            throw DecodingError.valueNotFound(T.self, DecodingError.Context(codingPath: [], debugDescription: "The given dictionary was invalid"))
        }
        
        return value
    }
}
