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
    
    open func decode<T : Decodable>(_ type: T.Type, from container: [String: Any]) throws -> T {
        let decoder = _FirebaseDecoder(referencing: container)
        guard let value = try decoder.unbox(container, as: T.self) else {
            throw DecodingError.valueNotFound(T.self, DecodingError.Context(codingPath: [], debugDescription: "The given dictionary was invalid"))
        }
        
        return value
    }
}
