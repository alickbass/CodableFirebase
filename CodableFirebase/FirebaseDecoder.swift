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
    
    open var userInfo: [CodingUserInfoKey : Any] = [:]
    open var dateDecodingStrategy: DateDecodingStrategy = .deferredToDate
    open var dataDecodingStrategy: DataDecodingStrategy = .deferredToData
    
    open func decode<T : Decodable>(_ type: T.Type, from container: Any) throws -> T {
        let options = _FirebaseDecoder._Options(
            dateDecodingStrategy: dateDecodingStrategy,
            dataDecodingStrategy: dataDecodingStrategy,
            skipFirestoreTypes: false,
            userInfo: userInfo
        )
        let decoder = _FirebaseDecoder(referencing: container, options: options)
        guard let value = try decoder.unbox(container, as: T.self) else {
            throw DecodingError.valueNotFound(T.self, DecodingError.Context(codingPath: [], debugDescription: "The given dictionary was invalid"))
        }
        
        return value
    }
}
