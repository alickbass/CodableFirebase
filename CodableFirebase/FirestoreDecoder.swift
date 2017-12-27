//
//  FirestoreDecoder.swift
//  Slap
//
//  Created by Oleksii on 21/10/2017.
//  Copyright © 2017 Slap. All rights reserved.
//

import Foundation

open class FirestoreDecoder {
    public init() {}
    
    open var userInfo: [CodingUserInfoKey : Any] = [:]
    
    open func decode<T : Decodable>(_ type: T.Type, from container: [String: Any]) throws -> T {
        let options = _FirebaseDecoder._Options(dateDecodingStrategy: nil, dataDecodingStrategy: nil, userInfo: userInfo)
        let decoder = _FirebaseDecoder(referencing: container, options: options)
        guard let value = try decoder.unbox(container, as: T.self) else {
            throw DecodingError.valueNotFound(T.self, DecodingError.Context(codingPath: [], debugDescription: "The given dictionary was invalid"))
        }
        
        return value
    }
}
