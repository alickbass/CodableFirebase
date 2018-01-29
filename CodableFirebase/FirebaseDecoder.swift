//
//  FirebaseDecoder.swift
//  CodableFirebase
//
//  Created by Oleksii on 27/12/2017.
//  Copyright © 2017 ViolentOctopus. All rights reserved.
//

import Foundation

open class FirebaseDecoder {
    /// The strategy to use for decoding `Date` values.
    public enum DateDecodingStrategy {
        /// Defer to `Date` for decoding. This is the default strategy.
        case deferredToDate
        
        /// Decode the `Date` as a UNIX timestamp from a JSON number.
        case secondsSince1970
        
        /// Decode the `Date` as UNIX millisecond timestamp from a JSON number.
        case millisecondsSince1970
        
        /// Decode the `Date` as an ISO-8601-formatted string (in RFC 3339 format).
        @available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
        case iso8601
        
        /// Decode the `Date` as a string parsed by the given formatter.
        case formatted(DateFormatter)
        
        /// Decode the `Date` as a custom value decoded by the given closure.
        case custom((_ decoder: Decoder) throws -> Date)
    }
    
    /// The strategy to use for decoding `Data` values.
    public enum DataDecodingStrategy {
        /// Defer to `Data` for decoding.
        case deferredToData
        
        /// Decode the `Data` from a Base64-encoded string. This is the default strategy.
        case base64
        
        /// Decode the `Data` as a custom value decoded by the given closure.
        case custom((_ decoder: Decoder) throws -> Data)
    }
    
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
